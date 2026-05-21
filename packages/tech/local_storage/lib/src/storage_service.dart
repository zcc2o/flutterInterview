import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) throw StateError('StorageService not initialized');
    return _prefs!;
  }

  Future<bool> setString(String key, String value) => prefs.setString(key, value);
  String? getString(String key) => prefs.getString(key);
  Future<bool> setInt(String key, int value) => prefs.setInt(key, value);
  int? getInt(String key) => prefs.getInt(key);
  Future<bool> setBool(String key, bool value) => prefs.setBool(key, value);
  bool? getBool(String key) => prefs.getBool(key);
  Future<bool> remove(String key) => prefs.remove(key);
  Set<String> getKeys() => prefs.getKeys();
  Future<bool> clear() => prefs.clear();
}
