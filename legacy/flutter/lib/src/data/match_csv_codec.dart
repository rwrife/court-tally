import '../application/match_repository.dart';
import '../domain/scoring/scoring.dart';

/// Portable match-summary CSV. This intentionally excludes the authoritative
/// event stream and therefore is not a restore format.
final class MatchCsvCodec {
  const MatchCsvCodec();

  String encode(List<PersistedMatch> matches) {
    final rows = <List<String>>[
      const <String>[
        'match_id',
        'sport',
        'preset',
        'status',
        'created_at_utc',
        'completed_at_utc',
        'side_one',
        'side_two',
        'winner',
        'score',
        'event_count',
      ],
      ...matches.map(_row),
    ];
    return '${rows.map((row) => row.map((value) => _escape(_spreadsheetSafe(value))).join(',')).join('\r\n')}\r\n';
  }

  List<String> _row(PersistedMatch match) {
    final state = match.state;
    final configuration = match.configuration;
    final winner = switch (state.winner) {
      SideId.one => configuration.sideOne.name,
      SideId.two => configuration.sideTwo.name,
      null => '',
    };
    final score = configuration.preset.sport == Sport.tennis
        ? 'sets ${state.setsOne}-${state.setsTwo}; games '
              '${state.gamesOne}-${state.gamesTwo}; points '
              '${state.pointLabelFor(SideId.one)}-'
              '${state.pointLabelFor(SideId.two)}'
        : 'games ${state.gamesOne}-${state.gamesTwo}; points '
              '${state.pointsOne}-${state.pointsTwo}';
    return <String>[
      configuration.id,
      _sportName(configuration.preset.sport),
      configuration.preset.name,
      state.status.name,
      match.createdAt.toUtc().toIso8601String(),
      match.completedAt?.toUtc().toIso8601String() ?? '',
      configuration.sideOne.name,
      configuration.sideTwo.name,
      winner,
      score,
      match.events.length.toString(),
    ];
  }

  String _spreadsheetSafe(String value) {
    final candidate = value.trimLeft();
    if (candidate.isNotEmpty && '=+-@'.contains(candidate[0])) {
      // CSV consumers commonly open summaries in spreadsheets. Prefix formula-
      // like user text so it is displayed literally rather than evaluated.
      return "'$value";
    }
    return value;
  }

  String _escape(String value) {
    if (!value.contains(RegExp('[,"\r\n]'))) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }

  String _sportName(Sport sport) => switch (sport) {
    Sport.pickleball => 'Pickleball',
    Sport.tennis => 'Tennis',
    Sport.badminton => 'Badminton',
    Sport.tableTennis => 'Table tennis',
  };
}
