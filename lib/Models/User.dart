import 'package:Inventory/Helpers/prefs.dart';

import '../Helpers/sqlite.dart';
import 'package:flutter/widgets.dart';

import 'Team.dart';

class User{
  int id;
  String username;
  String password;
  DateTime creationDate;
  int _role;
  String type;
  String uniqueId;
  dynamic avatar;
  int teamId;
  Future<Team> team() async => await Team.get(teamId);
  bool isNormal() => type == "normal";
  static Future<User> get({int id=-1}) async {
    var data = await SqLite.select("SELECT * FROM user WHERE id = ${(id <= 0)?await Prefs.getUserId():id}");
    if(data.length <= 0) return null;
    var res = data[0];
    var user = new User();
    user.id = res["id"];
    user.username = res["username"];
    user.password = res["password"];
    user.creationDate = DateTime.parse(res["creationDate"]);
    user._role = res["role"];
    user.type = res["type"];
    user.avatar = res["avatar"] == null ?AssetImage('images/avatar.png'):MemoryImage(res["avatar"]);
    user.teamId = res["team_id"];
    return user;
  }
  String role(){
    String tmp ;
    if(isNormal()){
      if(_role == 0) tmp = "Administrateur";
      else tmp = "Utilisateur";
    }
    else{
      if(_role == 0) tmp = "Résponsable";
      else tmp = "Membre";
    }
    return tmp;
  }
  NormalRole normalRole() => NormalRole.values[_role];
  MemberRole memberRole() => MemberRole.values[_role];
  //dynamic role() => (type == "normal")?NormalRole.values[_userRole]:MemberRole.values[_userRole];
}
enum NormalRole {
  Admin,
  User
}

enum MemberRole {
  Manager,
  Member
}