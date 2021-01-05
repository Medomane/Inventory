import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MyGlobal{
  static String dbName = "db.db";
  static String dbFolder = "SqLite";
  //static int duration = 5;
  static Future<String> getServerUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("serverUrl");
  }
  static Future<void> setServerUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("serverUrl",url);
  }

  static Future<void> setInfo(Map<String,dynamic> res) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("userId", res["Content"]["Id"]);
    await prefs.setString("username", res["Content"]["Username"]);
    await prefs.setString("password", res["Content"]["Password"]);
    await prefs.setInt("role", res["Content"]["Role"]);
    await prefs.setInt("teamId", res["Content"]["Team"]["Id"]);
    await prefs.setString("team", res["Content"]["Team"]["Name"]);
    await prefs.setInt("inventoryId", res["Content"]["Team"]["Inventory"]["Id"]);
    await prefs.setString("inventory", res["Content"]["Team"]["Inventory"]["Caption"]);
    print(res);
  }

  static Future<int> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.containsKey("userId") && prefs.getInt("userId") > 0)?prefs.getInt("userId"):0;
  }
  static Future<String> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("username");
  }
  static Future<String> getPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("password");
  }
  static Future<bool> isManager() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("role") == 0;
  }

  static Future<int> getTeamId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("teamId");
  }
  static Future<String> getTeam() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("team");
  }

  static Future<int> getInventoryId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("inventoryId");
  }
  static Future<String> getInventory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("inventory");
  }

  static Future<String> getBasePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("basePath");
  }
  static Future<void> setBasePath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("basePath",path);
  }

  static Future<String> dbPath() async => (await getBasePath()) +'/'+ MyGlobal.dbName;
  static Future<String> loginUrl() async => (await MyGlobal.getServerUrl())+"/login";
  static Future<String> downloadUrl() async => (await MyGlobal.getServerUrl())+"/downloadSqLiteDb";
  static Future<String> syncUrl() async => (await MyGlobal.getServerUrl())+"/syncData";
  static Future<String> reportProbUrl() async => (await MyGlobal.getServerUrl())+"/reportProb";
  //static Future<String> uploadUrl() async => (await MyGlobal.getServerUrl())+"/User/Upload";
  static Future<String> getRoot() async => (await getApplicationDocumentsDirectory()).path;
  static List<Color> colorsList(){
    var list = List<Color>();
    list.add(Colors.orange);
    list.add(Colors.limeAccent);
    list.add(Colors.orangeAccent);
    list.add(Colors.lightBlueAccent);
    list.add(Colors.lightGreen);
    list.add(Colors.deepOrangeAccent);
    list.add(Colors.yellow);
    list.add(Colors.lightGreenAccent);
    list.add(Colors.deepOrange);
    list.add(Colors.lime);
    list.add(Colors.yellowAccent);
    list.add(Colors.lightBlue);
    return list;
  }
}