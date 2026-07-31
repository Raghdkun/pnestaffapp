/// Abstraction over non-sensitive key/value persistence (backed by
/// SharedPreferences). Sensitive data (tokens) uses [SecureStorageService].
abstract interface class KeyValueStorage {
  String? getString(String key);
  Future<void> setString(String key, String value);

  bool? getBool(String key);
  Future<void> setBool(String key, {required bool value});

  int? getInt(String key);
  Future<void> setInt(String key, int value);

  double? getDouble(String key);
  Future<void> setDouble(String key, double value);

  bool containsKey(String key);
  Future<void> remove(String key);
  Future<void> clear();
}
