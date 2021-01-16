import 'package:Inventory/Helpers/global.dart';
import 'package:Inventory/Models/User.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'prefs.dart';
import 'func.dart';
class Http{
  //Login
  static Future<int> login(String username, String password,GlobalKey<ScaffoldState> key,BuildContext context,RoundedLoadingButtonController btn) async {
    if(!await Func.checkConnection(btn)) return null;
    try{
      var response = await Dio().get(Uri.encodeFull(await MyGlobal.loginUrl()),options: Options(headers: {"Authorization": "$username $password"}));
      if(response.statusCode == 200) {
        Map<String,dynamic> res = response.data;
        if(res["Type"].toString() == "error") await Func.showError(key,res["Content"].toString(),btn: btn);
        else return res["Content"] ;
      }
      else await Func.showError(key,'Erreur avec le statut: ${response.statusCode} ${response.statusMessage}.',btn: btn);
    }
    catch(er){
      await Func.showError(key,er.toString(),btn: btn);
    }
    return 0;
  }
  //send a message
  static Future<bool> sendMsg(String subject, String message,GlobalKey<ScaffoldState> key,BuildContext context,RoundedLoadingButtonController btn) async {
    if(!await Func.checkConnection(btn)) return false;
    try{
      var obj = '''{
        "UserId":"${(await Prefs.getUserId())}",
        "Subject":"'''+subject+'''",
        "Message":"'''+message+'''"
      }''';
      var response = await Dio().post(await MyGlobal.reportProbUrl(),data:obj,options: Options(headers: {"Content-type": "application/json"}));
      if(response.statusCode == 200) {
        var res = response.data;
        if(res["Type"].toString() == "error") await Func.showError(key,res["Content"].toString(),btn: btn);
        else {
          await Fluttertoast.showToast(msg: res["Content"].toString());
          await btn.success();
          return true ;
        }
      }
      else await Func.showError(key,'Erreur avec le statut: ${response.statusCode} ${response.statusMessage}.',btn: btn);
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
      var response = await Dio().get(Uri.encodeFull(baseUrl)).timeout(Duration(seconds: 10));
      if(response.statusCode == 200){
        var res = response.data;
        if(res["Type"].toString() == "success"){
          await Prefs.setServerUrl(baseUrl);
          await Func.endLoading(btnController: btn);
          return true ;
        }
        else await Func.showError(key,res["Content"].toString(),btn: btn);
      }
      else await Func.showError(key,'Erreur avec le statut: ${response.statusCode} ${response.statusMessage}.',btn: btn);
    }
    catch(er){
      await Func.showError(key,er.toString(),btn: btn);
    }
    return false;
  }
  //Upload SqLite Database
  static Future<bool> refreshData(GlobalKey<ScaffoldState> key,BuildContext context,RoundedLoadingButtonController btn) async {
    if(!await Func.checkConnection(btn)) return false;
    var pd = ProgressDialog(context,isDismissible: false);
    pd.style(maxProgress: 100,progress: 0,message: "Chargement ...");
    await pd.show();
    try{
      final Dio _dio = Dio();
      var file = await MyGlobal.getDbFile();
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path,filename: MyGlobal.dbName)
      });
      var user = await User.get();
      var response = await _dio.post(await MyGlobal.uploadUrl(),
        data: formData,
        options: Options(
            headers: {"Authorization": "${user.username} ${user.password}"} // set content-length
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
      print(response.statusMessage);
      if(response.statusCode == 200) {
        await Func.endLoading(pd: pd,btnController: btn);
        return await downloadDb(key, context, btn);
      }
      else await Func.showError(key,'Erreur avec le statut: ${response.statusCode} ${response.statusMessage}.',pd: pd,btn: btn);
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
      var file = await MyGlobal.getDbFile(delete: true);
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
        await Func.endLoading(pd: pd,btnController: btn);
        await btn.success();
        return true;
      }
      else await Func.showError(key,'Erreur avec le statut: ${response.statusCode} ${response.statusMessage}.',pd: pd,btn: btn);
    }
    catch(er){
      await Func.showError(key,er.toString(),pd: pd,btn: btn);
    }
    return false;
  }
}