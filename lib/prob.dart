import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

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
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      key: _scaffoldKey,
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
    if(!subjectError && !messageError) await Func.sendMsg(subject.text, message.text, _scaffoldKey, context, _btnController);
    else await _btnController.stop();
  }
}