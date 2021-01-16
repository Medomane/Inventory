import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'prefs.dart';


class MyGlobal{
  static const String dbName = "db.db";
  static const String _dbFolder = "SqLite";
  static const int duration = 5;
  static const maxLength = 20;
  static Future<String> loginUrl() async => (await Prefs.getServerUrl())+"/login";
  static Future<String> downloadUrl() async => (await Prefs.getServerUrl())+"/downloadSqLiteDb";
  static Future<String> uploadUrl() async => (await Prefs.getServerUrl())+"/uploadSqLiteDb";
  static Future<String> reportProbUrl() async => (await Prefs.getServerUrl())+"/reportProb";
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
  static Future<File> getDbFile({bool delete = false}) async => File((await _getRootFolder(delete: delete)).path +'/'+ MyGlobal.dbName);
  static Future<Directory> _getRootFolder({bool delete = false}) async {
    final String _appDocDir = (await getApplicationDocumentsDirectory()).path;
    var dir = Directory('$_appDocDir/${MyGlobal._dbFolder}');
    if(delete){
      if(await dir.exists()) dir = await dir.delete(recursive: true);
      dir = await dir.create();
    }
    else{
      if(!(await dir.exists())) dir = await dir.create();
    }
    return dir;
  }
}