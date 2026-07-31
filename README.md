# PNE Staff App

Cross-platform (Android + iOS, phone + tablet) staff application built with
Flutter, clean architecture, and the BLoC pattern. Everything visual is
tokenized and runtime-adjustable (theme, colors, fonts, text scale), and the
core ships with networking, storage, notifications, background tasks, and
permissions already wired.

## Tech stack

| Concern | Package |
|---|---|
| State management | `flutter_bloc`, `hydrated_bloc`, `bloc_concurrency` |
| Dependency injection | `get_it` + `injectable` |
| Routing | `go_router` (auth-guarded, adaptive shell) |
| Networking | `dio` (+ retry, logging), `connectivity_plus` |
| Functional errors | `fpdart` (`Either`), sealed `Failure`/`AppException` |
| Storage | `flutter_secure_storage`, `shared_preferences`, `hive_ce` |
| Theming | design tokens + `ThemeExtension` + `google_fonts` |
| Notifications | `firebase_messaging` (FCM) + `flutter_local_notifications` |
| Background tasks | `workmanager` |
| Permissions | `permission_handler` |
| Codegen | `build_runner`, `freezed`, `json_serializable`, `injectable_generator`, `envied` |
| Testing | `bloc_test`, `mocktail`, `alchemist` (golden) |

## Architecture

Feature-first clean architecture:

```
lib/
├── app/                 # bootstrap, root widget, BlocObserver
├── core/                # cross-cutting infrastructure
│   ├── config/          # Flavor / FlavorConfig, envied secrets
│   ├── di/              # injectable container + third-party module
│   ├── network/         # ApiClient over Dio, interceptors, error mapping
│   ├── storage/         # secure / prefs / token storage
│   ├── notifications/   # local + FCM services, channels, deep-link router
│   ├── background/      # workmanager service + callback dispatcher
│   ├── permissions/     # PermissionService
│   ├── router/          # go_router + auth redirect + shell
│   ├── theme/           # tokens, ThemeCubit, AppTheme builder, presets
│   ├── responsive/      # breakpoints, adaptive scaffolds
│   ├── error/ result/   # Failure/Exception model + Either helpers
│   └── widgets/         # shared UI (buttons, fields, loaders, states)
├── features/
│   └── <feature>/
│       ├── data/        # models (DTOs), data sources, repository impls
│       ├── domain/      # entities, repository interfaces, use cases
│       └── presentation/# bloc + views + widgets
└── l10n/                # gen-l10n (app_en.arb)
```

Dependencies point inward: `presentation → domain ← data`. Repositories return
`FutureResult<T>` (`Either<Failure, T>`); data sources throw `AppException`s that
`guardAsync` maps to `Failure`s.

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generate DI/JSON/env
cp .env.example .env                                        # then fill in secrets

# Run (dev flavor)
flutter run --flavor dev --target lib/main_dev.dart
```

### Flavors

Three flavors (`dev` / `staging` / `prod`) each have a Dart entry point and a
matching Android product flavor / iOS configuration:

```bash
flutter run   --flavor dev     -t lib/main_dev.dart
flutter build apk   --flavor staging -t lib/main_staging.dart
flutter build ipa   --flavor prod    -t lib/main_prod.dart
```

Per-flavor config (app name, base URL, feature flags) lives in
`lib/core/config/flavor.dart`. On `dev`, auth uses an **offline fake** data
source so the app runs with no backend; `staging`/`prod` use the real REST API.

### Firebase / push notifications

Push is **optional** and disabled until configured — the app builds and runs
(local + scheduled notifications work) without it. To enable FCM:

```bash
dart pub global activate flutterfire_cli
flutterfire configure        # regenerates lib/firebase_options.dart
```

### iOS

```bash
cd ios && pod install
```

Requires iOS 15+ (Firebase). Background modes, `BGTaskScheduler` identifiers,
and permission usage strings are pre-configured in `ios/Runner/Info.plist`; task
registration is in `ios/Runner/AppDelegate.swift`.

## Customizing the look

All styling flows from `lib/core/theme`:

- **Brand color** — change the `pne` seed in `theme_presets.dart` and the accents
  in `extensions/app_colors_x.dart`.
- **Tokens** — spacing/radii/elevation/typography live in `theme/tokens/`.
- **At runtime** — the Appearance screen drives `ThemeCubit` (mode, preset, font,
  text scale); changes persist via `hydrated_bloc` and restyle the app live.

## Testing

```bash
flutter analyze
flutter test
```

## Code generation

Re-run after changing anything annotated (`@injectable`, `@JsonSerializable`,
`envied`, freezed):

```bash
dart run build_runner watch --delete-conflicting-outputs
```
