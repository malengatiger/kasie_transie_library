import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lm;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/list_api_dog.dart';
import '../../utils/emojis.dart';
import '../../utils/functions.dart';

class QRScannerMobile extends StatefulWidget {
  const QRScannerMobile({super.key, required this.onCarScanned, required this.onUserScanned, required this.onError, required this.quitAfterScan});

  final Function(lm.Vehicle) onCarScanned;
  final Function(lm.User) onUserScanned;
  final Function onError;
  final bool quitAfterScan;
  @override
  State<QRScannerMobile> createState() => _QRScannerMobileState();
}

class _QRScannerMobileState extends State<QRScannerMobile> {
  MobileScannerController cameraController = MobileScannerController();
  PermissionStatus? permissionStatus;
  final mm = '🌀🌀🌀🌀🌀🌀🌀🌀QRScannerMobile 🍟🍟';

  @override
  void initState() {
    super.initState();
    _getCameraPermission();
  }
  Future _getCameraPermission() async {
    pp('$mm ......... requesting camera permission ...');
    permissionStatus = await Permission.camera.status;
    if (!permissionStatus!.isGranted) {
      permissionStatus = await Permission.camera.request();
    }
    pp('$mm requesting camera permission ...permissionStatus: $permissionStatus');

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Scanner'),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        // fit: BoxFit.contain,
        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;
          for (final barcode in barcodes) {

            pp('$mm Barcode found! ${barcode.rawValue}');
            final mjson = jsonDecode(barcode.rawValue!);
            _returnScannedData(mjson);
          }
        },
      ),
    );
  }
  void _returnScannedData(dynamic map) async {
    pp('$mm _returnScannedData : ${E.leaf2}${E.leaf2}${E.leaf2}');

    try {
      final vehicleId = map['vehicleId'];
      if (vehicleId != null) {
        final vehicle = await listApiDog.getVehicle(vehicleId);
        pp('$mm scanned vehicle retrieved from Realm : ${E.redDot}${E.redDot}${E.redDot}');
        myPrettyJsonPrint(vehicle!.toJson());
        widget.onCarScanned(vehicle);
        if (widget.quitAfterScan) {
          //qrViewController!.pauseCamera();
        }

        return;
      }
      final userId = map['userId'];
      if (userId != null) {
        // vehicle = await listApiDog.getVehicle(vehicleId);
        // pp('$mm scanned vehicle retrieved from Realm : ${E.redDot}${E.redDot}${E.redDot}');
        // myPrettyJsonPrint(vehicle!.toJson());
        return;
      }
    } catch (e) {
      pp(e);
    }

    widget.onError();
  }

}
