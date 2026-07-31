import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pnestaffapp/core/constants/app_constants.dart';
import 'package:pnestaffapp/core/storage/secure_storage_service.dart';

/// Device metadata sent in the `device` object of the employee login request.
class DeviceMetadata {
  const DeviceMetadata({
    required this.deviceId,
    required this.platform,
    required this.model,
    required this.osVersion,
    required this.appVersion,
  });

  final String deviceId;

  /// `ios` | `android` | `web` (matches the API enum).
  final String platform;
  final String model;
  final String osVersion;
  final String appVersion;

  Map<String, dynamic> toJson() => {
    'device_id': deviceId,
    'platform': platform,
    'model': model,
    'os_version': osVersion,
    'app_version': appVersion,
  };
}

/// Gathers stable device + app metadata via device_info_plus + package_info_plus.
/// `device_id` is `identifierForVendor` on iOS and a persisted UUID on Android
/// (Android no longer exposes a stable hardware id).
@lazySingleton
class DeviceInfoService {
  DeviceInfoService(this._secure);

  final SecureStorageService _secure;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  DeviceMetadata? _cached;

  Future<DeviceMetadata> metadata() async {
    if (_cached != null) return _cached!;

    final package = await PackageInfo.fromPlatform();
    final appVersion = '${package.version}+${package.buildNumber}';

    var platform = 'web';
    var model = 'unknown';
    var osVersion = 'unknown';
    String? vendorId;

    if (Platform.isIOS) {
      final ios = await _deviceInfo.iosInfo;
      platform = 'ios';
      model = ios.utsname.machine;
      osVersion = ios.systemVersion;
      vendorId = ios.identifierForVendor;
    } else if (Platform.isAndroid) {
      final android = await _deviceInfo.androidInfo;
      platform = 'android';
      model = '${android.manufacturer} ${android.model}';
      osVersion =
          'Android ${android.version.release} (SDK ${android.version.sdkInt})';
    }

    return _cached = DeviceMetadata(
      deviceId: await _resolveDeviceId(vendorId),
      platform: platform,
      model: model,
      osVersion: osVersion,
      appVersion: appVersion,
    );
  }

  Future<String> _resolveDeviceId(String? vendorId) async {
    if (vendorId != null && vendorId.isNotEmpty) return vendorId;
    final existing = await _secure.read(StorageKeys.deviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated =
        'app-${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}';
    await _secure.write(StorageKeys.deviceId, generated);
    return generated;
  }
}
