import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'scannerView.dart';


class Func{
  //static Color getRandomColor() => MyGlobal.colorsList()[Random().nextInt(MyGlobal.colorsList().length - 0)];
  static Future<SharedPreferences> getPrefs() async => await SharedPreferences.getInstance();
  static Future<bool> clearPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }
  static bool isNumeric(String s) {
    if(s == null) return false;
    return double.parse(s, (e) => null) != null;
  }
  static bool isNull(String val) => val == null || val.trim() == "" || val.trim() == "null";
  static Future<void> showError(GlobalKey<ScaffoldState> key,String error,{RoundedLoadingButtonController btn,ProgressDialog pd}) async {
    key.currentState.showSnackBar(SnackBar(
      duration: const Duration(seconds: 30),
      content: Text(error),
      backgroundColor: Colors.red,
    ));
    if(btn != null) await btn.stop();
    if(pd != null) await pd.hide();
  }
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
      Fluttertoast.showToast(msg: "Pas de connexion !!!",toastLength: Toast.LENGTH_LONG);
      return false;
    }
    return true;
  }
  static String trimEnd(String str,String c) => str[str.length-1] == c?str.substring(0, str.length - 1):str;

  static Future<String> scan(BuildContext context) async => await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => QRCodeView()));

  static Future<void> endLoading({ProgressDialog pd,RoundedLoadingButtonController btnController}) async {
    if(btnController != null) await btnController.stop();
    if(pd != null) await pd.hide();
  }

  static Text hTxt(String txt) => Text(txt,style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold));
}