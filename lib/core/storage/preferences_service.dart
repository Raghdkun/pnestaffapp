import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/storage/key_value_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [KeyValueStorage] backed by SharedPreferences. Reads are synchronous because
/// the instance is resolved eagerly at startup (see `RegisterModule`).
@LazySingleton(as: KeyValueStorage)
class PreferencesService implements KeyValueStorage {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<void> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  double? getDouble(String key) => _prefs.getDouble(key);

  @override
  Future<void> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  @override
  bool containsKey(String key) => _prefs.containsKey(key);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();
}
