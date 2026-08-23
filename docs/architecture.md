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
2. `productStatusRepositoryProvider` supplies the local data adapter.
3. `LoadProductStatus` reads the repository port.
4. `PreMvpScreen` renders the pure-Dart `ProductStatus` through the named home route.

The pure-Dart scoring model, named presets, sport rules, and reducer live under
`lib/src/domain/scoring/`. They remain independent of Flutter and can be
exercised with ordinary unit tests. The presentation shell is intentionally not
wired to scoring until the setup/live-scoring milestone.
