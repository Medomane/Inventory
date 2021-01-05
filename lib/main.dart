import 'dart:async';
import 'dart:convert';

import 'package:Inventory/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'Helpers/func.dart';
import 'Helpers/global.dart';

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

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      var userId = await MyGlobal.getUserId();
      if(userId > 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MyHome()));
    });
  }

  @override
  Widget build(BuildContext context) {
    //Func.endLoading(btnController: _btnController);
    return Scaffold(
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
        if(!await Func.checkConnection(_btnController)) return ;
        var obj = '''{
          "username":"${usernameField.text.trim()}",
          "password":"${passwordField.text.trim()}"
        }''';
        http.post(Uri.encodeFull(await MyGlobal.loginUrl()),body: obj,headers: {"Content-type": "application/json"}).then(
          (value) async {
            if(value.statusCode == 200){
              Map<String,dynamic> res = jsonDecode(value.body);
              if(res["Type"].toString() == "error") Func.errorToast(res["Content"].toString());
              else {
                if(await Func.downloadDb()){
                  _btnController.success();
                  Future.delayed(const Duration(seconds: 5), () async {
                    await MyGlobal.setInfo(res);
                    await Func.endLoading(btnController: _btnController);
                    await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => MyHome()));
                  });
                }
                else await Func.endLoading(btnController: _btnController);
              }
            }
            else Func.errorToast('Erreur avec le statut: ${value.statusCode}.');
          }
        ).catchError((error) async {
          await Func.endLoading(btnController: _btnController);
          Func.errorToast("Erreur.");
          print(error.toString());
        });
      }
      else await Func.endLoading(btnController: _btnController);
    }
    else{
      setState(() {
        serverUrlFieldError = Func.isNull(serverUrlField.text);
      });
      if(!serverUrlFieldError){
        if(!await Func.checkConnection(_btnController)) return ;
        var link = Uri.parse(serverUrlField.text);
        var baseUrl = link.scheme+'://'+link.host;
        if(link.hasPort) baseUrl += ":${link.port}";
        http.get(Uri.encodeFull(baseUrl)).timeout(Duration(seconds: 10)).then(
          (value) async {
            if (value.statusCode == 200) {
              Map<String,dynamic> res = jsonDecode(value.body);
              if(res["Type"].toString() == "success") {
                await MyGlobal.setServerUrl(baseUrl);
                setState(() {
                  urlDone = true;
                });
              }
              else Func.errorToast("Erreur !!!");
            }
            else Func.errorToast("Erreur ${value.statusCode} (${value.reasonPhrase})!!!");
            await Func.endLoading(btnController: _btnController);
          }
        ).catchError((error) async {
          Func.errorToast("Erreur.");
          await Func.endLoading(btnController: _btnController);
          print(error.toString());
        });
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