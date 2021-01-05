import 'dart:convert';

import 'package:Inventory/Helpers/global.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:http/http.dart' as http;

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
  @override
  void initState(){
    super.initState();
    _initUrl();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  /*Future<void> _validate() async {
    setState(() {
      serverUrlFieldError = Func.isNull(serverUrlField.text);
    });
    if(!serverLinkError){
      var link = Uri.parse(serverLink.text);
      var baseUrl = link.scheme+'://'+link.host;
      if(link.hasPort) baseUrl += ":${link.port}";
      if(await Func.checkConnection(_btnController)){
        http.get(Uri.encodeFull(baseUrl)).timeout(Duration(seconds: 10)).then((value) async {
          if (value.statusCode == 200) {
            Map<String,dynamic> res = jsonDecode(value.body);
            if(res["Type"].toString() == "success") {
              await MyGlobal.setServerUrl(baseUrl);
              _btnController.success();
              Future.delayed(Duration(seconds: 5)).then((v) async {
                _btnController.stop();
              });
              return ;
            }
            else Func.errorToast("Erreur !!!");
          }
          else Func.errorToast("Erreur ${value.statusCode} !!!");
          _btnController.stop();
        }).catchError((error){
          Func.errorToast(error.toString());
          _btnController.stop();
        });
      }
      else await _btnController.stop();
    }
    else await _btnController.stop();
  }*/
  /*Future<void> _setUrl() async {
    if(!Func.isNull(link.text)){
      if(await Func.checkConnection()){
        setState(() {
          _isButtonDisabled = true;
        });
        http.get(Uri.encodeFull(link.text)).then((value) async {
          if (value.statusCode == 200) {
            Map<String,dynamic> res = jsonDecode(value.body);
            if(res["Type"].toString() == "success") {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("serverUrl", link.text);
              Navigator.of(context).pop('Cancel');
            }
            else Func.errorToast("Erreur !!!");
          }
          else Func.errorToast("Erreur ${value.statusCode} !!!");
          setState(() {
            _isButtonDisabled = false;
          });
        }).catchError((error){
          Func.errorToast(error.toString());
          setState(() {
            _isButtonDisabled = false;
          });
        });
      }
    }
  }*/
  Future<void> _initUrl() async {
    serverUrlField.text = await MyGlobal.getServerUrl();
  }

  Future<void> _setUrl() async {
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
              await _btnController.success();
              Future.delayed(Duration(seconds: 5)).then((v) async {
                await _btnController.stop();
              });
              return ;
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