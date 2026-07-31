import 'package:pnestaffapp/app/bootstrap.dart';
import 'package:pnestaffapp/core/config/flavor.dart';

/// Default entry point for `flutter run` (no `--target`). Uses the dev flavor.
/// For real builds prefer the flavored entry points with `--flavor`:
///   flutter run --flavor dev     -t lib/main_dev.dart
///   flutter build apk --flavor prod -t lib/main_prod.dart
Future<void> main() => bootstrap(FlavorConfig.dev());
