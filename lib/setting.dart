import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'Helpers/func.dart';
import 'Helpers/drawer.dart';
import 'Helpers/http.dart';
import 'Helpers/prefs.dart';
import 'Models/User.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting>{
  TextEditingController serverUrlField ;
  bool serverUrlFieldError ;
  RoundedLoadingButtonController _btnController ;
  GlobalKey<ScaffoldState> _scaffoldKey ;
  Widget _drawer ;

  _SettingState(){
    _btnController = new RoundedLoadingButtonController();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _drawer = Divider(color: Colors.transparent,height: 0);
    serverUrlField = TextEditingController();
    serverUrlFieldError = false;
  }
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
      drawer: _drawer,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: (MediaQuery. of(context).size.height)-140,
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
  _initUrl() {
    Future.microtask(() async {
      serverUrlField.text = await Prefs.getServerUrl();
      var user = await User.get();
      setState(() {
        _drawer = AppDrawer(user);
      });
    });
  }

  Future<void> _setUrl() async {
    setState(() {
      serverUrlFieldError = Func.isNull(serverUrlField.text);
    });
    if(!serverUrlFieldError) await Http.setUrl(_scaffoldKey, serverUrlField.text, context, _btnController);
    else await Func.endLoading(btnController: _btnController);
  }
}