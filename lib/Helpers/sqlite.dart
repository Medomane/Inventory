import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import 'global.dart';

class SqLite {
  static Future<List<Map<String, dynamic>>> select(String query) async {
    Database _db = await openDatabase((await MyGlobal.getDbFile()).path);
    List<Map> list = await _db.rawQuery(query);
    await _db.close();
    _db = null;
    return list;
  }
  static Future<int> insert(String query) async {
    Database _db = await openDatabase((await MyGlobal.getDbFile()).path);
    var id = await _db.rawInsert(query);
    await _db.close();
    _db = null;
    return id;
  }
  static Future<int> update(String query) async {
    Database _db = await openDatabase((await MyGlobal.getDbFile()).path);
    var nbr = await _db.rawUpdate(query);
    await _db.close();
    _db = null;
    return nbr;
  }
  static Future<int> delete(String query) async {
    Database _db = await openDatabase((await MyGlobal.getDbFile()).path);
    var nbr = await _db.rawDelete(query);
    await _db.close();
    _db = null;
    return nbr;
  }
  static Future<void> freeDb() async {
    var db = await openDatabase((await MyGlobal.getDbFile()).path);
    await db.execute("VACUUM");
    db.close();
    db = null;
  }
}