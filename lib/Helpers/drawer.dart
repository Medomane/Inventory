import 'package:flutter/material.dart';

import '../home.dart';
import '../info.dart';
import '../itemDetail.dart';
import '../items.dart';
import '../main.dart';
import '../prob.dart';
import '../setting.dart';
import '../stock.dart';
import '../synch.dart';
import '../Models/User.dart';
import 'func.dart';

class AppDrawer extends StatelessWidget {
  final User user;
  AppDrawer(this.user);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: getList(context, user),
      ),
    );
  }

  static Widget _createHeader(User user) {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image:  AssetImage('images/bg.png')
        )
      ),
      child: Center(
        child: CircleAvatar(radius: 50,backgroundImage: user.avatar)
      ),
    );
  }
  static Widget _createDrawerItem(IconData icon, String text, BuildContext context,{StatefulWidget widget,Function func}) {
    return ListTile(
      title: Text( text, style: TextStyle(fontSize: 16) ),
      trailing: Icon(icon),
      onTap: widget != null ? () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => widget)) : func
    );
  }

  static List<Widget> getList(BuildContext context,User user){
    List<Widget> list = new List<Widget>();
    list.add(_createHeader(user));
    list.add(_createDrawerItem(Icons.home, 'Accueil',context,widget: MyHome()));
    list.add(Divider(height: 0,color: Colors.blue,));
    list.add(_createDrawerItem(Icons.account_circle, 'Profil',context,widget: Information()));
    list.add(Divider(height: 0,color: Colors.blue,));
    list.add(_createDrawerItem(Icons.article, 'Articles',context,widget: Items()));
    list.add(Divider(height: 0,color: Colors.blue,));
    list.add(_createDrawerItem(Icons.scanner, 'Scanner un article',context,widget: ItemPage(action: ItemAction.Scanner)));
    if(!user.isNormal()){
      list.add(Divider(height: 0,color: Colors.blue,));
      list.add(_createDrawerItem(Icons.inventory, 'Inventaire',context,widget: ItemPage(action: ItemAction.Inventory)));
      list.add(Divider(height: 0,color: Colors.blue,));
      list.add(_createDrawerItem(Icons.move_to_inbox_sharp, 'Stocks',context,widget: StockPage()));
      list.add(Divider(height: 0,color: Colors.blue,));
      list.add(_createDrawerItem(Icons.sync, 'Synchronisation',context,widget: SyncPage()));
    }
    list.add(Divider(height: 0,color: Colors.blue,));
    list.add(_createDrawerItem(Icons.settings, 'Paramètres',context,widget: Setting()));
    list.add(Divider(color: Colors.blue,height: 0,));
    list.add(_createDrawerItem(Icons.bug_report, 'Signaler un problème',context,widget: Problem()));
    list.add(Divider(color: Colors.blue,height: 0,));
    list.add(_createDrawerItem(Icons.logout, 'Se déconnecter',context,func: (){logOut(user,context);}));
    return list;
  }

  static void logOut(User user,BuildContext context){
    Future.microtask(() async {
      if(!user.isNormal()){
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("Vous allez perdre les données non synchronisé !!!"),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      "Annuler",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text(
                      "Continuer",
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () async {
                      await Func.clearPrefs();
                      Navigator.of(context).pop();
                      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MyLogin()));
                    },
                  ),
                ],
              );
            }
        );
      }
      else{
        await Func.clearPrefs();
        await Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MyLogin()));
      }
    });
  }
}