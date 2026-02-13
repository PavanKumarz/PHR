import '../datasources/settings_database.dart';

class SettingsService {
  static Future<void> save(String key, dynamic value) async {
    await SettingsDatabase.instance.saveSetting(key, value.toString());
  }

  static Future<String?> get(String key) async {
    return await SettingsDatabase.instance.getSetting(key);
  }

  static Future<bool> getBool(String key) async {
    final val = await get(key);
    return val == "true";
  }

  static Future<int> getInt(String key) async {
    final val = await get(key);
    return val != null ? int.parse(val) : 0;
  }

  static Future<void> init() async {}
}
