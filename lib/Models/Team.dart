import '../Helpers/sqlite.dart';
import './Inventory.dart';

class Team {
  int id;
  String name;
  int inventoryId;
  Future<Inventory> inventory() async => await Inventory.get(inventoryId);

  static Future<Team> get(int id) async {
    var data = await SqLite.select("SELECT * FROM team WHERE id = $id");
    if(data.length <= 0) return null;
    var res = data[0];
    var team = new Team();
    team.id = id;
    team.name = res["name"];
    team.inventoryId = res["inventory_id"];
    return team;
  }
}