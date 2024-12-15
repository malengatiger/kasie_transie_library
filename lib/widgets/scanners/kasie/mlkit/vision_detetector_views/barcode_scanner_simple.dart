import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../utils/functions.dart';

class BarcodeScannerSimple extends StatefulWidget {
  const BarcodeScannerSimple({super.key, required this.onScanned});

  final Function(String) onScanned;

  @override
  State<BarcodeScannerSimple> createState() => _BarcodeScannerSimpleState();
}

class _BarcodeScannerSimpleState extends State<BarcodeScannerSimple> {
  Barcode? _barcode;

  Widget _buildBarcode(Barcode? value) {
    if (value == null) {
      return const Text(
        'Scan something!',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }

    return Text(
      value.displayValue ?? 'No display value.',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  static const mm = '🍎🍎🍎🍎 BarcodeScannerSimple 🍎';

  @override
  void initState() {
    mobileScannerController.start();
    super.initState();
    _requestCameraPermission();
  }

  void _handleBarcode() {
    if (mounted) {
      setState(() {
        _barcode = barcodeCapture!.barcodes.firstOrNull;
      });
    }
    if (_barcode == null) return;
    pp('$mm barcode?.rawValue: ${_barcode?.rawValue}');
    widget.onScanned(_barcode!.rawValue!);
  }

  BarcodeCapture? barcodeCapture;
  final MobileScannerController mobileScannerController =
      MobileScannerController(
    autoStart: false,
    formats: [BarcodeFormat.qrCode],
  );
  bool controllerReady = false;
  bool cameraPermissionOK = false;

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          showErrorToast(
              message: 'Camera permission is required', context: context);
        }
        return;
      }
    }
    // Permission granted, proceed with camera usage
    pp('$mm ... camera permission granted ... ${status.name}');
    Future.delayed(const Duration(milliseconds: 100), () async {
      await mobileScannerController.start();
      pp('$mm .................. mobileScannerController should be started ...');
      setState(() {});
    });

    setState(() {
      cameraPermissionOK = true;
    });
  }

  Future _handleController() async {
    pp('$mm .................. _handleController ...');
    await _requestCameraPermission();
    if (cameraPermissionOK) {
      setState(() {
        controllerReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    pp('$mm build: controllerReady : $controllerReady');
    return Scaffold(
      // appBar: AppBar(title: const Text('Simple scanner')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: mobileScannerController,
            onDetectError: (obj, stack) {
              pp('$mm onDetectError: obj: $obj stack: $stack');
            },
            overlayBuilder: (ctx, constraints) {
              return Container(color: Colors.red);
            },
            fit: BoxFit.cover,
            errorBuilder: (ctx, MobileScannerException exc, child) {
              pp('$mm exc: ${exc.errorDetails?.code} ${exc.errorDetails?.message}');
              return Text('${exc.errorDetails?.message}');
            },
            onDetect: (capture) {
              pp('$mm Hooray! a scan has been detected! ${capture.barcodes.length}');
              setState(() {
                barcodeCapture = capture;
              });
              _handleBarcode();
            },
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Container(
          //     alignment: Alignment.bottomCenter,
          //     height: 100,
          //     color: Colors.black26,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [
          //         Expanded(child: Center(child: _buildBarcode(_barcode))),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
