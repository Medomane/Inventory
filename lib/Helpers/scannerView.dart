import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vibration/vibration.dart';

class QRCodeView extends StatefulWidget {
  const QRCodeView({Key key,}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCodeViewState();
}

class _QRCodeViewState extends State<QRCodeView> {
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool flashOn = false,animationToggle=false;

  @override
  void initState(){
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<SizeChangedLayoutNotification>(
            onNotification: (notification) {
              Future.microtask(() => controller?.updateDimensions(qrKey, scanArea: _area(context)));
              return false;
            },
            child: SizeChangedLayoutNotifier(
              key: const Key('qr-size-notifier'),
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.blue,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: _area(context),
                ),
              )
            )
          ),
          Positioned(
            width: 50,
            height: 50,
            child: Center(
              child: FlatButton(
                onPressed: (){
                  setState(() {
                    flashOn = !flashOn;
                    controller.toggleFlash();
                  });
                },
                child: flashOn?Icon(Icons.flash_on):Icon(Icons.flash_off),
              ),
            ),
            bottom: _flashPosition(context),
            left: (MediaQuery.of(context).size.width/2)-25,
          ),
          Center(
            child: Container(
              height: _area(context)-10,
              width: _area(context)-10,
              child: AnimatedContainer(
                alignment: animationToggle?AlignmentDirectional.bottomCenter:AlignmentDirectional.topCenter,
                duration: Duration(seconds: 2),
                onEnd: (){
                  setState(() {
                    animationToggle = !animationToggle;
                  });
                },
                curve: Curves.fastOutSlowIn,
                child: Container(
                  height: 2,
                  width: _area(context),
                  color: Colors.blue,
                ),
              )
            )
          ),
        ],
      )
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    setState(() {
      animationToggle = true;
    });
    controller.scannedDataStream.listen((scanData) async {
      this.controller.dispose();
      await FlutterBeep.beep();
      if (await Vibration.hasVibrator()) await Vibration.vibrate();
      Navigator.pop(context,scanData.code);
    });
  }

  double _flashPosition(BuildContext context){
    var area = _area(context);
    var h = ((MediaQuery.of(context).size.height-area)/2)-50;
    return h;
  }

  double _area(BuildContext context) => MediaQuery.of(context).size.width - 100;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}