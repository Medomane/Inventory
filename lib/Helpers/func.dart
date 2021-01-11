import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Inventory/Helpers/global.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
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

  static Future<File> getDownloadFile({bool delete=true}) async {
    if(delete) await Func.updateBaseFolder();
    String dir = (await MyGlobal.getBasePath());
    return new File('$dir/${MyGlobal.dbName}');
  }
  static Text hTxt(String txt) => Text(txt,style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold));



  //send a message
  static Future<bool> sendMsg(String subject, String message,GlobalKey<ScaffoldState> key,BuildContext context,RoundedLoadingButtonController btn) async {
    if(!await Func.checkConnection(btn)) return false;
    try{
      var obj = '''{
        "UserId":"${(await MyGlobal.getUserId())}",
        "Subject":"'''+subject+'''",
        "Message":"'''+message+'''"
      }''';
      Map<String, String> headers = {"Content-type": "application/json"};
      var response = await http.post(await MyGlobal.reportProbUrl(),body:obj,headers: headers);
      if(response.statusCode == 200) {
        Map<String,dynamic> res = jsonDecode(response.body);
        if(res["Type"].toString() == "error") await Func.showError(key,res["Content"].toString(),btn: btn);
        else {
          await Fluttertoast.showToast(msg: res["Content"].toString());
          await btn.success();
          return true ;
        }
      }
      else await Func.showError(key,'Erreur avec le statut: ${response.statusCode}.',btn: btn);
    }
    catch(er){
      await Func.showError(key,er.toString(),btn: btn);
    }
    return false;
  }
  //set url
  static Future<bool> setUrl(GlobalKey<ScaffoldState> key,String url,BuildContext context,RoundedLoadingButtonController btn) async {
    try{
      if(!await Func.checkConnection(btn)) return false;
      var link = Uri.parse(url);
      var baseUrl = link.scheme+'://'+link.host;
      if(link.hasPort) baseUrl += ":${link.port}";
      var response = await http.get(Uri.encodeFull(baseUrl)).timeout(Duration(seconds: 10));
      if(response.statusCode == 200){
        Map<String,dynamic> res = jsonDecode(response.body);
        if(res["Type"].toString() == "success"){
          await MyGlobal.setServerUrl(baseUrl);
          await endLoading(btnController: btn);
          return true ;
        }
        else await Func.showError(key,res["Content"].toString(),btn: btn);
      }
      else await Func.showError(key,'Erreur avec le statut: ${response.statusCode}.',btn: btn);
    }
    catch(er){
      await Func.showError(key,er.toString(),btn: btn);
    }
    return false;
  }
  //Login
  static Future<Map<String,dynamic>> login(String username, String password,GlobalKey<ScaffoldState> key,BuildContext context,RoundedLoadingButtonController btn) async {
    if(!await Func.checkConnection(btn)) return null;
    try{
      var obj = '''{
        "username":"$username",
        "password":"$password"
      }''';
      var response = await http.post(Uri.encodeFull(await MyGlobal.loginUrl()),body: obj,headers: {"Content-type": "application/json"});
      if(response.statusCode == 200) {
        Map<String,dynamic> res = jsonDecode(response.body);
        if(res["Type"].toString() == "error") await Func.showError(key,res["Content"].toString(),btn: btn);
        else return res ;
      }
      else await Func.showError(key,'Erreur avec le statut: ${response.statusCode}.',btn: btn);
    }
    catch(er){
      await Func.showError(key,er.toString(),btn: btn);
    }
    return null;
  }
  //Upload SqLite Database
  static Future<bool> refreshData(GlobalKey<ScaffoldState> key,BuildContext context,RoundedLoadingButtonController btn) async {
    if(!await Func.checkConnection(btn)) return false;
    var pd = new ProgressDialog(context,isDismissible: false);
    pd.style(maxProgress: 100,progress: 0,message: "Chargement ...");
    await pd.show();
    try{
      final Dio _dio = Dio();
      var file = await getDownloadFile(delete: false);
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path,filename: MyGlobal.dbName)
      });
      var response = await _dio.post(await MyGlobal.syncUrl(),
        data: formData,
        options: Options(
          headers: {"Authorization": "${(await MyGlobal.getUsername())} ${(await MyGlobal.getPassword())}"} // set content-length
        ),
        onSendProgress: (int received, int total){
          if (total == -1) return ;
          if(received == total) pd.update(message:"Mise à jour ...");
          else {
            var progress = "Chargement : " +(received / total * 100).toStringAsFixed(0) + "%";
            pd.update(message:progress);
          }
        }
      );
      if(response.statusCode == 200) {
        await endLoading(pd: pd);
        return await downloadDb(key, context, btn);
      }
      else await Func.showError(key,'Erreur avec le statut: ${response.statusCode}.',pd: pd,btn: btn);
    }
    catch(er){
      await Func.showError(key,er.toString(),pd: pd,btn: btn);
    }
    return false;
  }
  //Download SqLite Database
  static Future<bool> downloadDb(GlobalKey<ScaffoldState> key,BuildContext context,RoundedLoadingButtonController btn) async {
    if(!await Func.checkConnection(btn)) return false;
    var pd = new ProgressDialog(context,isDismissible: false);
    pd.style(maxProgress: 100,progress: 0,message: "Transformation...");
    await pd.show();
    try{
      var file = await getDownloadFile();
      final Dio _dio = Dio();
      final response = await _dio.download(
        await MyGlobal.downloadUrl(),
        file.path,
        onReceiveProgress: (int received, int total){
          if (total != -1) {
            var progress = "Téléchargement : " +(received / total * 100).toStringAsFixed(0) + "%";
            pd.update(message:progress);
          }
        }
      );
      if(response.statusCode == 200) {
        await endLoading(pd: pd,btnController: btn);
        await btn.success();
        return true;
      }
      else await Func.showError(key,'Erreur avec le statut: ${response.statusCode}.',pd: pd,btn: btn);
    }
    catch(er){
      await Func.showError(key,er.toString(),pd: pd,btn: btn);
    }
    return false;
  }
}