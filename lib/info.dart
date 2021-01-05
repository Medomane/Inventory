import 'package:flutter/material.dart';

import 'Helpers/drawer.dart';
import 'Helpers/sqlite.dart';

class Information extends StatefulWidget {
  @override
  _InformationState createState() => _InformationState();
}

class _InformationState extends State<Information> {
  var data;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Informations"),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: getData()
          ),
        )
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      var res = await SqLite.info();
      setState(() {
        data = res;
      });
    });
  }

  List<Widget> getData(){
    var list = new List<Widget>();
    list.add(Padding(
      child: Image.asset('images/inv1.png') ,
      padding: EdgeInsets.all(20),
    ));
    list.add(SizedBox(height: 15.0));
    if(data == null) return list ;
    data.forEach((k,v) {
      var val = v ;
      bool add = true;
      var title = "" ;
      switch(k){
        case "inventory" : title = "Inventaire";break;
        case "beginDate" : title = "Du";break;
        case "endDate" : title = "Au";break;
        case "team" : title = "Equipe";break;
        case "username" : title = "Nom d'utilisateur";break;
        case "role" :
          title = "Role";
          val = v == 0?"Résponsable":"Member";
        break;
        default : add = false;
      }
      if(add) list.add(Card(
          child: new ListTile(
            title: new Text(title),
            subtitle: new Text(val),
          ),
        ));
    });
    return list;
  }
}