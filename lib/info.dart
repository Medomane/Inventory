import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Helpers/drawer.dart';
import 'Models/User.dart';

class Information extends StatefulWidget {
  @override
  _InformationState createState() => _InformationState();
}

class _InformationState extends State<Information> {
  Widget _drawer ;
  List<Widget> _list;

  _InformationState(){
    _drawer = Divider(color: Colors.transparent,height: 0);
    _list = List<Widget>();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      var user = await User.get();
      _list = await getData(user);
      setState(() {
        _drawer = AppDrawer(user);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Informations"),
      ),
      drawer: _drawer,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(5),
          child: _list.length <= 0 ? Center(child: CircularProgressIndicator()) :Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _list
          ),
        )
      ),
    );
  }

  Future<List<Widget>> getData(User user) async{
    var list = new List<Widget>();
    list.add(Padding(
      child: Image(image: user.avatar,) ,
      padding: EdgeInsets.all(20),
    ));
    list.add(SizedBox(height: 15.0));
    list.add(Card(child: ListTile(title: Text("Nom d'utilisateur"), subtitle: Text(user.username), trailing: Icon(Icons.subject))));
    list.add(Card(child: ListTile(title: Text("Type"), subtitle: Text(user.isNormal()?"Normal":"Membre"), trailing: Icon(Icons.merge_type))));
    list.add(Card(child: ListTile(title: Text("Role"), subtitle: Text(user.role()), trailing: Icon(Icons.flag))));
    if(!user.isNormal()){
      var team = await user.team();
      var inv = await team.inventory();
      var formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      list.add(Card(child: ListTile(title: Text("Inventaire"), subtitle: Text(inv.caption), trailing: Icon(Icons.inventory))));
      list.add(Card(child: ListTile(title: Text("Du"), subtitle: Text(formatter.format(inv.beginDate)), trailing: Icon(Icons.not_started))));
      list.add(Card(child: ListTile(title: Text("Au"), subtitle: Text(formatter.format(inv.endDate)), trailing: Icon(Icons.close))));
      list.add(Card(child: ListTile(title: Text("Equipe"), subtitle: Text(team.name), trailing: Icon(Icons.people))));
    }
    return list;
  }
}