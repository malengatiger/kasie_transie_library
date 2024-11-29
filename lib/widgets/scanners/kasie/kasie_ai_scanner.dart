import 'dart:convert';

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pretty_print_json/pretty_print_json.dart' as pretty;

import '../../../utils/functions.dart';
import 'barcode_display.dart';

class KasieAIScanner extends StatefulWidget {
  const KasieAIScanner({super.key, required this.onScanned});

  final Function(Map<String, dynamic>) onScanned;
  @override
  State<KasieAIScanner> createState() => _KasieAIScannerState();
}

class _KasieAIScannerState extends State<KasieAIScanner> {
  String barcode = 'Tap  to scan';
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  static const mm = '🍐🍐🍐🍐KasieAIScanner 🍎';

  @override
  void initState() {
    super.initState();
  }

  Future _handleScanResult(Map<String, dynamic> json) async {
    if (json['vehicleId'] != null) {
      pp('\n\n$mm  🥬 Seems a vehicle has been scanned  🥬 🥬 ${json['vehicleReg']}  🥬 🥬');
    }
    pp('$mm ...  widget.onScanned ... ');
    pp('\n\n$mm ${pretty.prettyJson(json)}\n\n');
    widget.onScanned(json);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    final Rect scanWindow = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: width,
      height: height,
    );
    return Scaffold(
      appBar: AppBar(
          title: const Row(
        children: [
          Icon(Icons.document_scanner_sharp),
          SizedBox(width: 16),
          Text(
            'KasieTransie AI Scanner',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
        ],
      )),
      body: Stack(children: [
        Center(
          child: AiBarcodeScanner(
            onDispose: () {
              pp("\n🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎Barcode scanner disposed!");
            },
            hideGalleryButton: true,
            fit: BoxFit.cover,
            controller: scannerController,
            hideSheetDragHandler: true,
            hideSheetTitle: true,
            scanWindow: scanWindow,
            cutOutSize: width,
            validator: (value) {
              if (value.barcodes.isEmpty) {
                return false;
              }
              if (!(value.barcodes.first.rawValue?.contains('flutter.dev') ??
                  false)) {
                return false;
              }
              return true;
            },
            onDetect: (BarcodeCapture capture) async {
              /// The row string scanned barcode value
              pp("$mm Barcode onDetect ...");

              final List<Barcode> barcodes = capture.barcodes;
              pp("$mm Barcode list: ${barcodes.length}");
              if (barcodes.isNotEmpty) {
                final String? scannedValue = capture.barcodes.first.rawValue;
                if (scannedValue != null && scannedValue.runtimeType == String) {
                  pp("$mm Barcode scannedValue runtimeType: ${scannedValue.runtimeType}");
                  pp("$mm 🥦🥦 Barcode scanned: $scannedValue 🥦🥦");
                  Map<String, dynamic> map = jsonDecode(scannedValue);
                  pp("$mm Barcode map runtimeType: ${map.runtimeType}");
                  pp("$mm 🥦🥦 Barcode json: $map 🥦🥦");
                  await scannerController.stop();
                  _handleScanResult(map);
                }
              }
            },
          ),
        ),
      ]),
    );
  }
}
