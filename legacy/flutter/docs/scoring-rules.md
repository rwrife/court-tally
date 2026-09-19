# Scoring rules and supported presets

Court Tally's scoring domain is a deterministic recreational scorekeeper, not
an officiating tool. It records the winner of each rally and derives score,
service, change-of-ends prompts, game/set completion, and match completion from
an ordered event stream. The domain has no Flutter, storage, network, account,
analytics, or device dependency.

## Versioned presets

Preset identifiers and version numbers are persistence contracts. Version 1
supports exactly these formats:

| Preset id | Supported format |
|---|---|
| `pickleball.usap.side-out.best-of-3-to-11` | Traditional side-out scoring; best of three games; each game to 11, win by two |
| `pickleball.usap.side-out.single-to-15` | Traditional side-out scoring; one game to 15, win by two |
| `pickleball.usap.side-out.single-to-21` | Traditional side-out scoring; one game to 21, win by two |
| `tennis.itf.advantage.best-of-3` | Best of three advantage sets; first to six games by two; seven-point tiebreak at 6–6, win by two |
| `badminton.bwf.best-of-3-to-21` | Best of three rally-scored games to 21, win by two, hard cap at 30 |
| `table-tennis.ittf.best-of-5-to-11` | Best of five games to 11, win by two |

No-fast-four tennis, no-ad tennis, match tiebreaks, pickleball rally scoring,
short-game badminton, and other formats are deliberately unsupported in v1.
The application must reject unknown preset ids/versions instead of mapping them
to a similar format. Adding a format requires a new named preset, a versioned
contract, and rule tests.

## Service and changing ends

- **Pickleball:** only the serving side scores. In doubles, the opening service
  sequence of each game begins at service number 2 and later side-outs begin at
  service number 1. Singles side-outs transfer service immediately and do not
  invent a second server. This side-level model intentionally does not claim
  individual doubles-player position tracking. The first-serving side alternates
  between games. Change ends between games and at 6, 8, or 11 in a deciding game
  played to 11, 15, or 21 respectively.
- **Tennis:** one side serves for a normal game. Service alternates by game. In
  a tiebreak the next side serves two points after the opening one-point service,
  then service alternates every two points. Change ends after odd-numbered
  games and every six tiebreak points.
- **Badminton:** rally winner scores and serves next. A game winner serves first
  in the next game. Change ends between games and when a side first reaches 11
  in the deciding game.
- **Table tennis:** service alternates every two points, then every point once
  both sides reach 10. The first server alternates between games. Change ends
  between games and when a side first reaches 5 in the deciding game.

A generated change-of-ends prompt must be acknowledged with `SidesChanged`
before another point is accepted. `PointUndone` and `PointRedone` change the
effective point stream; replaying that stream produces the same state.

## Authoritative sources

Rules were implemented against the governing bodies' published rules pages and
rulebooks, accessed 2026-08-23:

- [USA Pickleball Official Rulebook](https://usapickleball.org/rules/) — scoring,
  service sequence, game formats, and change-of-ends rules.
- [International Tennis Federation Rules and Regulations](https://www.itftennis.com/en/about-us/governance/rules-and-regulations/)
  — Rules of Tennis sections on game/set scoring, tie-break service, and changing
  ends.
- [Badminton World Federation Statutes](https://corporate.bwfbadminton.com/statutes/)
  — Laws of Badminton sections 7–8 and 11 on scoring, changing ends, and service.
- [International Table Tennis Federation Statutes](https://www.ittf.com/statutes/)
  — Laws of Table Tennis sections 2.11–2.13 on games, matches, service order,
  and changing ends.

Court Tally resolves only scorekeeping consequences. It does not decide faults,
lets, line calls, misconduct, substitutions, injuries, equipment compliance, or
any other officiating question.
