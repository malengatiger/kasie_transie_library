import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/functions.dart';

class ScannerThree extends StatefulWidget {
  const ScannerThree({super.key});

  @override
  ScannerThreeState createState() => ScannerThreeState();
}

class ScannerThreeState extends State<ScannerThree>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const mm = '🦋🦋🦋 ScannerThree 🦋🦋🦋';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        // Handle permission denial (e.g., show a message, disable camera features)
        return;
      }
    }
    // Permission granted, proceed with camera usage
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ScanResult? scanResult;

  _scan() async {
    var options = const ScanOptions(
      autoEnableFlash: false,
      restrictFormat: [BarcodeFormat.qr],
      useCamera: -1,
      android: AndroidOptions(useAutoFocus: true, aspectTolerance: 0.00),
      strings: {
        'cancel': 'Cancel',
        'flash_on': 'Flash on',
        'flash_off': 'Flash off',
      },

    );
    try {
      scanResult = await BarcodeScanner.scan(options: options);
      pp('$mm rawContent: ${scanResult?.rawContent.toString()}');
      pp('$mm format name${scanResult?.format.name}');
      pp('$mm Type name: ${scanResult?.type.name}');
      pp('$mm toString: ${scanResult.toString()}');
    } catch (e, s) {
      pp('$e $s');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Three'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _scan();
                },
                child: SizedBox(
                  width: 300,
                  child: Text(
                    'Scan',
                    style: myTextStyleLarge(context),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
