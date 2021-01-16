import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'Helpers/func.dart';
import 'Helpers/drawer.dart';
import 'Helpers/sqlite.dart';
import 'Models/Item.dart';
import 'Models/Product.dart';
import 'Models/User.dart';

enum ItemAction{
  Scanner,
  ShowDetail,
  Inventory
}

class ItemPage extends StatefulWidget {
  final int id ;
  final String code;
  final ItemAction action;

  ItemPage({this.id,this.code,this.action});

  @override
  _ItemPageState createState() => _ItemPageState(id: id,code: code,action: action);
}

class _ItemPageState extends State<ItemPage>{
  int id ;
  String code;
  bool _isLoading ,_notFound;
  ItemAction action;
  Widget _drawer ;
  Item currentItem;
  User user ;
  TextEditingController quantityField ;
  GlobalKey<ScaffoldState> _scaffoldKey ;
  _ItemPageState({this.id,this.code,this.action}){
    _drawer = Divider(color: Colors.transparent,height: 0);
    _isLoading = true;
    _notFound = false;
    quantityField = TextEditingController();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }
  _initData() async {
    setState(() => _isLoading = true);
    Future.microtask(() async {
      String query;
      user = await User.get();
      if(!Func.isNull('$id') && id > 0) query = 'select * from item where id = $id ';
      else if(!Func.isNull(code)) query = '''select * from item where code = '$code' ''';
      if(query != null){
        var res = await SqLite.select(query);
        if(res.length > 0) {
          currentItem = await Item.get(res[0]["id"]);
          _notFound = false;
        }
        else _notFound = true;
      }
      else _notFound = true;
      _drawer = AppDrawer(user);
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !Func.isNull('$id')?Text("Détail de l'article : $id"):!Func.isNull('$code')?Text("Détail de l'article : $code"):Text("Détail"),
      ),
      drawer: _drawer,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(5),
          child: _isLoading?Center(child: CircularProgressIndicator(),): _notFound?Center(child: Text("Pas d'information"),):Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: getData(context)
          ),
        )
      ),
      floatingActionButton: (action == ItemAction.Inventory || action == ItemAction.Scanner)?FloatingActionButton.extended(
          icon: Icon(Icons.scanner),
          onPressed: () => scanQR(),
          label: Text('Scanner')
      ):Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  List<Widget> getData(BuildContext context){
    var list = new List<Widget>();
    list.add(Padding(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: (MediaQuery. of(context).size.height)-100,
        ),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder:(context)=>ImageView(currentItem.image))),
          child: Image(image: currentItem.image),
        ),
      ) ,
      padding: EdgeInsets.all(20),
    ));
    list.add(SizedBox(height: 15.0));
    list.add(Card(child: new ListTile(title: new Text("Référence"), subtitle: new Text(currentItem.reference), trailing: Icon(Icons.account_balance_wallet))));
    list.add(Card(child: new ListTile(title: new Text("Désignation"), subtitle: new Text(currentItem.designation), trailing: Icon(Icons.textsms_rounded))));
    list.add(Card(child: new ListTile(title: new Text("Code"), subtitle: new Text(currentItem.code), trailing: Icon(Icons.code))));
    list.add(Card(child: new ListTile(title: new Text("Famille"), subtitle: new Text(currentItem.family), trailing: Icon(Icons.family_restroom))));
    list.add(Card(child: new ListTile(title: new Text("N°Lot/Serie"), subtitle: new Text(currentItem.num), trailing: Icon(Icons.info))));
    list.add(Card(child: new ListTile(title: new Text("En stock"), subtitle: new Text(currentItem.inStock.toString()), trailing: Icon(Icons.move_to_inbox))));
    list.add(Card(child: new ListTile(title: new Text("Prix de vente"), subtitle: new Text(currentItem.sellingPrice.toString()), trailing: Icon(Icons.money))));
    if(Item.showBuyingPrice(user)) list.add(Card(child: new ListTile(title: new Text("Prix d'achat"), subtitle: new Text(currentItem.buyingPrice.toString()), trailing: Icon(Icons.money))));
    if(action == ItemAction.Inventory){
      list.add(Card(
        child: TextField(
          controller: quantityField,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Quantité',
            suffixIcon: IconButton(
                icon: Icon(Icons.check_circle),
                onPressed: () => sendQte(quantityField.text)
            ),
          ),
          onSubmitted: (qte) => sendQte(qte),
          keyboardType: TextInputType.number,
        ),
      ));
      list.add(SizedBox(height: 70.0));
    }
    else if(action == ItemAction.Scanner) list.add(SizedBox(height: 70.0));
    return list;
  }
  @override
  void dispose() {
    super.dispose();
  }
  Future<void> sendQte(String val) async {
    if(!Func.isNull(val)){
      var pr = new ProgressDialog(context,isDismissible: false);
      try{
        var qte = double.parse(val.replaceAll(',', '.'));
        pr.style(message: "Ajout ...");
        await pr.show();
        await Product.add(qte, currentItem.id);
        await pr.hide();
        await Fluttertoast.showToast(msg: "Opération s'est déroulée avec succès",toastLength:Toast.LENGTH_LONG);
      }
      catch(ex){
        await Func.showError(_scaffoldKey,ex.toString(),pd: pr);
      }
    }
  }

  Future scanQR() async{
    String barcodeScanRes;
    try {
      barcodeScanRes = await Func.scan(context);
      if (!mounted) return;
      code = barcodeScanRes;
      id = null;
      _initData();
    } catch(e) {
      print(e.toString());
    }
  }
}

class ImageView extends StatefulWidget {
  final img;
  ImageView(this.img);
  @override
  _ImageViewState createState() => _ImageViewState(img);
}
class _ImageViewState extends State<ImageView>{
  final img;
  _ImageViewState(this.img);

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      imageProvider: img,
    );
  }
}