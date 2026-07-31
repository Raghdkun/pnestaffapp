# CLAUDE.md — PNE Staff App

Project memory for Claude Code. Keep this current when architecture, conventions, or the auth contract change.

## What this is
Cross-platform Flutter **staff app** (Android + iOS, phone + tablet). Clean architecture + BLoC. Fully tokenized/runtime-adjustable theming, plus notifications, background tasks, permissions, and build flavors. Auth is backed by the **LC Portal API**.

- Flutter **3.44** / Dart **3.12**. Package name: `pnestaffapp`, applicationId `com.pneunited.pnestaffapp`.

## Commands
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # injectable + json + gen-l10n + envied
flutter analyze            # MUST stay at 0 issues (very_good_analysis, strict)
flutter test
flutter run --flavor dev -t lib/main_dev.dart              # Android (flavor required)
flutter run -t lib/main_dev.dart -d <ios-device-id>       # iOS (NO --flavor; see Gotchas)
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install            # run inside ios/ (UTF-8 needed on Ruby 4.0)
flutterfire configure       # optional: enables FCM (regenerates lib/firebase_options.dart)
```
Codegen must be re-run after changing anything annotated with `@injectable`, `@JsonSerializable`, `envied`, or the `.arb` files.

## Tech stack (by concern)
- **State:** flutter_bloc, hydrated_bloc, bloc_concurrency, equatable
- **DI:** get_it + injectable
- **Routing:** go_router (auth-guarded, adaptive shell)
- **Network:** dio (+ dio_smart_retry, pretty_dio_logger), connectivity_plus
- **FP/errors:** fpdart (`Either`), sealed `Failure`/`AppException`
- **Storage:** flutter_secure_storage, shared_preferences, hive_ce
- **Theming:** design tokens + `ThemeExtension` + google_fonts
- **Notifications:** firebase_messaging (FCM) + flutter_local_notifications + timezone
- **Background:** workmanager
- **Permissions:** permission_handler
- **Codegen:** build_runner, freezed, json_serializable, injectable_generator, envied, go_router_builder
- **Test:** bloc_test, mocktail, alchemist (golden)

## Architecture (feature-first clean architecture)
```
lib/
├── app/                 # bootstrap, root widget (PneStaffApp), BlocObserver
├── core/
│   ├── config/          # Flavor/FlavorConfig, envied (Env)
│   ├── di/              # injection.dart (getIt, configureDependencies) + register_module
│   ├── network/         # ApiClient(Dio), interceptors, dio_error_mapper, api_envelope, network_info
│   ├── storage/         # SecureStorageService, PreferencesService(KeyValueStorage), TokenStorage
│   ├── notifications/   # NotificationService (local+FCM), channels, NotificationRouter (deep-links)
│   ├── background/      # BackgroundTaskService, callbackDispatcher, BackgroundTasks (ids)
│   ├── permissions/     # PermissionService
│   ├── router/          # AppRouter (go_router), app_routes, GoRouterRefreshStream
│   ├── theme/           # tokens/, AppTheme, ThemeCubit/State, presets, AppColorsX extension
│   ├── responsive/      # Breakpoints, ResponsiveValue, AdaptiveNavShell/TwoPane
│   ├── error/ result/   # exceptions.dart, failures.dart, error_mapper, Result/guardAsync
│   ├── extensions/ constants/ utils/ widgets/
├── features/<feature>/{data,domain,presentation}
└── l10n/                # gen-l10n (app_en.arb, English only)
```
Dependency rule: `presentation → domain ← data`. Repositories return `FutureResult<T>` = `Future<Either<Failure, T>>`.

## Conventions (follow these)
- **DI:** annotate with `@injectable` / `@LazySingleton(as: Interface)`. `build.yaml` **auto-registers** classes whose names end in `Service|Repository|Impl|Bloc|Cubit|UseCase|DataSource` — so also-annotating those is fine but pick the right binding. `FlavorConfig` is registered **manually** in `bootstrap` *before* `configureDependencies(env)`; the Dio module reads it via `gh<FlavorConfig>()` (a build-time "unregistered type" warning is expected and harmless). Third-party singletons live in `core/di/register_module.dart`.
- **State/events:** plain `Equatable` classes (NOT freezed). Persisted state uses `HydratedCubit` (e.g. `ThemeCubit`). `copyWith` uses an `_unset` sentinel for nullable fields.
- **Errors:** data sources throw sealed `AppException`; repositories wrap calls in `guardAsync(() async {...})` which maps to `Failure` via `error_mapper.dart`. `dio_error_mapper.dart` turns `DioException` → `AppException`. UI shows `failure.message`; 422s carry `fieldErrors`.
- **Network:** `ApiClient` (get/post/put/patch/delete) returns the decoded body; base URL from `FlavorConfig`. `AuthInterceptor` attaches `Authorization: Bearer <token>`. **LC Portal responses are enveloped** `{success,message,data}` — unwrap with `ApiEnvelope.dataMap(body)` in data sources.
- **Storage:** tokens → `TokenStorage` (secure); non-sensitive → `KeyValueStorage`; keys centralized in `StorageKeys`.
- **Theming:** never hardcode colors/sizes — use `Theme.of`/`context.colorScheme`/`context.textTheme`, `context.colors` (AppColorsX), and tokens in `core/theme/tokens` (`AppSpacing`, `AppRadii`, `AppElevation`). Restyle via `ThemeCubit`.
- **Responsive:** use `context.isPhone/isTablet`, `context.breakpoint`, `ResponsiveValue`, `AdaptiveNavShell`, `AdaptiveTwoPane`. Constrain wide content (e.g. forms `maxWidth: 440`).
- **Routing:** `AppRouter` (`@lazySingleton`). Route constants in `app_routes.dart`. Auth redirect reads `AuthBloc.state`; `refreshListenable` = `GoRouterRefreshStream(authBloc.stream)`. Notification taps deep-link via `NotificationRouter`.
- **i18n:** English only via gen-l10n. Add keys to `lib/l10n/app_en.arb`, use `context.l10n.<key>`. `generate: true` in pubspec.
- **Imports:** package imports. Lint = very_good_analysis with `comment_references` and `sort_pub_dependencies` disabled.

## Flavors & environments
`dev` / `staging` / `prod` → `lib/main_<flavor>.dart` → `bootstrap(FlavorConfig.<flavor>())`. Android product flavors (with `applicationIdSuffix` `.dev`/`.staging`) + `manifestPlaceholders["appName"]`.
- **Base URLs:** dev & staging → `https://authtesting.lcportal.cloud/api/v1`; prod → `https://auth.lcportal.cloud/api/v1`.

## Auth — LC Portal API (EMPLOYEE auth)
The app authenticates **employees** (not portal Users). JWT `bearerAuth`; envelope `{ success, message, data }`, **snake_case**. **Single bearer token** (Sanctum `id|hash` in `data.token`, `token_type:"Bearer"`); **no refresh token** — the `AuthInterceptor` does single-flight 401 → `/auth/refresh-token` → retry, else clears the session (`SessionExpiredNotifier`) and the router redirects to login. Login sends a `device` object + `fcm_token`.

Endpoints (relative to `/api/v1`):
| Method | Path | Auth | Body | data |
|---|---|---|---|---|
| POST | `/auth/employee/login` | public | `employee_id:int, password, client_type:"mobile", device{device_id,platform,model,os_version,app_version}, fcm_token?` | `{ token, token_type, employee }` |
| POST | `/auth/employee/logout` | bearer | — | — |
| GET | `/auth/employee/me` | bearer | — | `{ employee }` |
| POST | `/auth/refresh-token` | bearer | — | `{ token, token_type }` |
| POST | `/auth/forgot-password` | public | `email` | — (email OTP) |
| POST | `/auth/reset-otp-verify` | public | `email, otp` | — |
| POST | `/auth/reset-password` | public | `email, otp, password, password_confirmation` | — |

`employee` (FullEmployee): `id:int, first_name, middle_name?, last_name, full_name, active, global_roles[], all_permissions[], stores[]` (`EmployeeStoreMembership{store_number, status?, active, effective_date?}`). **No email, no avatar, no self-update.** App `Employee` entity flattens roles/permissions to `List<String>`. `device` from `DeviceInfoService` (device_info_plus + package_info_plus); `fcm_token` from `StorageKeys.fcmToken`.
Error shapes: 401 `{success:false,message}`; 422 `{message, errors:{field:[...]}}`; unauth `{message:"Unauthenticated."}`. Employee endpoints + `FullEmployee` verified live against `authtesting` on 2026-07-17.
UI: **employee-id** Login, Forgot/Reset (email OTP, 3-step — employees reset via email), **read-only** Profile (name/active/roles/stores). No self-signup and **no profile edit** (no employee update endpoint). NOTE: the email-login (`/auth/login`, `FullUser`) is a *different* actor and is not used by this app.

## Notifications / background / permissions
- **Notifications:** `NotificationService` (local + FCM). Channels `general`/`alerts`/`reminders` (FCM default = `general`). Taps deep-link via `NotificationRouter`. **Firebase is configured** (project `staffapp-d0c7d`) via `lib/firebase_options.dart` (+ `google-services.json` / `GoogleService-Info.plist`); init stays guarded so it degrades gracefully. Push init is **non-blocking** (runs over the UI). A real **FCM token needs a real device**: iOS needs an APNs key in Firebase + `aps-environment` (the iOS *simulator* returns `apns-token-not-set`); Android needs Google Play Services. `fcm_token` is best-effort at login.
- **Background:** `workmanager`; `callbackDispatcher` is a top-level `@pragma('vm:entry-point')`. iOS task ids in `BackgroundTasks` must match `Info.plist` `BGTaskSchedulerPermittedIdentifiers` + `AppDelegate` registrations (module `workmanager_apple`).
- **Permissions:** `PermissionService` over permission_handler; Android manifest + iOS `Info.plist` usage strings already declared.

## Gotchas (bit us before)
- **flutter_local_notifications v22** → ALL named params: `initialize(settings:)`, `show(id:,title:,body:,notificationDetails:,payload:)`, `zonedSchedule(id:,scheduledDate:,notificationDetails:,androidScheduleMode:)`, `cancel(id:)`.
- **flutter_timezone v5** → `getLocalTimezone()` returns `TimezoneInfo`; use `.identifier`.
- **Android:** minSdk 24 (Firebase ≥23); core library desugaring enabled (`desugar_jdk_libs 2.1.4`).
- **iOS build/run (learned the hard way):** the **Runner** deployment target must be **15.0** in `project.pbxproj` (Firebase + `workmanager_apple` need it — the Podfile only bumps the pods). **SPM is disabled** for this project (`flutter config --no-enable-swift-package-manager`) because `workmanager_apple` has no Swift Package Manager support and it also confuses scheme selection. iOS has **no flavor build-configs** yet, so run it as `flutter run -t lib/main_dev.dart` (NO `--flavor`); Android uses `--flavor dev`. On this machine's Homebrew **Ruby 4.0.1**, run `pod install` / `flutter run` with `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8` or CocoaPods throws `Encoding::CompatibilityError`; the `ffi` "extensions not built" warning is cosmetic. Verified running on the iPhone 17 simulator on 2026-07-03.
- **workmanager:** `initialize(isInDebugMode:)` is deprecated/removed — call `initialize(callbackDispatcher)`.
- **google_fonts** downloads fonts at runtime (offline first-launch falls back to system).
- **Firebase native:** the `com.google.gms.google-services` Gradle plugin is intentionally **NOT** applied — `firebase_options.dart` drives init, and the plugin would fail on the `.dev`/`.staging` `applicationIdSuffix` (Firebase is registered only for the base package). Register per-flavor Firebase apps if you want the plugin.
- **Android emulator (this machine):** the `Pixel_9a` AVD's system image was incomplete (`system.img` missing) → "No initial system image". Reinstall with `sdkmanager "system-images;android-36;google_apis_playstore;arm64-v8a"`.
- Python has no CA certs on this machine — use `curl` (or an unverified SSL context) for API probing.

## Testing
`flutter analyze` (0 issues) + `flutter test`. Blocs via bloc_test + mocktail. Live auth testing hits `authtesting.lcportal.cloud`.
