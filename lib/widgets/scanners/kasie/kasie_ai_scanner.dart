import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pretty_print_json/pretty_print_json.dart' as pretty;
import '../../../utils/functions.dart';
import 'mlkit/mobile_scanner_one.dart';
class KasieAIScanner extends StatefulWidget {
  const KasieAIScanner({super.key, required this.onScanned});

  final Function(Map<String, dynamic>) onScanned;

  @override
  State<KasieAIScanner> createState() => _KasieAIScannerState();
}

class _KasieAIScannerState extends State<KasieAIScanner> {
  String barcode = 'Tap  to scan';

  static const mm = '🍐🍐🍐🍐KasieAIScanner 🍎';

  @override
  void initState() {
    super.initState();
  }

  bool cameraPermissionOK = false;

  Future _handleScanResult(BarcodeCapture capture) async {
    pp('\n\n$mm  🥬 Seems something has been scanned  🥬 🥬 $json  🥬 🥬');

    pp('$mm ...  widget.onScanned ... ');
    pp('\n\n$mm ${pretty.prettyJson(json)}\n\n');
    widget.onScanned(jsonDecode(capture.barcodes.first.rawValue!));
  }

  String? barcodeString;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final center = MediaQuery.sizeOf(context).center(Offset.zero);

    final double scanWindowWidth = width / 3;
    final double scanWindowHeight = height / 2;

    final Rect scanWindow = Rect.fromCenter(
      center: center,
      width: scanWindowWidth,
      height: scanWindowHeight,
    );
    return Stack(children: [
      Center(
        child: SizedBox(
            height: height,
            width: width,
            child: MobileScannerOne(
              // scanWindow: scanWindow,
              fit: BoxFit.cover,

              onDetectError: (error, stackTrace){
                pp('$mm error: $error');
                pp('$mm stackTrace: $stackTrace');
              },
              onDetect: (capture){
                pp('\n\n$mm ... MobileScannerOne 🥬🥬🥬 onDetect: 🥬 ${capture.barcodes.first.rawValue} 🥬');
              },
              onScanned: (capture) {
                pp('\n\n$mm ... MobileScannerOne 🥬🥬🥬 onScanned: 🥬  ${capture.barcodes.first.rawValue} 🥬');
                _handleScanResult(capture);
              },
            )),
      )
    ]);
  }
}
