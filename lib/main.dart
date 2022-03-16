import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _scanBarcode = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('QR Code Scanner')),
        body: Builder(
          builder: (BuildContext context) {
            return Container(
              alignment: Alignment.center,
              child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => scanQR(context),
                      child: const Text(
                        'Scan QR Code',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                          minimumSize: const Size(
                              200, 60) // put the width and height you want
                          ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Text(
                        _scanBarcode,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 60),
                    ),
                  ]),
            );
          },
        ),
      ),
    );
  }

  Future<void> scanQR(BuildContext context) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      // barcodeScanRes = 'Failed to get platform version.';
      barcodeScanRes = '';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    log("Scan finished");
    if (await confirm(
      context,
      title: const Text('Open Link?'),
      content: Text(barcodeScanRes),
      textOK: const Text('Yes'),
      textCancel: const Text('No'),
    )) {
      log('pressedOK');
      setState(() async {
        _scanBarcode = 'Scan Result: $barcodeScanRes';
      });
      checkingValue(barcodeScanRes);
    } else {
      log('pressedCancel');
    }
  }

  Future checkingValue(String url) async {
    log("checking...");
    if (url != null || url != "") {
      if (url.contains("https") || url.contains("http")) {
        _launchURL(url);
      }
    }
  }

  void _launchURL(String url) async {
    log("try open link..");
    if (await canLaunch(url)) {
      log("can launch url");
      if (!await launch(url)) {
        log('Could not launch $url');
      }
    }
    log("link opened");
  }
}
