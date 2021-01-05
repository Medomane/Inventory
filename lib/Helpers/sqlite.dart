import 'package:fl_chart/fl_chart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import 'global.dart';

class SqLite {
  static Future<List<Map<String, dynamic>>> select(String query) async {
    Database _db = await openDatabase(await MyGlobal.dbPath());
    List<Map> list = await _db.rawQuery(query);
    await _db.close();
    _db = null;
    return list;
  }
  static Future<Map> info() async {
    var res = await select('''SELECT i.caption inventory, i.beginDate, i.endDate,t.name team, m.username, m.role, m.team_id,t.inventory_id 
    FROM Inventory i, Team t, Member m WHERE i.id = t.inventory_id AND t.id = m.team_id AND m.id = ${(await MyGlobal.getUserId())}''');
    return res[0];
  }
  static Future<int> saveProduct(double qte, int itemId) async {
    Database _db = await openDatabase(await MyGlobal.dbPath());
    var id = await _db.rawInsert("insert into Product (quantity,item_id,member_id) values ($qte,$itemId,${(await MyGlobal.getUserId())})");
    await _db.close();
    _db = null;
    return id;
  }
  static Future<void> deleteProduct(int id) async {
    Database _db = await openDatabase(await MyGlobal.dbPath());
    await _db.rawDelete("DELETE FROM Product where id = ?",[id]);
    await _db.close();
    _db = null;
  }
  static Future<List<FlSpot>> getLine() async {
    var res = await select("select date(date) date, sum(quantity) quantity from Product where member_id = ${(await MyGlobal.getUserId())} group by date(date)");
    //CAST(strftime('%s', date) AS DOUBLE)
    var data = List<FlSpot>();
    double zero = 0;
    if (res.length <= 0) data.add(FlSpot(zero, zero));
    double i = 1;
    for (var t in res) {
      data.add(FlSpot(i, t["quantity"]));
      i++;
      //data.add(FlSpot(t['date'], t["quantity"]));
    }
    return data;
  }
  static Future<List<Map<String, dynamic>>> getPieData() async {
    var res = await select(''' SELECT m.id,m.username, ifnull(sum(quantity),0) quantity FROM Member m left JOIN Product p ON p.member_id = m.id
    where team_id = (select team_id from member where id = ${(await MyGlobal.getUserId())}) group by m.id,m.username ''');
    return res;
  }
  static Future<void> freeDb() async {
    var db = await openDatabase(await MyGlobal.dbPath());
    await db.execute("VACUUM");
    db.close();
    db = null;
  }
  static Future<double> getMemberSum() async  {
    var res = (await select('SELECT sum(quantity) sum FROM product where member_id = ${(await MyGlobal.getUserId())} group by member_id'));
    return (res.length <= 0) ? 0 :res[0]["sum"];
  }
  static Future<double> getGroupSum() async {
    var res = (await select('SELECT sum(quantity) sum FROM product INNER JOIN member ON product.member_id = member.id where team_id = ${(await MyGlobal.getTeamId())} group by team_id'));
    return (res.length <= 0) ? 0 :res[0]["sum"];
  }
  //static Color getRandomColor() => MyGlobal.colorsList()[Random().nextInt(MyGlobal.colorsList().length - 0)];
}