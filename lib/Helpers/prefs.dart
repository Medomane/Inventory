import 'func.dart';

class Prefs{
  static Future<String> getServerUrl() async {
    var prefs = await Func.getPrefs();
    return prefs.getString("serverUrl");
  }
  static Future<void> setServerUrl(String url) async {
    var prefs = await Func.getPrefs();
    await prefs.setString("serverUrl",url);
  }

  static Future<int> getUserId() async {
    var prefs = await Func.getPrefs();
    return prefs.getInt("userId");
  }
  static Future<void> setUserId(int id) async {
    var prefs = await Func.getPrefs();
    return prefs.setInt("userId",id);
  }
}