import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:qrscan/qrscan.dart' as scanner;

import 'Helpers/func.dart';
import 'Helpers/drawer.dart';
import 'Helpers/sqlite.dart';

class Item extends StatefulWidget {
  final id;
  final bool isScanner;
  Item(this.id,this.isScanner);
  @override
  _ItemState createState() => _ItemState(id,isScanner);
}

class _ItemState extends State<Item>{
  var id,data;
  bool isScanner;
  bool _isLoading = true,_notFound = false;
  final quantityField = TextEditingController();
  _ItemState(this.id,this.isScanner);
  @override
  Widget build(BuildContext context) {
    double padding = 20;
    return Scaffold(
      appBar: AppBar(
        title: Text("Détail de l'article : $id"),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: _isLoading?Center(child: CircularProgressIndicator(),): _notFound?Center(child: Text("Pas d'information"),):Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: getData()
          ),
        )
      ),
      floatingActionButton: !isScanner?Container():FloatingActionButton.extended(
          icon: Icon(Icons.scanner),
          onPressed: () => scanQR(),
          label: Text('Scanner')
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }
  _initData() async {
    setState(() => _isLoading = true);
    Future.delayed(Duration(seconds: 1)).then((value) async {
      var query = '''select * from item where id = '$id' ''';
      var res = await SqLite.select(query);
      if(res.length > 0) {
        data = res[0];
        _notFound = false;
      }
      else _notFound = true;
      setState(() => _isLoading = false);
    });
  }
  List<Widget> getData(){
    var list = new List<Widget>();
    list.add(Padding(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: (MediaQuery. of(context).size.height)-100,
        ),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder:(context)=>ImageView(data["icon"] == null ?AssetImage('images/inventory.jpg',):MemoryImage(data["icon"])))),
          child: data["icon"] == null ?Image.asset('images/inventory.jpg',):Image.memory(data["icon"]),
        ),
      ) ,
      padding: EdgeInsets.all(20),
    ));
    list.add(SizedBox(height: 15.0));
    data.forEach((k,v) {
      bool add = true;
      var title = "" ;
      switch(k){
        case "reference" : title = "Référence";break;
        case "designation" : title = "Désignation";break;
        case "code" : title = "Code";break;
        case "family" : title = "Famille";break;
        case "num" : title = "N°Lot/Serie";break;
        default : add = false;
      }
      if(add)
        list.add(Card(
          child: new ListTile(
            title: new Text(title),
            subtitle: new Text(v),
          ),
        ));
    });
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
    list.add(SizedBox(height: 50.0));
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
        await pr.show();
        await SqLite.saveProduct(qte, data["id"]);
        await pr.hide();
        await Fluttertoast.showToast(msg: "Opération s'est déroulée avec succès",toastLength:Toast.LENGTH_LONG);
      }
      catch(ex){
        pr.hide();
        Func.errorToast(ex.toString());
      }
    }
  }

  Future scanQR() async{
    String barcodeScanRes;
    try {
      barcodeScanRes = await scanner.scan();
      if (!mounted) return;
      print("done");
      id = barcodeScanRes;
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