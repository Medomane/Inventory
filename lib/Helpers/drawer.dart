import 'package:flutter/material.dart';

import '../home.dart';
import '../info.dart';
import '../itemDetail.dart';
import '../items.dart';
import '../prob.dart';
import '../setting.dart';
import '../stock.dart';
import '../synch.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(),
          _createDrawerItem(icon: Icons.home, text: 'Accueil',context: context,widget: MyHome()),
          Divider(height: 0,color: Colors.blue,),
          _createDrawerItem(icon: Icons.account_circle, text: 'Profil',context: context,widget: Information()),
          Divider(height: 0,color: Colors.blue,),
          _createDrawerItem(icon: Icons.article, text: 'Articles',context: context,widget: Items()),
          Divider(height: 0,color: Colors.blue,),
          _createDrawerItem(icon: Icons.scanner, text: 'Scanner un article',context: context,widget: Item(null,true)),
          Divider(height: 0,color: Colors.blue,),
          _createDrawerItem(icon: Icons.inventory, text: 'Inventaire',context: context,widget: Item(null,true)),
          Divider(height: 0,color: Colors.blue,),
          _createDrawerItem(icon: Icons.move_to_inbox_sharp, text: 'Stocks',widget: StockPage(),context: context),
          Divider(height: 0,color: Colors.blue,),
          _createDrawerItem(icon: Icons.sync, text: 'Synchronisation',context: context,widget: SyncPage()),
          Divider(height: 0,color: Colors.blue,),
          _createDrawerItem(icon: Icons.settings, text: 'Paramètres',context: context,widget: Setting()),
          Divider(color: Colors.blue,height: 0,),
          _createDrawerItem(icon: Icons.bug_report, text: 'Signaler un problème',context: context,widget: Problem()),
        ],
      ),
    );
  }
  Widget _createHeader() {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image:  AssetImage('images/bg.png')
        )
      ), child: null,
    );
  }
  Widget _createDrawerItem({IconData icon, String text, BuildContext context,StatefulWidget widget}) {
    return ListTile(
      title: Text( text, style: TextStyle(fontSize: 16) ),
      trailing: Icon(icon),
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => widget))
    );
  }
}