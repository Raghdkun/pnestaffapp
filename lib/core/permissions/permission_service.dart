import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

/// App-facing permission identifiers. Keeps the rest of the app decoupled from
/// permission_handler's platform-specific [Permission] set.
enum AppPermission {
  notifications,
  camera,
  microphone,
  photos,
  storage,
  locationWhenInUse,
  locationAlways,
}

/// Wrapper over permission_handler with a small, intention-revealing surface:
/// check status, request (single or many), and jump to system settings when a
/// permission is permanently denied.
@lazySingleton
class PermissionService {
  Future<PermissionStatus> status(AppPermission permission) =>
      _resolve(permission).status;

  Future<bool> isGranted(AppPermission permission) async {
    final status = await _resolve(permission).status;
    return _isEffectivelyGranted(status);
  }

  /// Requests [permission]; returns `true` if granted (or limited/provisional,
  /// which are "granted enough" for iOS photos/notifications).
  Future<bool> request(AppPermission permission) async {
    final status = await _resolve(permission).request();
    return _isEffectivelyGranted(status);
  }

  Future<Map<AppPermission, bool>> requestMany(
    List<AppPermission> permissions,
  ) async {
    final result = <AppPermission, bool>{};
    for (final permission in permissions) {
      result[permission] = await request(permission);
    }
    return result;
  }

  /// True when the user chose "Don't ask again" / disabled it in settings —
  /// the UI should then route them to [openSettings].
  Future<bool> isPermanentlyDenied(AppPermission permission) =>
      _resolve(permission).isPermanentlyDenied;

  Future<bool> openSettings() => openAppSettings();

  bool _isEffectivelyGranted(PermissionStatus status) =>
      status.isGranted || status.isLimited || status.isProvisional;

  Permission _resolve(AppPermission permission) => switch (permission) {
    AppPermission.notifications => Permission.notification,
    AppPermission.camera => Permission.camera,
    AppPermission.microphone => Permission.microphone,
    AppPermission.photos => Permission.photos,
    AppPermission.storage => Permission.storage,
    AppPermission.locationWhenInUse => Permission.locationWhenInUse,
    AppPermission.locationAlways => Permission.locationAlways,
  };
}
