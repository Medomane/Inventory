import 'package:Inventory/Helpers/prefs.dart';
import 'package:fl_chart/fl_chart.dart';

import '../Helpers/sqlite.dart';

import 'User.dart';
import 'Item.dart';

class Product{
  int id;
  double quantity;
  DateTime date;
  int userId;
  int itemId;

  static Future<int> add(double qte,int itemId) async => SqLite.insert("insert into product (quantity,item_id,user_id) values ($qte,$itemId,${(await Prefs.getUserId())})");
  static Future<int> delete(int id) async => SqLite.delete("DELETE FROM product where id = $id");

  static Future<double> getMemberSum() async  {
    var res = (await SqLite.select('SELECT sum(quantity) sum FROM product where user_id = ${(await Prefs.getUserId())} group by user_id'));
    return (res.length <= 0) ? 0 :res[0]["sum"];
  }
  static Future<double> getGroupSum() async {
    var user = await User.get();
    var res = (await SqLite.select('SELECT sum(quantity) sum FROM product INNER JOIN user ON product.user_id = user.id where team_id = ${user.teamId} group by team_id'));
    return (res.length <= 0) ? 0 :res[0]["sum"];
  }


  static Future<List<FlSpot>> getLine() async {
    var res = await SqLite.select("select date(date) date, sum(quantity) quantity from product where user_id = ${(await Prefs.getUserId())} group by date(date)");
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
    var res = await SqLite.select(''' SELECT m.id,m.username, ifnull(sum(quantity),0) quantity FROM user m left JOIN product p ON p.user_id = m.id
    where team_id = (select team_id from user where id = ${(await Prefs.getUserId())}) group by m.id,m.username ''');
    return res;
  }

  Future<User> user() async => await User.get(id: userId);
  Future<Item> item() async => await Item.get(itemId);

  static Future<Product> get(int id) async {
    var data = await SqLite.select("SELECT * FROM product WHERE id = $id");
    if(data.length <= 0) return null;
    var res = data[0];
    var team = new Product();
    team.id = id;
    team.quantity = res["quantity"];
    team.date = DateTime.parse(res["date"]);
    team.userId = res["userId"];
    team.itemId = res["itemId"];
    return team;
  }
}