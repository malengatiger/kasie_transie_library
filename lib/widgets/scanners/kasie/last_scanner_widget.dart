import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/data_schemas.dart';
import '../../../data/ticket.dart';

class LastScannerWidget extends StatefulWidget {
  const LastScannerWidget(
      {super.key,
      required this.onVehicleScanned,
      required this.onCommuterScanned,
      required this.onCommuterTicketScanned,
      required this.onError});

  final Function(Vehicle) onVehicleScanned;
  final Function(Commuter) onCommuterScanned;
  final Function(CommuterTicket) onCommuterTicketScanned;
  final Function(String) onError;

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
  static const mm = '🍄🍄🍄🍄LastScannerWidget 🍄';

  @override
  void initState() {
    super.initState();

    _getPermission();
  }

  _getPermission() async {
    var json = {
      "vehicleId": "my-vehicle-id",
      "vehicleReg": "GF 65 GV GP",
      "associationId": "ass-id",
      "associationName": "ass-name",
      "size": 1
    };
    pp('$mm ${json.toString()}');

    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;
      setState(() {});
    });
    var isGranted = await Permission.camera.isGranted;
    if (!isGranted) {
      await Permission.camera.request();
    }

    pp('🐬🐬🐬🐬🐬🐬🐬🐬 Camera permission is granted: $isGranted');
  }

  void _scan() async {
    debugPrint('\n\n$mm ...... 🐬🐬 start scan ...');
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
          '$mm 🐬 🐬 🐬 Result: ${result!.type.name} - 🍎🍎 ${result!.rawContent} 🍎🍎');
      var json = jsonDecode(result!.rawContent);
      // myPrettyJsonPrint(json);
      debugPrint('$mm 🐬 🐬 🐬 🍎🍎🍎🍎 $json \n');
      if (result != null) {
        _processQRCode(json!);
      }
    } on PlatformException catch (e) {
      pp(e);
    }
    setState(() {});
  }

  Map<String, dynamic> _stringToMap(String data) {
    // 1. Add double quotes around keys
    String validJson = data.replaceAllMapped(
        RegExp(r'(\w+):'), (match) => '"${match.group(1)}":');

    // 2. Correctly handle date strings
    validJson = validJson.replaceAllMapped(RegExp(r'"(\w+)":"(.*?)"'),
        (match) => '"${match.group(1)}":${match.group(2)}');

    // 3. Decode the corrected JSON string
    return jsonDecode(validJson);
  }

  void _processQRCode(Map<String, dynamic> mJson) async {
    pp('$mm .................. _processQRCode: ');
    myPrettyJsonPrint(mJson);
    try {
      if (mJson['vehicleId'] != null ||
          mJson['commuterId'] != null ||
          mJson['commuterTicketId'] != null) {
        if (mJson['vehicleId'] != null) {
          var car = Vehicle.fromJson(mJson!);

          pp('$mm car scanned,  🍀 🍀 🍀 🍀 widget.onVehicleScanned has been called! POP OUT!!');
          Navigator.of(context).pop(car);
          pp('$mm vehicle scanned: 🍀 🍀 🍀 🍀 calling widget.onVehicleScanned ... ${car.toJson()}');
          widget.onVehicleScanned(car);
        }
        if (mJson['commuterId'] != null) {
          var c = Commuter.fromJson(mJson!);

          pp('$mm commuter scanned,  🍀 🍀 🍀 🍀 widget.onCommuterScanned has been called! POP OUT!!');
          Navigator.of(context).pop(c);
          pp('$mm commuter scanned,  🍀 🍀 🍀 🍀 calling widget.onCommuterScanned ...: ${c.toJson()}');
          widget.onCommuterScanned(c);
        }
        if (mJson['commuterTicketId'] != null) {
          var c = CommuterTicket.fromJson(mJson!);
          pp('$mm commuter ticket scanned: ${c.toJson()}');
          widget.onCommuterTicketScanned(c);
          Navigator.of(context).pop(c);
        }
      } else {
        pp('$mm .................. _processQRCode: 😈 😈 😈 😈 unknown code');
        widget.onError('Unknown QR code');
        Navigator.of(context).pop();
      }

      setState(() {});
    } catch (e, s) {
      pp('$mm ERROR: $e - $s');
      if (mounted) {
        showErrorToast(
            duration: const Duration(seconds: 5),
            message: 'Fucked up scanner shit:  $e',
            context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ButtonStyle(
              elevation: WidgetStatePropertyAll(16),
              backgroundColor: WidgetStatePropertyAll(Colors.green.shade600),
            ),
            onPressed: () {
              _scan();
            },
            child: Padding(padding: EdgeInsets.all(16), child: Text(
              'Start Scanner',
              style: myTextStyle(weight: FontWeight.w300, fontSize: 28, color: Colors.white ),
            ),)
          )
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _scan,
      //   tooltip: 'Scan QR Code',
      //   child: const Icon(Icons.scanner),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
