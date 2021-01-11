import 'Helpers/drawer.dart';
import 'Helpers/global.dart';
import 'Helpers/sqlite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'itemDetail.dart';

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}
class _StockPageState extends State<StockPage>{
  List<Map<String, dynamic>> _source = List<Map<String, dynamic>>();
  bool _isLoading = true;

  _initData(String str) async {
    setState(() => _isLoading = true);
    Future.delayed(Duration(seconds: 1)).then((value) async {
      _source.clear();
      var query = '''SELECT p.id,p.quantity,p.date,i.code item,p.item_id FROM Product p, Item i 
      WHERE p.item_id = i.id and p.member_id = ${(await MyGlobal.getUserId())} order by date DESC''';
      var data = await SqLite.select(query);
      _source.addAll(data);
      setState(() => _isLoading = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _initData(null);
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
      drawer: AppDrawer(),
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
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder:(context)=>Item(item["item_id"],false))),
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
                                  await SqLite.deleteProduct(item["id"]);
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
                      Navigator.push(context, MaterialPageRoute(builder:(context)=>Item(item["item_id"],false)));
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