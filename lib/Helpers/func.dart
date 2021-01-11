import 'dart:async';
import 'dart:io';

import 'package:Inventory/Helpers/global.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'scannerView.dart';


class Func{
  static bool isNumeric(String s) {
    if(s == null) return false;
    return double.parse(s, (e) => null) != null;
  }
  static Future<void> showError(GlobalKey<ScaffoldState> key,String error,{RoundedLoadingButtonController btn,ProgressDialog pd}) async {
    key.currentState.showSnackBar(SnackBar(
      duration: const Duration(seconds: 30),
      content: Text(error),
      backgroundColor: Colors.red,
    ));
    if(btn != null) await btn.stop();
    if(pd != null) await pd.hide();
  }
  static void _errorToast(String content) => Fluttertoast.showToast(msg: content,backgroundColor: Colors.red,textColor: Colors.white,toastLength:Toast.LENGTH_LONG );
  static bool isNull(String val) => val == null || val.trim() == "" || val.trim() == "null";
  static Future<void> updateBaseFolder() async {
    final String _appDocDir = await MyGlobal.getRoot();
    final Directory _appDocDirFolder =  Directory('$_appDocDir/${MyGlobal.dbFolder}');
    if(await _appDocDirFolder.exists()) await _appDocDirFolder.delete(recursive: true);
    final Directory _appDocDirNewFolder = await _appDocDirFolder.create();
    await MyGlobal.setBasePath(_appDocDirNewFolder.path);
  }
  /*static Future<List<FileSystemEntity>> _dirContents(Directory dir) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = dir.list(recursive: false);
    lister.listen ((file) => files.add(file), onDone:   () => completer.complete(files));
    return completer.future;
  }*/
  /*static Future<void> allFiles() async {
    var dir =Directory(await MyGlobal.getBasePath());
    var files =await Func.dirContents(dir);
    for(var f in files){
      try{
        print(f.path);
      }
      catch(e){print(e.toString());}
    }
  }*/
  static Future<bool> checkConnection(RoundedLoadingButtonController btn) async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool res ;
    if (connectivityResult == ConnectivityResult.mobile) res = await _checkInternet();
    else if (connectivityResult == ConnectivityResult.wifi) res = true ;
    else res = await _checkInternet();
    if(!res) btn.stop();
    return res ;
  }
  static Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) return true;
    } on SocketException catch (_) {
      _errorToast("Pas de connexion !!!");
      return false;
    }
    return true;
  }
  static String trimEnd(String str,String c) => str[str.length-1] == c?str.substring(0, str.length - 1):str;
  /*static Future<bool> downloadDb(String body,int statusCode, RoundedLoadingButtonController _btnController,{ProgressDialog pd}) async {
    if (statusCode == 200) {
      Map<String,dynamic> res = jsonDecode(body);
      if(res["Type"].toString() == "error") Func.errorToast(res["Content"].toString());
      else {
        try{
          print(res);
          /*await Func.updateBaseFolder();
          await FlutterDownloader.enqueue(
              url: res["Content"]["path"],
              savedDir: (await MyGlobal.getBasePath()),
              showNotification: false,
              openFileFromNotification: false,
              fileName: MyGlobal.dbName
          );
          await FlutterDownloader.loadTasks();
          await _btnController.stop();
          if(pd != null) await pd.hide();*/
          //int userId = res["Content"]["userId"];
          //await MyGlobal.setUserId(userId);
          await _btnController.stop();
          return true;
        }
        catch(ex){
          Func.errorToast(ex.toString());
        }
      }
    }
    else Func.errorToast('Erreur avec le statut: $statusCode.');
    await _btnController.stop();
    if(pd != null) await pd.hide();
    return false;
  }*/

  static Future<String> scan(BuildContext context) async {
    return await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => QRCodeView()));
  }

  static Future<void> endLoading({ProgressDialog pd,RoundedLoadingButtonController btnController}) async {
    if(btnController != null) await btnController.stop();
    if(pd != null) await pd.hide();
  }

  static Future<bool> downloadDb(GlobalKey<ScaffoldState> key,{RoundedLoadingButtonController btn,ProgressDialog pd}) async {
    try{
      await Func.updateBaseFolder();
      var httpClient = new HttpClient();
      httpClient.connectionTimeout = Duration(hours: 1);
      var request = await httpClient.getUrl(Uri.parse(await MyGlobal.downloadUrl()));
      var response = await request.close();
      response.timeout(Duration(hours: 1));
      var bytes = await consolidateHttpClientResponseBytes(response);
      String dir = (await MyGlobal.getBasePath());
      File file = new File('$dir/${MyGlobal.dbName}');
      await file.writeAsBytes(bytes);
      return true;
    }
    catch(er){
      Func.showError(key,er.toString());
      return false;
    }
  }
  static Text hTxt(String txt) => Text(txt,style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold));
}