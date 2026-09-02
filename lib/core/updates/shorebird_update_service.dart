import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/utils/app_logger.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Silent over-the-air updates (Shorebird code push).
///
/// Behaviour: a patch is downloaded **silently in the background** and applied
/// the **next time the app launches** — the user is never prompted or
/// interrupted. Shorebird's native updater already checks once at startup; this
/// service adds a check on every app *resume* so long-lived sessions still pick
/// up patches, and centralizes logging/patch reporting.
///
/// Everything is guarded by [isAvailable], which is false in debug/profile and
/// in non-Shorebird builds (e.g. plain `flutter run`), so this is a safe no-op
/// during development.
@lazySingleton
class ShorebirdUpdateService {
  ShorebirdUpdateService(this._logger);

  final AppLogger _logger;
  final ShorebirdUpdater _updater = ShorebirdUpdater();

  /// Guards against overlapping checks (launch + resume can race).
  bool _checking = false;

  /// True only in a Shorebird-released build.
  bool get isAvailable => _updater.isAvailable;

  /// The currently running patch number, or null when on the base release.
  /// Useful as a crash-reporting tag.
  Future<int?> currentPatchNumber() async {
    if (!isAvailable) return null;
    try {
      final patch = await _updater.readCurrentPatch();
      return patch?.number;
    } on Object catch (e, s) {
      _logger.w('Could not read current patch', error: e, stackTrace: s);
      return null;
    }
  }

  /// Checks for a new patch and, if one exists, downloads it in the background.
  /// The patch becomes active on the next app launch. Never throws.
  Future<void> checkForUpdate() async {
    if (!isAvailable || _checking) return;
    _checking = true;
    try {
      final status = await _updater.checkForUpdate();
      switch (status) {
        case UpdateStatus.outdated:
          _logger.i('Shorebird: patch available — downloading silently');
          await _updater.update();
          _logger.i('Shorebird: patch downloaded — applies on next launch');
        case UpdateStatus.restartRequired:
          _logger.i('Shorebird: patch staged — applies on next launch');
        case UpdateStatus.upToDate:
          _logger.d('Shorebird: up to date');
        case UpdateStatus.unavailable:
          _logger.d('Shorebird: updater unavailable');
      }
    } on UpdateException catch (e, s) {
      // Expected in the field (offline, no patch for this release, etc.).
      _logger.w('Shorebird update skipped: ${e.message}', stackTrace: s);
    } on Object catch (e, s) {
      _logger.w('Shorebird update failed', error: e, stackTrace: s);
    } finally {
      _checking = false;
    }
  }
}
