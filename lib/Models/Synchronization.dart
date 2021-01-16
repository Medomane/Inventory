import '../Helpers/sqlite.dart';
import 'User.dart';

class Synchronization
{
  int id;
  DateTime date;
  String message;
  int userId;
  Future<User> user() async => await User.get(id: userId);

  static Future<Synchronization> get(int id) async {
    var data = await SqLite.select("SELECT * FROM synchronization WHERE id = $id");
    if(data.length <= 0) return null;
    var res = data[0];
    var sync = new Synchronization();
    sync.id = id;
    sync.date = DateTime.parse(res["date"]);
    sync.message = res["message"];
    sync.userId = res["userId"];
    return sync;
  }
}