import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'home.dart';
import 'Helpers/prefs.dart';
import 'Helpers/func.dart';
import 'Helpers/global.dart';
import 'Helpers/http.dart';

void main() => runApp(MaterialApp( home: MyLogin(), ));

class MyLogin extends StatefulWidget {
  @override
  _MyLoginState createState() {
    WidgetsFlutterBinding.ensureInitialized();
    return _MyLoginState();
  }
}

class _MyLoginState extends State<MyLogin> {
  final usernameField = TextEditingController();
  final passwordField = TextEditingController();
  final serverUrlField = TextEditingController();
  bool usernameFieldError = false,passwordFieldError = false,serverUrlFieldError = false,urlDone=false;
  final RoundedLoadingButtonController _btnController = new RoundedLoadingButtonController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      var userId = await Prefs.getUserId();
      if(userId != null && userId > 0) await Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MyHome()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _getBody()
          ),
        )
      )
    );
  }

  Future<void> _login(BuildContext context) async {
    if(urlDone){
      setState(() {
        usernameFieldError = Func.isNull(usernameField.text);
        passwordFieldError = Func.isNull(passwordField.text);
      });
      if(!usernameFieldError && !passwordFieldError){
        int id = await Http.login(usernameField.text, passwordField.text.split(' ')[0], _scaffoldKey, context, _btnController);
        if(id > 0){
          if(await Http.downloadDb(_scaffoldKey,context, _btnController)){
            _btnController.success();
            Future.delayed(Duration(seconds: MyGlobal.duration), () async {
              await Prefs.setUserId(id);
              await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => MyHome()));
            });
          }
        }
      }
      else await Func.endLoading(btnController: _btnController);
    }
    else{
      setState(() {
        serverUrlFieldError = Func.isNull(serverUrlField.text);
      });
      if(!serverUrlFieldError){
        if(await Http.setUrl(_scaffoldKey, serverUrlField.text, context, _btnController)){
          setState(() {
            urlDone = true;
          });
        }
      }
      else await Func.endLoading(btnController: _btnController);
    }
  }
  List<Widget> _getBody(){
    var list = List<Widget>();
    list.add(Padding(
      child: Image.asset('images/inventory.jpg'),
      padding: EdgeInsets.all(20),
    ));
    if(urlDone){
      list.add(TextField(
        controller: usernameField,
        decoration: InputDecoration(
          errorText: usernameFieldError?"Champs obligatoire":null,
          hintText: 'Nom d\'utilisateur',
          suffixIcon: Icon(Icons.supervised_user_circle),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ));
      list.add(SizedBox(height: 15.0,));
      list.add(TextField(
        controller: passwordField,
        obscureText: true,
        decoration: InputDecoration(
          errorText: passwordFieldError?"Champs obligatoire":null,
          hintText: 'Mot de passe',
          suffixIcon: Icon(Icons.enhanced_encryption),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ));
    }
    else list.add(TextField(
      controller: serverUrlField,
      decoration: InputDecoration(
        errorText: serverUrlFieldError?"Champs obligatoire":null,
        hintText: 'Url de serveur',
        suffixIcon: Icon(Icons.link),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    ));
    list.add(SizedBox(height: 15.0,));
    list.add(RoundedLoadingButton(
        child: Text(urlDone?'Se connecter':'Valider', style: TextStyle(color: Colors.white)),
        controller: _btnController,
        onPressed: (){_login(context);}
    ));
    return list;
  }
}