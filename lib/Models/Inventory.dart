import '../Helpers/sqlite.dart';

class Inventory{
  int id;
  String caption;
  DateTime beginDate;
  DateTime endDate;
  DateTime creationDate;
  bool active;
  //Inventory({this.id,this.caption,this.beginDate,this.endDate,this.creationDate,this.active});
  static Future<Inventory> get(int id) async {
    var data = await SqLite.select("SELECT * FROM inventory WHERE id = $id");
    if(data.length <= 0) return null;
    var res = data[0];
    var inv = new Inventory();
    inv.id = id;
    inv.caption = res["caption"];
    inv.beginDate = DateTime.parse(res["beginDate"]);
    inv.endDate = DateTime.parse(res["endDate"]);
    inv.creationDate = DateTime.parse(res["creationDate"]);
    inv.active = res["active"] == 1;
    return inv;
  }
}