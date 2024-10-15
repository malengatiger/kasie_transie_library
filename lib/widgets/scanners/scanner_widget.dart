import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/widgets/scanners/scanner_constants.dart';
import 'package:kasie_transie_library/widgets/scanners/user_card.dart';
import 'package:kasie_transie_library/widgets/scanners/vehicle_card.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../../data/data_schemas.dart';
import '../../data/ticket.dart';
import '../../utils/functions.dart';
import '../../utils/navigator_utils.dart';




class QRScannerWidget extends StatefulWidget {
  const QRScannerWidget(
      {super.key,
      required this.onVehicleScanned,
      required this.onUserScanned,
      required this.onTicketScanned,
      required this.onCommuterScanned});

  final Function(Vehicle) onVehicleScanned;
  final Function(User) onUserScanned;
  final Function(Ticket) onTicketScanned;
  final Function(Commuter) onCommuterScanned;

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  String? _scanResult;
  User? userScanned;
  Vehicle? carScanned;
  Commuter? commuterScanned;
  Ticket? ticketScanned;

  String? typeString;
  static const mm = '🍎🍎🍎 QRScannerWidget 🍎';

  _navigateToScan() async {
    _scanResult = await NavigationUtils.navigateTo(
        context: context,
        widget: const SimpleBarcodeScannerPage(),
        transitionType: PageTransitionType.leftToRight);
    pp('$mm scan result: $_scanResult');
    if (_scanResult != null) {
      var mJson = jsonDecode(_scanResult!);
      if (mJson['vehicleId'] != null) {
        carScanned = Vehicle.fromJson(mJson);
        typeString = ScannerConstants.vehicle;
        widget.onVehicleScanned(carScanned!);
      }
      if (mJson['userId'] != null) {
        userScanned = User.fromJson(mJson);
        typeString = ScannerConstants.user;
        widget.onUserScanned(userScanned!);
      }
      if (mJson['commuterId'] != null) {
        commuterScanned = Commuter.fromJson(mJson);
        typeString = ScannerConstants.commuter;
        widget.onCommuterScanned(commuterScanned!);
      }
      if (mJson['ticketId'] != null) {
        ticketScanned = Ticket.fromJson(mJson);
        typeString = ScannerConstants.ticket;
        widget.onTicketScanned(ticketScanned!);
      }

      pp('\n\n$mm scanned: 🍎 $typeString 🍎');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text('KasieScanner',
              style: myTextStyle(
                fontSize: 24,
                weight: FontWeight.w900,
              ))),
      body: SafeArea(
          child: Stack(
        children: [
          _scanResult == null
              ? Center(
                  child: ElevatedButton(
                      style: const ButtonStyle(
                        elevation: WidgetStatePropertyAll(8),
                      ),
                      onPressed: () {
                        _navigateToScan();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Start Scanning',
                          style: myTextStyle(
                              fontSize: 28, weight: FontWeight.bold),
                        ),
                      )),
                )
              : gapW32,
          _scanResult == null
              ? gapW32
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Scan Result',
                      style: myTextStyle(weight: FontWeight.bold, fontSize: 24),
                    ),
                    if (carScanned != null) VehicleCard(vehicle: carScanned!),
                    if (userScanned != null) UserCard(user: userScanned!),
                    gapH32,
                    gapH32,
                  ],
                ),
          _scanResult == null
              ? gapW32
              : Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel')),
                          ElevatedButton(
                              style: const ButtonStyle(
                                elevation: WidgetStatePropertyAll(8.0),
                              ),
                              onPressed: () {
                                _navigateToScan();
                              },
                              child: Text(
                                'Done',
                                style: myTextStyle(
                                    fontSize: 24, weight: FontWeight.bold),
                              )),
                        ],
                      ),
                    ),
                  ),
                )
        ],
      )),
    );
  }
}
