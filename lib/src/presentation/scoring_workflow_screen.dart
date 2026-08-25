import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/match_repository.dart';
import '../domain/scoring/scoring.dart';
import 'dependencies.dart';

/// Owns the local setup-to-score workflow and restores unfinished matches.
final class ScoringWorkflowScreen extends ConsumerStatefulWidget {
  const ScoringWorkflowScreen({super.key});

  @override
  ConsumerState<ScoringWorkflowScreen> createState() =>
      _ScoringWorkflowScreenState();
}

final class _ScoringWorkflowScreenState
    extends ConsumerState<ScoringWorkflowScreen> {
  PersistedMatch? _match;
  String? _error;
  String _announcement = 'Court Tally ready.';
  bool _loading = true;
  bool _busy = false;

  MatchRepository get _repository => ref.read(matchRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final initialized = await _repository.initialize();
    if (initialized case RepositoryFailure<void>(:final message)) {
      _showLoadFailure(message);
      return;
    }
    final result = await _repository.loadResumableMatch();
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      switch (result) {
        case RepositorySuccess<PersistedMatch?>(:final value):
          _match = value;
        case RepositoryFailure<PersistedMatch?>(:final message):
          _error = message;
      }
    });
  }

  void _showLoadFailure(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _error = message;
      _loading = false;
      _busy = false;
    });
  }

  Future<void> _startMatch({
    required String sideOneName,
    required String sideTwoName,
    required RulesPreset preset,
    required SideId initialServer,
    required bool doubles,
    String? sideOnePartner,
    String? sideTwoPartner,
  }) async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    final createdAt = DateTime.now().toUtc();
    final matchId = 'match-${createdAt.microsecondsSinceEpoch}';
    final configuration = MatchConfiguration(
      id: matchId,
      sideOne: _buildSide(
        matchId: matchId,
        side: SideId.one,
        name: sideOneName,
        doubles: doubles,
        partnerName: sideOnePartner,
      ),
      sideTwo: _buildSide(
        matchId: matchId,
        side: SideId.two,
        name: sideTwoName,
        doubles: doubles,
        partnerName: sideTwoPartner,
      ),
      preset: preset,
    );
    final result = await _repository.createMatch(
      configuration,
      createdAt: createdAt,
      initialServer: initialServer,
    );
    if (!mounted) {
      return;
    }
    switch (result) {
      case RepositorySuccess<PersistedMatch>(:final value):
        setState(() {
          _match = value;
          _announcement = _announcementFor(
            InitialServerChosen(initialServer),
            value,
          );
          _busy = false;
        });
      case RepositoryFailure<PersistedMatch>(:final message):
        _showLoadFailure(message);
    }
  }

  Future<void> _appendEvent(ScoreEvent event) async {
    final current = _match;
    if (_busy || current == null) {
      return;
    }
    setState(() => _busy = true);
    final result = await _repository.appendEvent(
      matchId: current.configuration.id,
      event: event,
      expectedSequence: current.nextSequence,
      occurredAt: DateTime.now().toUtc(),
    );
    if (!mounted) {
      return;
    }
    switch (result) {
      case RepositorySuccess<PersistedMatch>(:final value):
        final justCompleted =
            !current.state.isComplete && value.state.isComplete;
        setState(() {
          _match = value;
          _announcement = _announcementFor(event, value);
          _busy = false;
        });
        if (justCompleted) {
          await _showCompletionDialog(value);
        }
      case RepositoryFailure<PersistedMatch>(:final message):
        setState(() {
          _announcement = 'Action not saved. $message';
          _busy = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirmAbandon() async {
    final current = _match;
    if (_busy || current == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Abandon this match?'),
        content: const Text(
          'This permanently deletes the in-progress match and its score events.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep scoring'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Abandon and delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _busy = true);
    final result = await _repository.deleteMatch(current.configuration.id);
    if (!mounted) {
      return;
    }
    switch (result) {
      case RepositorySuccess<void>():
        setState(() {
          _match = null;
          _busy = false;
          _announcement = 'In-progress match deleted.';
        });
      case RepositoryFailure<void>(:final message):
        setState(() => _busy = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _showCompletionDialog(PersistedMatch match) async {
    final winner = match.state.winner == SideId.one
        ? match.configuration.sideOne.name
        : match.configuration.sideTwo.name;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Match complete'),
          content: Text('$winner won the match.'),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Finish match'),
            ),
          ],
        ),
      ),
    );
    if (mounted) {
      setState(() {
        _match = null;
        _announcement = 'Match saved to local history.';
      });
    }
  }

  String _announcementFor(ScoreEvent event, PersistedMatch match) {
    final state = match.state;
    final configuration = match.configuration;
    final one = state.pointLabelFor(SideId.one);
    final two = state.pointLabelFor(SideId.two);
    final server = state.server == SideId.one
        ? configuration.sideOne.name
        : configuration.sideTwo.name;
    final base = switch (event) {
      PointAwarded() =>
        'Score updated. ${configuration.sideOne.name} $one, '
            '${configuration.sideTwo.name} $two. Serving $server.',
      PointUndone() =>
        'Undid last point. ${configuration.sideOne.name} $one, '
            '${configuration.sideTwo.name} $two.',
      PointRedone() =>
        'Redid point. ${configuration.sideOne.name} $one, '
            '${configuration.sideTwo.name} $two.',
      SidesChanged() => 'Change of ends confirmed. Serving $server.',
      InitialServerChosen() => 'Match started. Serving $server.',
    };
    final prompt = state.sideChangePrompt;
    if (event is PointAwarded && prompt != null) {
      return '$base Change ends. ${prompt.description}';
    }
    return base;
  }

  MatchSide _buildSide({
    required String matchId,
    required SideId side,
    required String name,
    required bool doubles,
    required String? partnerName,
  }) {
    return MatchSide(
      id: side,
      name: name.trim(),
      participants: <Participant>[
        Participant(id: '$matchId-${side.name}-1', name: name.trim()),
        if (doubles)
          Participant(id: '$matchId-${side.name}-2', name: partnerName!.trim()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Court Tally')),
      body: SafeArea(
        child: switch ((_loading, _error, _match)) {
          (true, _, _) => const Center(child: CircularProgressIndicator()),
          (false, final String error, _) => _LoadFailure(
            message: error,
            onRetry: () {
              setState(() {
                _error = null;
                _loading = true;
              });
              _restore();
            },
          ),
          (false, null, null) => _MatchSetupForm(
            busy: _busy,
            onStart: _startMatch,
          ),
          (false, null, final PersistedMatch match)
              when match.state.status == MatchStatus.awaitingInitialServer =>
            _InitialServerRecovery(
              match: match,
              busy: _busy,
              onChoose: (side) => _appendEvent(InitialServerChosen(side)),
              onAbandon: _confirmAbandon,
            ),
          (false, null, final PersistedMatch match) => _LiveScoringView(
            match: match,
            busy: _busy,
            announcement: _announcement,
            onEvent: _appendEvent,
            onAbandon: _confirmAbandon,
          ),
        },
      ),
    );
  }
}

typedef _StartMatch = Future<void> Function({
  required String sideOneName,
  required String sideTwoName,
  required RulesPreset preset,
  required SideId initialServer,
  required bool doubles,
  String? sideOnePartner,
  String? sideTwoPartner,
});

final class _MatchSetupForm extends StatefulWidget {
  const _MatchSetupForm({required this.busy, required this.onStart});

  final bool busy;
  final _StartMatch onStart;

  @override
  State<_MatchSetupForm> createState() => _MatchSetupFormState();
}

final class _MatchSetupFormState extends State<_MatchSetupForm> {
  final _formKey = GlobalKey<FormState>();
  final _sideOneController = TextEditingController();
  final _sideTwoController = TextEditingController();
  final _sideOnePartnerController = TextEditingController();
  final _sideTwoPartnerController = TextEditingController();
  Sport _sport = Sport.pickleball;
  RulesPreset _pickleballPreset = RulesPreset.pickleballBestOfThree;
  SideId _initialServer = SideId.one;
  bool _doubles = false;

  RulesPreset get _preset => switch (_sport) {
    Sport.pickleball => _pickleballPreset,
    Sport.tennis => RulesPreset.tennisBestOfThree,
    Sport.badminton => RulesPreset.badmintonBestOfThree,
    Sport.tableTennis => RulesPreset.tableTennisBestOfFive,
  };

  @override
  void dispose() {
    _sideOneController.dispose();
    _sideTwoController.dispose();
    _sideOnePartnerController.dispose();
    _sideTwoPartnerController.dispose();
    super.dispose();
  }

  String? _requiredName(String? value, String label) {
    return value == null || value.trim().isEmpty
        ? 'Enter a name for $label.'
        : null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    widget.onStart(
      sideOneName: _sideOneController.text,
      sideTwoName: _sideTwoController.text,
      preset: _preset,
      initialServer: _initialServer,
      doubles: _doubles,
      sideOnePartner: _doubles ? _sideOnePartnerController.text : null,
      sideTwoPartner: _doubles ? _sideTwoPartnerController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: 'New match setup',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Text('Start a match', style: textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('No account or network connection required.'),
            const SizedBox(height: 24),
            DropdownButtonFormField<Sport>(
              initialValue: _sport,
              decoration: const InputDecoration(
                labelText: 'Sport preset',
                border: OutlineInputBorder(),
              ),
              items: Sport.values
                  .map(
                    (sport) => DropdownMenuItem<Sport>(
                      value: sport,
                      child: Text(_sportName(sport)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: widget.busy
                  ? null
                  : (value) => setState(() => _sport = value!),
            ),
            if (_sport == Sport.pickleball) ...<Widget>[
              const SizedBox(height: 16),
              DropdownButtonFormField<RulesPreset>(
                initialValue: _pickleballPreset,
                decoration: const InputDecoration(
                  labelText: 'Pickleball match format',
                  border: OutlineInputBorder(),
                ),
                items:
                    const <RulesPreset>[
                          RulesPreset.pickleballBestOfThree,
                          RulesPreset.pickleballSingleGame15,
                          RulesPreset.pickleballSingleGame21,
                        ]
                        .map(
                          (preset) => DropdownMenuItem<RulesPreset>(
                            value: preset,
                            child: Text(preset.name),
                          ),
                        )
                        .toList(growable: false),
                onChanged: widget.busy
                    ? null
                    : (value) => setState(() => _pickleballPreset = value!),
              ),
            ],
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment<bool>(value: false, label: Text('Singles')),
                ButtonSegment<bool>(value: true, label: Text('Doubles')),
              ],
              selected: <bool>{_doubles},
              onSelectionChanged: widget.busy
                  ? null
                  : (selection) => setState(() => _doubles = selection.single),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sideOneController,
              enabled: !widget.busy,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Side 1 name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _requiredName(value, 'side 1'),
            ),
            if (_doubles) ...<Widget>[
              const SizedBox(height: 16),
              TextFormField(
                controller: _sideOnePartnerController,
                enabled: !widget.busy,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Side 1 partner',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _requiredName(value, 'side 1 partner'),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _sideTwoController,
              enabled: !widget.busy,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Side 2 name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _requiredName(value, 'side 2'),
            ),
            if (_doubles) ...<Widget>[
              const SizedBox(height: 16),
              TextFormField(
                controller: _sideTwoPartnerController,
                enabled: !widget.busy,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Side 2 partner',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _requiredName(value, 'side 2 partner'),
              ),
            ],
            const SizedBox(height: 20),
            Text('Initial server', style: textTheme.titleMedium),
            RadioGroup<SideId>(
              groupValue: _initialServer,
              onChanged: (value) {
                if (!widget.busy) {
                  setState(() => _initialServer = value!);
                }
              },
              child: Column(
                children: <Widget>[
                  RadioListTile<SideId>(
                    value: SideId.one,
                    title: const Text('Side 1 serves first'),
                  ),
                  RadioListTile<SideId>(
                    value: SideId.two,
                    title: const Text('Side 2 serves first'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: FilledButton(
                onPressed: widget.busy ? null : _submit,
                child: Text(widget.busy ? 'Starting…' : 'Start match'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sportName(Sport sport) => switch (sport) {
    Sport.pickleball => 'Pickleball',
    Sport.tennis => 'Tennis',
    Sport.badminton => 'Badminton',
    Sport.tableTennis => 'Table tennis',
  };
}

final class _InitialServerRecovery extends StatelessWidget {
  const _InitialServerRecovery({
    required this.match,
    required this.busy,
    required this.onChoose,
    required this.onAbandon,
  });

  final PersistedMatch match;
  final bool busy;
  final Future<void> Function(SideId) onChoose;
  final Future<void> Function() onAbandon;

  @override
  Widget build(BuildContext context) {
    final configuration = match.configuration;
    return Semantics(
      container: true,
      label: 'Resume match setup',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Text(
            'Resume match setup',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${configuration.sideOne.name} vs ${configuration.sideTwo.name}',
          ),
          Text(configuration.preset.name),
          const SizedBox(height: 16),
          const Text('Choose the initial server to continue.'),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: FilledButton(
              onPressed: busy ? null : () => onChoose(SideId.one),
              child: Text('${configuration.sideOne.name} serves first'),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: FilledButton(
              onPressed: busy ? null : () => onChoose(SideId.two),
              child: Text('${configuration.sideTwo.name} serves first'),
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: OutlinedButton.icon(
              onPressed: busy ? null : onAbandon,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Abandon match'),
            ),
          ),
        ],
      ),
    );
  }
}

final class _LiveScoringView extends StatelessWidget {
  const _LiveScoringView({
    required this.match,
    required this.busy,
    required this.announcement,
    required this.onEvent,
    required this.onAbandon,
  });

  final PersistedMatch match;
  final bool busy;
  final String announcement;
  final Future<void> Function(ScoreEvent) onEvent;
  final Future<void> Function() onAbandon;

  @override
  Widget build(BuildContext context) {
    final configuration = match.configuration;
    final state = match.state;
    final servingName = state.server == SideId.one
        ? configuration.sideOne.name
        : configuration.sideTwo.name;
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final landscape = constraints.maxWidth > constraints.maxHeight;
          final controls = <Widget>[
            _ScoreControl(
              order: 1,
              side: SideId.one,
              name: configuration.sideOne.name,
              score: state.pointLabelFor(SideId.one),
              serving: state.server == SideId.one,
              enabled:
                  !busy && !state.isComplete && state.sideChangePrompt == null,
              onPressed: () => onEvent(const PointAwarded(SideId.one)),
            ),
            _ScoreControl(
              order: 2,
              side: SideId.two,
              name: configuration.sideTwo.name,
              score: state.pointLabelFor(SideId.two),
              serving: state.server == SideId.two,
              enabled:
                  !busy && !state.isComplete && state.sideChangePrompt == null,
              onPressed: () => onEvent(const PointAwarded(SideId.two)),
            ),
          ];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Live match',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '${configuration.sideOne.name} vs ${configuration.sideTwo.name}',
                ),
                Text(configuration.preset.name),
                const SizedBox(height: 8),
                Semantics(
                  container: true,
                  liveRegion: true,
                  label: announcement,
                  child: ExcludeSemantics(
                    child: Text(
                      'Points: ${state.pointLabelFor(SideId.one)}–'
                      '${state.pointLabelFor(SideId.two)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                Text('Games: ${state.gamesOne}–${state.gamesTwo}'),
                if (configuration.preset.sport == Sport.tennis)
                  Text('Sets: ${state.setsOne}–${state.setsTwo}'),
                Text('Serving: $servingName'),
                Text(
                  'Game ${state.gameNumber}'
                  '${configuration.preset.sport == Sport.tennis ? ', set ${state.setNumber}' : ''}',
                ),
                const SizedBox(height: 16),
                if (landscape)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(child: controls.first),
                        const SizedBox(width: 16),
                        Expanded(child: controls.last),
                      ],
                    ),
                  )
                else ...<Widget>[
                  controls.first,
                  const SizedBox(height: 16),
                  controls.last,
                ],
                if (state.sideChangePrompt case final prompt?) ...<Widget>[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Change ends',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(prompt.description),
                          const SizedBox(height: 12),
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(3),
                            child: FilledButton.tonal(
                              onPressed: busy
                                  ? null
                                  : () => onEvent(const SidesChanged()),
                              child: const Text('Confirm sides changed'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(4),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: OutlinedButton.icon(
                          onPressed: !busy && state.pointHistory.isNotEmpty
                              ? () => onEvent(const PointUndone())
                              : null,
                          icon: const Icon(Icons.undo),
                          label: const Text('Undo'),
                        ),
                      ),
                    ),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(5),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: OutlinedButton.icon(
                          onPressed: !busy && state.redoStack.isNotEmpty
                              ? () => onEvent(const PointRedone())
                              : null,
                          icon: const Icon(Icons.redo),
                          label: const Text('Redo'),
                        ),
                      ),
                    ),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(6),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: OutlinedButton.icon(
                          onPressed: busy ? null : onAbandon,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Abandon match'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

final class _ScoreControl extends StatelessWidget {
  const _ScoreControl({
    required this.order,
    required this.side,
    required this.name,
    required this.score,
    required this.serving,
    required this.enabled,
    required this.onPressed,
  });

  final double order;
  final SideId side;
  final String name;
  final String score;
  final bool serving;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label =
        'Award point to $name. Current score $score. '
        '${serving ? 'Serving.' : 'Receiving.'}';
    return FocusTraversalOrder(
      order: NumericFocusOrder(order),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: label,
        onTap: enabled ? onPressed : null,
        excludeSemantics: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 160),
          child: FilledButton.tonal(
            key: ValueKey<String>('score-${side.name}'),
            onPressed: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(name, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(score, style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 8),
                  Text(serving ? 'SERVING' : 'RECEIVING'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
