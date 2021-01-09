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
          padding: EdgeInsets.all(5),
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
      var val = v,title = "" ;
      bool add = true;
      Icon trail  ;
      switch(k){
        case "inventory" :
          title = "Inventaire";
          trail = Icon(Icons.inventory);
        break;
        case "beginDate" :
          title = "Du";
          trail = Icon(Icons.not_started);
          break;
        case "endDate" :
          title = "Au";
          trail = Icon(Icons.close);
          break;
        case "team" :
          title = "Equipe";
          trail = Icon(Icons.people);
        break;
        case "username" :
          title = "Nom d'utilisateur";
          trail = Icon(Icons.subject);
          break;
        case "role" :
          title = "Role";
          val = v == 0?"Résponsable":"Member";
          trail = Icon(Icons.flag);
        break;
        default : add = false;
      }
      if(add) list.add(Card(
          child: ListTile(
            title: Text(title),
            subtitle: Text(val),
            trailing: trail,
          ),
        ));
    });
    return list;
  }
}