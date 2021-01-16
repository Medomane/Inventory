import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_table/DatatableHeader.dart';
import 'package:responsive_table/responsive_table.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'Helpers/func.dart';
import 'Helpers/drawer.dart';
import 'Helpers/global.dart';
import 'Helpers/http.dart';
import 'Helpers/prefs.dart';
import 'Helpers/sqlite.dart';
import 'Models/User.dart';

class SyncPage extends StatefulWidget {
  @override
  _SyncPageState createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage>{
  List<Map<String, dynamic>> _source ;
  RoundedLoadingButtonController _btnController ;
  GlobalKey<ScaffoldState> _scaffoldKey ;
  Widget _drawer ;
  bool _isLoading = true;

  _SyncPageState(){
    _source = List<Map<String, dynamic>>();
    _btnController = new RoundedLoadingButtonController();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _drawer = Divider(color: Colors.transparent,height: 0);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Synchronisation"),
      ),
      drawer: _drawer,
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: (MediaQuery. of(context).size.height)-150,
          ),
          child: ResponsiveDatatable(
            headers: headers(context),
            source: _source,
            autoHeight: false,
            isLoading: _isLoading,
          ),
        )
      ),
      floatingActionButton: RoundedLoadingButton(
          child: Text("Synchroniser", style: TextStyle(color: Colors.white)),
          controller: _btnController,
          onPressed: (){
            synchronize();
          }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  @override
  void initState() {
    super.initState();
    _init();
  }
  void _init(){
    setState(() => _isLoading = true);
    Future.microtask(() async {
      _source.clear();
      var user = await User.get();
      var query = 'SELECT * FROM synchronization WHERE user_id = ${user.id} order by date';
      var data = await SqLite.select(query);
      _source.addAll(data);
      _drawer = AppDrawer(user);
      setState(() => _isLoading = false);
    });
  }
  @override
  void dispose() {
    super.dispose();
  }
  List<DatatableHeader> headers(context){
    List<DatatableHeader> _headers = [
      DatatableHeader(
          text: "id",
          value: "id",
          show: false
      ),
      DatatableHeader(
        value: "date",
        sourceBuilder: (value, row) {
          final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
          final String formatted = formatter.format(DateTime.parse(value));
          return Text(formatted);
        },
        headerBuilder: (value) => Func.hTxt("Date")
      ),
      DatatableHeader(
        value: "state",
        show: false,
        sourceBuilder: (value, row) {
          var val = value.toInt();
          return Text(val == 0?"Succès":val == 1?"Erreur":"Echoue");
        },
        headerBuilder: (value) => Func.hTxt("Type")
      ),
      DatatableHeader(
        value: "message",
        headerBuilder: (value) => Func.hTxt("Message")
      ),
    ];
    return _headers;
  }
  void synchronize() async {
    if(await Http.refreshData(_scaffoldKey, context, _btnController)){
      await Func.endLoading(btnController: _btnController);
      _init();
    }
  }
}