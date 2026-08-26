import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/match_repository.dart';
import '../data/data_ownership_service.dart';
import '../domain/scoring/scoring.dart';
import 'dependencies.dart';

final class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

final class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _participantController = TextEditingController();
  List<PersistedMatch> _matches = const <PersistedMatch>[];
  Sport? _sport;
  MatchCompletionFilter _completion = MatchCompletionFilter.any;
  DateTime? _from;
  DateTime? _through;
  String? _error;
  bool _loading = true;
  bool _busy = false;

  MatchRepository get _repository => ref.read(matchRepositoryProvider);
  DataOwnershipService get _ownership => ref.read(dataOwnershipServiceProvider);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _participantController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final initialized = await _repository.initialize();
    if (initialized case RepositoryFailure<void>(:final message)) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = message;
        });
      }
      return;
    }
    await _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final result = await _repository.queryHistory(
      MatchHistoryFilter(
        fromInclusive: _from,
        toExclusive: _through == null
            ? null
            : DateUtils.dateOnly(_through!).add(const Duration(days: 1)),
        sport: _sport,
        participantName: _participantController.text,
        completion: _completion,
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      switch (result) {
        case RepositorySuccess<List<PersistedMatch>>(:final value):
          _matches = value;
        case RepositoryFailure<List<PersistedMatch>>(:final message):
          _error = message;
      }
    });
  }

  Future<void> _pickDate({required bool from}) async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDate: (from ? _from : _through) ?? DateTime.now(),
      helpText: from ? 'Filter from date' : 'Filter through date',
    );
    if (selected != null && mounted) {
      setState(() {
        if (from) {
          _from = selected;
        } else {
          _through = selected;
        }
      });
    }
  }

  Future<void> _deleteMatch(PersistedMatch match) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this match?'),
        content: Text(
          '${match.configuration.sideOne.name} vs '
          '${match.configuration.sideTwo.name} and its complete score-event '
          'history will be permanently deleted. This cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete match'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    final result = await _repository.deleteMatch(match.configuration.id);
    if (!mounted) {
      return;
    }
    switch (result) {
      case RepositorySuccess<void>():
        _showMessage('Match permanently deleted.');
        await _load();
      case RepositoryFailure<void>(:final message):
        _showMessage(message);
    }
  }

  Future<void> _deleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete all local history?'),
        content: const Text(
          'Every saved and in-progress match, participant record, and ordered '
          'score event will be permanently deleted from this device. Export a '
          'JSON backup first if you may need to restore it. This cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep my data'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete all history'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    setState(() => _busy = true);
    final result = await _repository.deleteAllMatches();
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    switch (result) {
      case RepositorySuccess<int>(:final value):
        _showMessage('$value local matches permanently deleted.');
        await _load();
      case RepositoryFailure<int>(:final message):
        _showMessage(message);
    }
  }

  Future<void> _exportJson() async {
    setState(() => _busy = true);
    final result = await _ownership.createJsonBackup(
      exportedAt: DateTime.now().toUtc(),
    );
    if (!mounted) {
      return;
    }
    if (result case RepositoryFailure<String>(:final message)) {
      setState(() => _busy = false);
      _showMessage(message);
      return;
    }
    final contents = (result as RepositorySuccess<String>).value;
    try {
      await ref
          .read(dataTransferGatewayProvider)
          .shareDocument(
            fileName:
                'court-tally-backup-${DateTime.now().millisecondsSinceEpoch}.json',
            mimeType: 'application/json',
            contents: contents,
          );
    } on Object catch (error) {
      if (mounted) {
        _showMessage('The platform share sheet could not be opened: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _busy = true);
    final result = await _ownership.createCsvSummary();
    if (!mounted) {
      return;
    }
    if (result case RepositoryFailure<String>(:final message)) {
      setState(() => _busy = false);
      _showMessage(message);
      return;
    }
    final contents = (result as RepositorySuccess<String>).value;
    try {
      await ref
          .read(dataTransferGatewayProvider)
          .shareDocument(
            fileName:
                'court-tally-summary-${DateTime.now().millisecondsSinceEpoch}.csv',
            mimeType: 'text/csv',
            contents: contents,
          );
    } on Object catch (error) {
      if (mounted) {
        _showMessage('The platform share sheet could not be opened: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _importJson() async {
    String? source;
    try {
      source = await ref.read(dataTransferGatewayProvider).pickJsonBackup();
    } on Object catch (error) {
      if (mounted) {
        _showMessage('The platform file picker could not be opened: $error');
      }
      return;
    }
    if (source == null || !mounted) {
      return;
    }
    setState(() => _busy = true);
    final previewResult = await _ownership.previewImport(source);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (previewResult case RepositoryFailure<ImportPreview>(:final message)) {
      _showMessage(message);
      return;
    }
    final preview = (previewResult as RepositorySuccess<ImportPreview>).value;
    final mode = await showDialog<MatchImportMode>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Review validated backup'),
        content: SingleChildScrollView(
          child: Text(
            'The complete JSON document and all score-event streams passed '
            'validation.\n\n'
            'Backup: ${preview.backupMatches} matches\n'
            'New matches: ${preview.additions}\n'
            'Matching ids: ${preview.conflicts}\n'
            'Current local matches: ${preview.currentMatches}\n\n'
            'Merge keeps current matches and skips matching ids. Replace '
            'permanently deletes all current local history, then imports this '
            'backup in one transaction.',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, MatchImportMode.merge),
            child: const Text('Merge backup'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, MatchImportMode.replace),
            child: const Text('Replace local data'),
          ),
        ],
      ),
    );
    if (mode == null || !mounted) {
      return;
    }
    setState(() => _busy = true);
    final applied = await _ownership.applyImport(preview, mode);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    switch (applied) {
      case RepositorySuccess<MatchImportResult>(:final value):
        _showMessage(
          'Import complete: ${value.imported} imported, '
          '${value.skipped} skipped, ${value.removed} replaced.',
        );
        await _load();
      case RepositoryFailure<MatchImportResult>(:final message):
        _showMessage(message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _clearFilters() {
    setState(() {
      _sport = null;
      _completion = MatchCompletionFilter.any;
      _from = null;
      _through = null;
      _participantController.clear();
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History and data')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              'Local match history',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'History stays on this device unless you explicitly export it.',
            ),
            const SizedBox(height: 16),
            _FilterCard(
              sport: _sport,
              completion: _completion,
              participantController: _participantController,
              from: _from,
              through: _through,
              onSportChanged: (value) => setState(() => _sport = value),
              onCompletionChanged: (value) =>
                  setState(() => _completion = value),
              onPickFrom: () => _pickDate(from: true),
              onPickThrough: () => _pickDate(from: false),
              onApply: _load,
              onClear: _clearFilters,
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error case final error?)
              _HistoryError(message: error, onRetry: _load)
            else if (_matches.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No matches meet these filters.'),
                ),
              )
            else
              ..._matches.map(
                (match) => _MatchHistoryCard(
                  match: match,
                  onOpen: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MatchDetailScreen(match: match),
                    ),
                  ),
                  onDelete: () => _deleteMatch(match),
                ),
              ),
            const SizedBox(height: 24),
            Text('Your data', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Court Tally has no account, cloud sync, ads, or analytics. '
                  'JSON backup is versioned and lossless. CSV contains summaries '
                  'only and cannot restore presets, participants, or score events. '
                  'Exports and imports open operating-system sheets only after '
                  'you choose an action. No broad storage or other sensitive '
                  'permission is requested. Uninstalling may delete local data.',
                ),
              ),
            ),
            const SizedBox(height: 8),
            _DataAction(
              icon: Icons.backup_outlined,
              label: 'Export lossless JSON backup',
              onPressed: _busy ? null : _exportJson,
            ),
            _DataAction(
              icon: Icons.table_chart_outlined,
              label: 'Export CSV summaries',
              onPressed: _busy ? null : _exportCsv,
            ),
            _DataAction(
              icon: Icons.restore_page_outlined,
              label: 'Import JSON backup',
              onPressed: _busy ? null : _importJson,
            ),
            const SizedBox(height: 8),
            _DataAction(
              icon: Icons.delete_forever_outlined,
              label: 'Delete all local history',
              onPressed: _busy ? null : _deleteAll,
            ),
          ],
        ),
      ),
    );
  }
}

final class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.sport,
    required this.completion,
    required this.participantController,
    required this.from,
    required this.through,
    required this.onSportChanged,
    required this.onCompletionChanged,
    required this.onPickFrom,
    required this.onPickThrough,
    required this.onApply,
    required this.onClear,
  });

  final Sport? sport;
  final MatchCompletionFilter completion;
  final TextEditingController participantController;
  final DateTime? from;
  final DateTime? through;
  final ValueChanged<Sport?> onSportChanged;
  final ValueChanged<MatchCompletionFilter> onCompletionChanged;
  final VoidCallback onPickFrom;
  final VoidCallback onPickThrough;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Filters', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            DropdownButtonFormField<Sport?>(
              initialValue: sport,
              decoration: const InputDecoration(
                labelText: 'Sport',
                border: OutlineInputBorder(),
              ),
              items: <DropdownMenuItem<Sport?>>[
                const DropdownMenuItem<Sport?>(child: Text('Any sport')),
                ...Sport.values.map(
                  (value) => DropdownMenuItem<Sport?>(
                    value: value,
                    child: Text(_sportName(value)),
                  ),
                ),
              ],
              onChanged: onSportChanged,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: participantController,
              decoration: const InputDecoration(
                labelText: 'Participant name contains',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onApply(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MatchCompletionFilter>(
              initialValue: completion,
              decoration: const InputDecoration(
                labelText: 'Completion state',
                border: OutlineInputBorder(),
              ),
              items: const <DropdownMenuItem<MatchCompletionFilter>>[
                DropdownMenuItem(
                  value: MatchCompletionFilter.any,
                  child: Text('Any state'),
                ),
                DropdownMenuItem(
                  value: MatchCompletionFilter.inProgress,
                  child: Text('In progress'),
                ),
                DropdownMenuItem(
                  value: MatchCompletionFilter.completed,
                  child: Text('Completed'),
                ),
              ],
              onChanged: (value) => onCompletionChanged(value!),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton(
                  onPressed: onPickFrom,
                  child: Text(
                    from == null ? 'From date' : 'From ${_date(from!)}',
                  ),
                ),
                OutlinedButton(
                  onPressed: onPickThrough,
                  child: Text(
                    through == null
                        ? 'Through date'
                        : 'Through ${_date(through!)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: <Widget>[
                FilledButton(
                  onPressed: onApply,
                  child: const Text('Apply filters'),
                ),
                TextButton(
                  onPressed: onClear,
                  child: const Text('Clear filters'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _MatchHistoryCard extends StatelessWidget {
  const _MatchHistoryCard({
    required this.match,
    required this.onOpen,
    required this.onDelete,
  });

  final PersistedMatch match;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final configuration = match.configuration;
    return Card(
      child: Semantics(
        container: true,
        label:
            '${_sportName(configuration.preset.sport)} match, '
            '${configuration.sideOne.name} versus ${configuration.sideTwo.name}, '
            '${_statusName(match.state.status)}',
        child: ListTile(
          minVerticalPadding: 12,
          title: Text(
            '${configuration.sideOne.name} vs ${configuration.sideTwo.name}',
          ),
          subtitle: Text(
            '${_sportName(configuration.preset.sport)} • '
            '${_statusName(match.state.status)} • ${_date(match.createdAt)}',
          ),
          onTap: onOpen,
          trailing: IconButton(
            tooltip: 'Delete this match',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ),
      ),
    );
  }
}

final class _DataAction extends StatelessWidget {
  const _DataAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }
}

final class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Text(message),
            const SizedBox(height: 8),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

final class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({required this.match, super.key});

  final PersistedMatch match;

  @override
  Widget build(BuildContext context) {
    final configuration = match.configuration;
    final states = _replayStates(match);
    return Scaffold(
      appBar: AppBar(title: const Text('Match detail')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              '${configuration.sideOne.name} vs ${configuration.sideTwo.name}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(configuration.preset.name),
            Text('Created ${match.createdAt.toLocal()}'),
            Text('Status: ${_statusName(match.state.status)}'),
            if (match.state.winner case final winner?)
              Text(
                'Winner: ${winner == SideId.one ? configuration.sideOne.name : configuration.sideTwo.name}',
              ),
            const SizedBox(height: 20),
            Text(
              'Ordered event replay',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (match.events.isEmpty)
              const Text('No score events recorded.')
            else
              ...List<Widget>.generate(match.events.length, (index) {
                final event = match.events[index];
                final state = states[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${event.sequence + 1}')),
                    title: Text(_eventName(event.event, configuration)),
                    subtitle: Text(
                      '${event.occurredAt.toLocal()}\n'
                      'Points ${state.pointLabelFor(SideId.one)}–'
                      '${state.pointLabelFor(SideId.two)}, games '
                      '${state.gamesOne}–${state.gamesTwo}'
                      '${configuration.preset.sport == Sport.tennis ? ', sets ${state.setsOne}–${state.setsTwo}' : ''}',
                    ),
                    isThreeLine: true,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

List<MatchState> _replayStates(PersistedMatch match) {
  final created = const MatchReducer().create(match.configuration);
  if (created is! MatchCreated) {
    return const <MatchState>[];
  }
  var state = created.state;
  final states = <MatchState>[];
  for (final saved in match.events) {
    final transition = const MatchReducer().apply(state, saved.event);
    if (transition is! ScoreAccepted) {
      return const <MatchState>[];
    }
    state = transition.state;
    states.add(state);
  }
  return states;
}

String _eventName(
  ScoreEvent event,
  MatchConfiguration configuration,
) => switch (event) {
  InitialServerChosen(:final side) =>
    '${side == SideId.one ? configuration.sideOne.name : configuration.sideTwo.name} chosen to serve first',
  PointAwarded(:final side) =>
    'Point to ${side == SideId.one ? configuration.sideOne.name : configuration.sideTwo.name}',
  SidesChanged() => 'Change of ends confirmed',
  PointUndone() => 'Previous point undone',
  PointRedone() => 'Point redone',
};

String _sportName(Sport sport) => switch (sport) {
  Sport.pickleball => 'Pickleball',
  Sport.tennis => 'Tennis',
  Sport.badminton => 'Badminton',
  Sport.tableTennis => 'Table tennis',
};

String _statusName(MatchStatus status) => switch (status) {
  MatchStatus.awaitingInitialServer => 'Awaiting initial server',
  MatchStatus.inProgress => 'In progress',
  MatchStatus.completed => 'Completed',
};

String _date(DateTime value) =>
    value.toLocal().toIso8601String().substring(0, 10);
