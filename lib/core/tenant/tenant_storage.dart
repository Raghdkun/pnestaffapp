import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/constants/app_constants.dart';
import 'package:pnestaffapp/core/storage/key_value_storage.dart';

/// Persists the active tenant root domain and the cached domain allowlist.
/// Non-secret (a domain string, not a credential), so this reads/writes
/// through [KeyValueStorage] rather than secure storage.
@lazySingleton
class TenantStorage {
  TenantStorage(this._prefs);

  final KeyValueStorage _prefs;

  String? readActiveDomain() => _prefs.getString(StorageKeys.tenantActiveDomain);

  Future<void> writeActiveDomain(String domain) =>
      _prefs.setString(StorageKeys.tenantActiveDomain, domain);

  List<String>? readAllowlistCache() {
    final raw = _prefs.getString(StorageKeys.tenantAllowlistCache);
    if (raw == null || raw.isEmpty) return null;
    return raw.split(',').where((e) => e.isNotEmpty).toList();
  }

  Future<void> writeAllowlistCache(List<String> domains) async {
    await _prefs.setString(StorageKeys.tenantAllowlistCache, domains.join(','));
    await _prefs.setInt(
      StorageKeys.tenantAllowlistCachedAt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  DateTime? readAllowlistCachedAt() {
    final millis = _prefs.getInt(StorageKeys.tenantAllowlistCachedAt);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }
}
