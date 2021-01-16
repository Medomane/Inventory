import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'Helpers/func.dart';
import 'Helpers/drawer.dart';
import 'Helpers/http.dart';
import 'Models/User.dart';

class Problem extends StatefulWidget {
  @override
  _ProblemState createState() => _ProblemState();
}
class _ProblemState extends State<Problem>{
  Widget _drawer ;
  TextEditingController _subject ,_message ;
  RoundedLoadingButtonController _btnController ;
  bool _subjectError, _messageError;
  GlobalKey<ScaffoldState> _scaffoldKey ;

  _ProblemState(){
    _btnController = new RoundedLoadingButtonController();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _subject = TextEditingController();
    _message = TextEditingController();
    _subjectError = _messageError = false;
    _drawer = Divider(color: Colors.transparent,height: 0);
  }

  @override
  void initState() {
    super.initState();
    _initUrl();
  }
  _initUrl() {
    Future.microtask(() async {
      var user = await User.get();
      setState(() {
        _drawer = AppDrawer(user);
      });
    });
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
      drawer: _drawer,
      body: ListView(
        padding: EdgeInsets.fromLTRB(5,0,5,10),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(30,15,30,15),
            child: Image(image: AssetImage('images/prob.png',),),
          ),
          TextField(
            controller: _subject,
            decoration: InputDecoration(
              errorText: _subjectError?"Champs obligatoire":null,
              suffixIcon: Icon(Icons.link),
              border: OutlineInputBorder(),
              labelText: 'Objet :',
            ),
          ),
          SizedBox(height: 15.0),
          TextField(
            controller: _message,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            minLines: 10,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Message :',
              suffixIcon: Icon(Icons.message),
              errorText: _messageError?"Champs obligatoire":null,
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
      _subjectError = Func.isNull(_subject.text);
      _messageError = Func.isNull(_message.text);
    });
    if(!_subjectError && !_messageError) await Http.sendMsg(_subject.text, _message.text, _scaffoldKey, context, _btnController);
    else await _btnController.stop();
  }
}