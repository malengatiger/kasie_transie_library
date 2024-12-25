import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:permission_handler/permission_handler.dart';

class LastScannerWidget extends StatefulWidget {
  const LastScannerWidget({super.key, required this.onScanned});

  final Function(dynamic) onScanned;

  @override
  State<LastScannerWidget> createState() => LastScannerWidgetState();
}

class LastScannerWidgetState extends State<LastScannerWidget> {
  ScanResult? result;

  final _flashOnController = TextEditingController(text: 'Flash on');
  final _flashOffController = TextEditingController(text: 'Flash off');
  final _cancelController = TextEditingController(text: 'Cancel');

  final _aspectTolerance = 0.00;
  var _numberOfCameras = 0;
  final _selectedCamera = -1;
  final _useAutoFocus = true;
  final _autoEnableFlash = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;
      setState(() {});
    });
    _getPermission();
  }

  _getPermission() async {
    var isGranted = await Permission.camera.isGranted;
    if (!isGranted) {
      await Permission.camera.request();
    }

    pp('🐬🐬🐬🐬🐬🐬🐬🐬 Camera permission is granted: $isGranted');
  }

  void _scan() async {
    debugPrint('\n\n...... 🐬🐬 start scan ...');
    setState(() {});
    try {
      var options = ScanOptions(
        restrictFormat: [BarcodeFormat.qr],
        useCamera: _selectedCamera,
        autoEnableFlash: _autoEnableFlash,
        android: AndroidOptions(
          aspectTolerance: _aspectTolerance,
          useAutoFocus: _useAutoFocus,
        ),
      );

      result = await BarcodeScanner.scan(options: options);
      debugPrint(
          '🐬 🐬 🐬 Result: ${result!.type.name} - 🍎🍎 ${result!.rawContent} 🍎🍎');
      var json = jsonDecode(result!.rawContent);
      myPrettyJsonPrint(json);
      debugPrint('🐬 🐬 🐬 🍎🍎🍎🍎\n');
      widget.onScanned(json);
      if (mounted) {
        Navigator.of(context).pop(json);
      }
    } on PlatformException catch (e) {
      pp(e);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Scan Result',
                  style: myTextStyle(weight: FontWeight.w900, fontSize: 24)),
              gapH32,
              result == null
                  ? const Text('No scan yet')
                  : Text(
                      result!.rawContent,
                      style: myTextStyle(),
                    ),
            ],
          ),
        ),
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scan,
        tooltip: 'Scan QR Code',
        child: const Icon(Icons.scanner),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
