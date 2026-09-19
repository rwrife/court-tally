# Architecture boundaries

Court Tally uses inward dependencies so scoring can remain deterministic and testable without a Flutter runtime.

```text
presentation (Flutter + Riverpod composition)
        │
        ├───────────────┐
        ▼               ▼
application ───────► domain ◄────── data
  use cases          pure Dart       local adapters
  + ports
```

## Layer contracts

| Layer | Location | Responsibility | May depend on |
|---|---|---|---|
| Domain | `lib/src/domain/` | Immutable product and, later, scoring concepts | Dart core only |
| Application | `lib/src/application/` | Use cases and repository ports | Domain |
| Data | `lib/src/data/` | Local implementations of application ports | Application, domain, local persistence libraries |
| Presentation | `lib/src/presentation/` | Flutter widgets, routing, themes, and Riverpod composition | Application, domain, data, Flutter |

The domain layer must not import Flutter, Riverpod, platform channels, persistence, or any outer layer. `test/architecture/domain_boundary_test.dart` enforces that rule. Repository interfaces live in the application layer; concrete adapters live in data. Riverpod providers are confined to presentation as the composition root.

## Current application flow

1. `MainApp` establishes the Riverpod dependency-injection scope.
2. `matchRepositoryProvider` owns the app-private Drift database adapter.
3. `ScoringWorkflowScreen` initializes local storage and restores the newest unfinished match.
4. The setup form maps four sport choices and the supported pickleball formats to immutable named presets, validates singles/doubles names, and atomically persists the configuration with its initial server.
5. The live surface serializes every point, undo, redo, and side-change acknowledgement through `MatchRepository`; repository replay remains authoritative.
6. Rule completion opens an explicit finish confirmation and retains the completed match in local history. Explicitly confirmed abandonment deletes only that in-progress match.
7. The history/data route queries the same repository through application filters, replays ordered events for detail, and requires confirmation for one/all-history deletion.
8. `DataOwnershipService` produces versioned lossless JSON and escaped CSV. JSON import is fully decoded and replay-validated in staging, previewed, then merged or replaced by one repository transaction.
9. `DataTransferGateway` keeps operating-system picker/share APIs outside the application boundary; Riverpod supplies the platform adapter and tests supply an in-memory fake.

The pure-Dart scoring model, named presets, sport rules, and reducer live under
`lib/src/domain/scoring/`. They remain independent of Flutter and can be
exercised with ordinary unit tests.

`MatchRepository` is the application-layer persistence contract. Its Drift
adapter stores configurations and ordered score events transactionally, then
replays those events to return derived state. `InMemoryMatchRepository` follows
the same sequence/conflict contract for tests. Riverpod owns the app-private
database lifetime in the presentation composition root, but persistence types
never cross inward into application or domain code. See
[the versioned schema and recovery contract](local-data-schema.md) and
[the data-ownership/export contract](data-ownership.md).
