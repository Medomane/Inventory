import 'dart:convert';

import 'package:Inventory/Helpers/global.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:http/http.dart' as http;

import 'Helpers/func.dart';
import 'Helpers/drawer.dart';

class Problem extends StatefulWidget {
  @override
  _ProblemState createState() => _ProblemState();
}
class _ProblemState extends State<Problem>{
  final subject = TextEditingController();
  final message = TextEditingController();
  final RoundedLoadingButtonController _btnController = new RoundedLoadingButtonController();
  bool subjectError = false,messageError = false;
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Problème"),
      ),
      drawer: AppDrawer(),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20,0,20,10),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(30,15,30,15),
            child: Image(image: AssetImage('images/prob.png',),),
          ),
          TextField(
            controller: subject,
            decoration: InputDecoration(
              errorText: subjectError?"Champs obligatoire":null,
              suffixIcon: Icon(Icons.link),
              border: OutlineInputBorder(),
              labelText: 'Objet :',
            ),
          ),
          SizedBox(height: 15.0),
          TextField(
            controller: message,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            minLines: 10,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Message :',
              suffixIcon: Icon(Icons.message),
              errorText: messageError?"Champs obligatoire":null,
            ),
          ),
          SizedBox(height: 15.0),
          RoundedLoadingButton(
              child: Text("Valider", style: TextStyle(color: Colors.white)),
            controller: _btnController,
            onPressed: (){
              _validate();
            }
          )
        ],
      )
    );
  }
  Future<void> _validate() async {
    setState(() {
      subjectError = Func.isNull(subject.text);
      messageError = Func.isNull(message.text);
    });
    if(!subjectError && !messageError){
      if(!(await Func.checkConnection(_btnController))) return ;
      var url = await MyGlobal.reportProbUrl();
      print(url);
      var obj = '''{
        "UserId":"${(await MyGlobal.getUserId())}",
        "Subject":"'''+subject.text.trim()+'''",
        "Message":"'''+message.text.trim()+'''"
      }''';
      Map<String, String> headers = {"Content-type": "application/json"};
      http.post(url,body:obj,headers: headers).then(
        (value) async {
          if (value.statusCode == 200) {
            Map<String,dynamic> res = jsonDecode(value.body);
            if(res["Type"].toString() == "error") {
              await _btnController.stop();
              Func.errorToast(res["Content"].toString());
            }
            else {
              Fluttertoast.showToast(msg: res["Content"].toString());
              await _btnController.success();
            }
          }
          else {
            await _btnController.stop();
            Func.errorToast('Erreur avec le statut: ${value.statusCode}.');
            print(value.reasonPhrase);
          }
        }
      ).catchError((error) async {
        await _btnController.stop();
        Func.errorToast(error.toString());
      });
    }
    else await _btnController.stop();
  }
}