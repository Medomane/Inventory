import 'package:Inventory/Helpers/global.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'Helpers/func.dart';
import 'Helpers/drawer.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting>{
  final serverUrlField = TextEditingController();
  bool serverUrlFieldError = false;
  final RoundedLoadingButtonController _btnController = new RoundedLoadingButtonController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState(){
    super.initState();
    _initUrl();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Paramètres"),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(0),
              constraints: BoxConstraints(
                maxHeight: (MediaQuery. of(context).size.height)-160,
              ),
              child: Card(
                elevation: 1,
                shadowColor: Colors.black,
                clipBehavior: Clip.none,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TextField(
                        controller: serverUrlField,
                        decoration: InputDecoration(
                          errorText: serverUrlFieldError?"Champs obligatoire":null,
                          suffixIcon: Icon(Icons.link),
                          border: OutlineInputBorder(),
                          labelText: 'Lien de serveur',
                        ),
                      ),
                    ],
                  ),
                )
              ),
            ),
            RoundedLoadingButton(
              child: Text("Valider", style: TextStyle(color: Colors.white)),
              controller: _btnController,
              onPressed: (){
                _setUrl();
              }
            )
          ]
        )
      )
    );
  }
  Future<void> _initUrl() async {
    serverUrlField.text = await MyGlobal.getServerUrl();
  }

  Future<void> _setUrl() async {
    setState(() {
      serverUrlFieldError = Func.isNull(serverUrlField.text);
    });
    if(!serverUrlFieldError) await Func.setUrl(_scaffoldKey, serverUrlField.text, context, _btnController);
    else await Func.endLoading(btnController: _btnController);
  }
}