import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lm;
import 'package:kasie_transie_library/widgets/tiny_bloc.dart';
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
      body: Stack(
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              gapH16,
              Center(
                child: SizedBox(height: 300, width: 300,
                  child: MobileScanner(
                    // fit: BoxFit.contain,
                    controller: cameraController,
                    fit: BoxFit.fill,
                    onDetect: (capture) {
                      cameraController.stop();
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        pp('$mm fucking Barcode found!: ${barcode.rawValue}');
                        var string = barcode.rawValue;
                        pp('$mm string: $string');
                        if (!string!.contains('{')) {
                          string = '{\n$string\n}';
                        }
                        Map? mjson;
                        try {
                          mjson = jsonDecode(convertStringToJson(barcode.rawValue!));
                        } catch (e) {
                          mjson = jsonDecode(barcode.rawValue!);
                        }
                        pp('$mm mjson: $mjson');
                        tinyBloc.setScannerResult(mjson!);
                        Navigator.of(context).pop(mjson);
                      }
                    },
                  ),
                ),
              ),
              gapH32,
              car == null? gapH16: Text('${car!.vehicleReg}', style: myTextStyleLarge(context),),

            ],
          )
        ],
      ),
    );
  }
  String convertStringToJson(String input) {
    pp(' Parse the string into a Map object');
    Map<String, dynamic> keyValuePairs = {};
    List<String> pairs = input.split(',');
    for (String pair in pairs) {
      List<String> parts = pair.split(':');
      if (parts.length == 2) {
        String key = parts[0].trim().replaceAll('"', '');
        String value = parts[1].trim().replaceAll('"', '');
        keyValuePairs[key] = value;
      }
    }

    // Convert the Map object into a JSON string
    String json = jsonEncode(keyValuePairs);
    return json;
  }
  lm.Vehicle? car;
  void _returnScannedData(Map json) async {
    pp('$mm _returnScannedData : check id below .....  ${E.leaf2}${E.leaf2}${E.leaf2}');
    myPrettyJsonPrint(json);
    try {
      final vehicleId = json['vehicleId'];
      if (vehicleId != null) {
        car = await listApiDog.getVehicle(vehicleId);
        pp('$mm scanned car retrieved. widget.quitAfterScan: ${widget.quitAfterScan} : ${E.redDot}${E.redDot}${E.redDot}');
        myPrettyJsonPrint(car!.toJson());
        if (widget.quitAfterScan) {
          cameraController.stop();
        }
        if (mounted) {
          setState(() {
          });
        }
        widget.onCarScanned(car!);
        return;
      } else {
        pp('$mm _returnScannedData has no car!!! - why is it null? : ${E.leaf2}${E.leaf2}${E.leaf2}');

      }
      final userId = json['userId'];
      if (userId != null) {
        // car = await listApiDog.getVehicle(vehicleId);
        // pp('$mm scanned car retrieved from Realm : ${E.redDot}${E.redDot}${E.redDot}');
        // myPrettyJsonPrint(car!.toJson());
        return;
      }
    } catch (e) {
      pp(e);
    }

    // widget.onError();
  }

}
