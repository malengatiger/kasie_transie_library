import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lm;
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/initializer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';


class QRScanner extends StatefulWidget {
  const QRScanner(
      {Key? key,
      required this.onCarScanned,
      required this.onUserScanned,
      required this.onError, required this.quitAfterScan})
      : super(key: key);

  final Function(lm.Vehicle) onCarScanned;
  final Function(lm.User) onUserScanned;
  final Function onError;
  final bool quitAfterScan;

  @override
  QRScannerState createState() => QRScannerState();
}

class QRScannerState extends State<QRScanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final mm = '🌀🌀🌀🌀🌀🌀🌀🌀QRScanner 🍟🍟';

  Barcode? result;
  QRViewController? qrViewController;
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
    permissionStatus = await Permission.camera.status;
    if (!permissionStatus!.isGranted) {
      permissionStatus = await Permission.camera.request();
    }
    setState(() {});
  }

  void _returnScannedData(dynamic map) async {
    pp('$mm _returnScannedData : ${E.leaf2}${E.leaf2}${E.leaf2}');


    qrViewController!.resumeCamera();

    try {
      final vehicleId = map['vehicleId'];
      if (vehicleId != null) {
        final vehicle = await listApiDog.getVehicle(vehicleId);
        pp('$mm scanned vehicle retrieved from Realm : ${E.redDot}${E.redDot}${E.redDot}');
        myPrettyJsonPrint(vehicle!.toJson());
        widget.onCarScanned(vehicle);
        if (widget.quitAfterScan) {
          qrViewController!.pauseCamera();
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

  Widget _buildQrView(BuildContext context) {
    pp('$mm _buildQrView ... get qr widget');

    return permissionStatus!.isGranted
        ? Container(color: Colors.black,
            width: 300,
            height: 300,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                  borderColor: Theme.of(context).primaryColor,
                  borderRadius: 16,
                  borderLength: 30,
                  borderWidth: 16,
                  cutOutSize: 300),
              onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
            ),
          )
        : Center(
            child: Card(
              child: Text(
                'No Permission!',
                style: myTextStyleMediumLargeWithSize(context, 24),
              ),
            ),
          );
  }

  void _onQRViewCreated(QRViewController controller) {
    pp('$mm _onQRViewCreated ..............');
    setState(() {
      qrViewController = controller;
    });
    pp('$mm scannedDataStream.listen ...............');
    controller.scannedDataStream.listen((scanData) {
      pp('$mm scannedDataStream delivered scanned data ${scanData.code}');
      if (scanData.code != null) {
        try {
          var m = jsonDecode(scanData.code!);
          controller.pauseCamera();
          _returnScannedData(m);
        } catch (e) {
          pp(e);
        }
      }
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    pp('$mm _onPermissionSet ................ $p ');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    qrViewController?.dispose();
    super.dispose();
  }

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
      child: _buildQrView(context),
    );
  }
}
