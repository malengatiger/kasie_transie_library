import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lm;
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/initializer.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/data_schemas.dart';


class QRScanner extends StatefulWidget {
  const QRScanner(
      {super.key,
      required this.onCarScanned,
      required this.onUserScanned,
      required this.onError,
      required this.quitAfterScan,
      required this.onClear});

  final Function(lm.Vehicle) onCarScanned;
  final Function(lm.User) onUserScanned;
  final Function onError;
  final Function onClear;

  final bool quitAfterScan;

  @override
  QRScannerState createState() => QRScannerState();
}

class QRScannerState extends State<QRScanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final mm = '🌀🌀🌀🌀🌀🌀🌀🌀QRScanner 🍟🍟';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();

  Barcode? result;

  // QRViewController? qrViewController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  lm.Vehicle? vehicle;
  late StreamSubscription<bool> _subscription;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _getCameraPermission();
  }

  PermissionStatus? permissionStatus;

  void _listen() {
    _subscription = initializer.completionStream.listen((event) {
      pp('\n\n$mm delivered an initialization completion flag: $event\n');
    });
  }

  Future _getCameraPermission() async {
    pp('$mm ......... requesting camera permission ...');
    permissionStatus = await Permission.camera.status;
    pp('$mm ......... requesting camera permissionStatus!.isGranted: ${permissionStatus!.isGranted} ...');
    if (permissionStatus!.isGranted) {
      pp('$mm ......... we cool ...');
    } else {
      pp('$mm ......... we NOT cool, will request permission  ${E.redDot}...');
      permissionStatus = await Permission.camera.request();
    }
    setState(() {});
  }

  void _returnScannedData(BarcodeCapture map) async {
    pp('$mm _returnScannedData : ${E.leaf2}${E.leaf2}${E.leaf2}');

    Vehicle? vehicle;
    if (map.barcodes.isNotEmpty) {
      var barcode = map.barcodes[0].rawValue;
      if (barcode != null) {
        var json = jsonDecode(barcode);
        vehicle = Vehicle.fromJson(json);
      }
    }

    try {
      if (vehicle != null) {
         vehicle = await listApiDog.getVehicle(vehicle.vehicleId!.toString());
        pp('$mm scanned vehicle retrieved from Realm : ${E.redDot}${E.redDot}${E.redDot}');
        myPrettyJsonPrint(vehicle!.toJson());
        widget.onCarScanned(vehicle);
        if (widget.quitAfterScan) {}

        return;
      }
      // final userId = map['userId'];
      // if (userId != null) {
      //   // vehicle = await listApiDog.getVehicle(vehicleId);
      //   // pp('$mm scanned vehicle retrieved from Realm : ${E.redDot}${E.redDot}${E.redDot}');
      //   // myPrettyJsonPrint(vehicle!.toJson());
      //   return;
      // }
    } catch (e) {
      pp(e);
    }

    widget.onError();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final MobileScannerController mobileScannerController =
      MobileScannerController();

  @override
  Widget build(BuildContext context) {
    if (permissionStatus == null) {
      return const Center(
        child: Text('Waiting for Godot!'),
      );
    }
    return SizedBox(
      width: 300,
      height: 300,
      child: MobileScanner(
        controller: mobileScannerController,
        onDetect: (barcodeCapture) {
          pp('barcodeCapture ${barcodeCapture.toString()}');
          _returnScannedData(barcodeCapture);
        },
        errorBuilder: (context, exception, widget) {
          pp('we fell down, Boss! ...');
          return const Text('Fuck!');
        },
        overlayBuilder: (context, constraints) {
          return const Text('What is Overlay??');
        },
      ),
    );
  }
}
