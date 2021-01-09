import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:responsive_table/DatatableHeader.dart';
import 'package:responsive_table/responsive_table.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'Helpers/func.dart';
import 'Helpers/drawer.dart';
import 'Helpers/global.dart';
import 'Helpers/sqlite.dart';

class SyncPage extends StatefulWidget {
  @override
  _SyncPageState createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage>{
  List<Map<String, dynamic>> _source = List<Map<String, dynamic>>();
  final RoundedLoadingButtonController _btnController = new RoundedLoadingButtonController();
  bool _isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Synchronisation"),
      ),
      drawer: AppDrawer(),
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
    Future.delayed(Duration(seconds: 1)).then((value) async {
      _source.clear();
      var query = 'SELECT * FROM synchronization WHERE member_id = ${(await MyGlobal.getUserId())} order by date';
      var data = await SqLite.select(query);
      _source.addAll(data);
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
    if(!(await Func.checkConnection(_btnController))) return ;
    var pr = new ProgressDialog(context,isDismissible: false);
    await pr.show();
    await SqLite.freeDb();
    final uploader = FlutterUploader();
    await uploader.enqueue(
      url: await MyGlobal.syncUrl(),
      files: [FileItem(filename: MyGlobal.dbName, savedDir: (await MyGlobal.getBasePath()), fieldname:"file")],
      method: UploadMethod.POST,
      headers: {"Authorization": "${(await MyGlobal.getUsername())} ${(await MyGlobal.getPassword())}"},
      showNotification: false
    );
    uploader.result.listen((event) async {
      if(event.statusCode == 200){
        if(await Func.downloadDb()){
          _btnController.success();
          Future.delayed(const Duration(seconds: 5), () async {
            await Func.endLoading(btnController: _btnController,pd: pr);
            await Fluttertoast.showToast(msg: "Opération s'est déroulée avec succès",toastLength:Toast.LENGTH_LONG);
            _init();
          });
        }
        else await Func.endLoading(btnController: _btnController);
      }
      else Func.errorToast('Erreur avec le statut: ${event.statusCode}.');
    },onError: (e) async {
      await Func.endLoading(btnController: _btnController,pd: pr);
      Func.errorToast(e.toString());
    });
  }
}