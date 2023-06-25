import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lm;
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/initializer.dart';
import 'package:kasie_transie_library/widgets/vehicle_detail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanDispatch extends StatefulWidget {
  const ScanDispatch({Key? key}) : super(key: key);

  @override
  ScanDispatchState createState() => ScanDispatchState();
}

class ScanDispatchState extends State<ScanDispatch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final mm = '🌀🌀🌀🌀🌀🌀🌀🌀ScanDispatch 🍟🍟';

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
    setState(() {

    });

  }

  void _showScannedVehicle(Map carMap) async {

      var vehicleId = carMap['vehicleId'];
      if (vehicleId != null) {
        vehicle = await listApiDog.getVehicle(vehicleId);
        pp('$mm scanned vehicle retrieved from Realm : ${E.redDot}${E.redDot}${E.redDot}');
        myPrettyJsonPrint(vehicle!.toJson());
      }
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    pp('$mm _buildQrView ... get qr widget' );
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return permissionStatus!.isGranted? SizedBox(width: 400, height: 400,
      child: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
            borderColor: Colors.red,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: scanArea),
        onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
      ),
    ) : Center(
      child: Card(
        child: Text('No Permission!', style: myTextStyleMediumLargeWithSize(context, 24),),
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
        var m = jsonDecode(scanData.code!);
        controller.pauseCamera();
        _showScannedVehicle(m);
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
        child: Text('waiting for Godot!'),
      );
    }
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text('Scan Vehicle', style: myTextStyleLarge(context),),
      ),
      body: Stack(
        children: [
          Center(
            child: SizedBox(width: 600,
              child: Column(
                children: [
                  const SizedBox(height: 48,),
                  Text('Taxi Dispatch Scan', style: myTextStyleMediumLargeWithSize(context, 24),),
                  const SizedBox(height: 48,),
                  vehicle == null? _buildQrView(context) : Column(
                    children: [
                      VehicleDetail(vehicle: vehicle!,),
                      const SizedBox(height: 48,),
                      SizedBox(width: 300,
                        child: ElevatedButton(onPressed: (){
                          pp('$mm dispatch this car: ${vehicle!.vehicleReg}');
                        }, child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Dispatch this Taxi'),
                        ),
                        ),
                      ),
                      const SizedBox(height: 48,),

                      ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.grey),
                        ),
                        onPressed: (){
                          pp('$mm scan again ... ');

                        }, child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Scan Again'),
                      ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          
        ],
      ),
    ));
  }
}
