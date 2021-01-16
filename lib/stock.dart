import 'Helpers/drawer.dart';
import 'Helpers/prefs.dart';
import 'Helpers/sqlite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'Models/Product.dart';
import 'Models/User.dart';
import 'itemDetail.dart';

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}
class _StockPageState extends State<StockPage>{
  List<Map<String, dynamic>> _source ;
  bool _isLoading ;
  Widget _drawer ;
  _StockPageState(){
    _source = List<Map<String, dynamic>>();
    _isLoading = true;
    _drawer = Divider(color: Colors.transparent,height: 0);
  }
  _initData() async {
    setState(() => _isLoading = true);
    Future.microtask(() async {
      _source.clear();
      var user = await User.get();
      var query = '''SELECT p.id,p.quantity,p.date,i.code item,p.item_id FROM product p, item i 
      WHERE p.item_id = i.id and p.user_id = ${user.id} order by date DESC''';
      var data = await SqLite.select(query);
      _source.addAll(data);
      _drawer = AppDrawer(user);
      setState(() => _isLoading = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock"),
      ),
      drawer: _drawer,
      body: _isLoading?Center(child: CircularProgressIndicator()):SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: (MediaQuery. of(context).size.height)-90,
          ),
          child: ListView.builder(
            itemCount: _source.length,
            itemBuilder:(context, index) {
              final item = _source[index];
              final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
              final String formatted = formatter.format(DateTime.parse(item['date']));
              return Card(
                child: Dismissible(
                  background: slideRightBackground(),
                  secondaryBackground: slideLeftBackground(),
                  key: Key('${item['item_id']}'),
                  child: ListTile(
                    title: Text('Quantité : ${item['quantity']}'),
                    subtitle: Text('Date : '+formatted),
                    trailing: Text('${item['item']}'),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder:(context)=>ItemPage(action: ItemAction.ShowDetail,id: item["item_id"],))),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      final bool res = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text("Voulez-vous supprimer cet élément ?"),
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
                                  "Supprimer",
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () async {
                                  await Product.delete(item["id"]);
                                  setState(() {
                                    _source.removeAt(index);
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        }
                      );
                      return res;
                    }
                    else {
                      Navigator.push(context, MaterialPageRoute(builder:(context)=>ItemPage(action: ItemAction.ShowDetail,id: item["item_id"])));
                      return false;
                    }
                  },
                ),
              );
            },
          )
        ),
      )
    );
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.article_rounded,
              color: Colors.white,
            ),
            Text(
              " Article",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }
  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Supprimer",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }
}