import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/photo_handler.dart';
import 'package:kasie_transie_library/widgets/vehicle_photo_widget.dart';
import 'package:kasie_transie_library/widgets/video_recorder.dart';
import 'package:badges/badges.dart' as bd;
import 'package:realm/realm.dart';

import '../utils/parsers.dart';

class VehiclePassengerCount extends StatefulWidget {
  const VehiclePassengerCount(
      {Key? key, required this.vehicle, required this.route})
      : super(key: key);

  final lib.Vehicle vehicle;
  final lib.Route route;

  @override
  VehiclePassengerCountState createState() => VehiclePassengerCountState();
}

class VehiclePassengerCountState extends State<VehiclePassengerCount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const mm = ' 🔷🔷🔷🔷🔷🔷 VehiclePassengerCount 🔷';
  var passengerCounts = <lib.AmbassadorPassengerCount>[];

  bool busy = false;
  bool showAllCounts = false;
  lib.User? user;
  String? passengersInText,
      passengerCounter,
      passengersOutText,
      currentPassengersText,
      saveCounts;

  Future _setTexts() async {
    final c = await prefs.getColorAndLocale();
    passengersInText = await translator.translate('passengersIn', c.locale);
    passengersOutText = await translator.translate('passengersOut', c.locale);
    currentPassengersText =
        await translator.translate('currentPassengers', c.locale);
    saveCounts = await translator.translate('saveCounts', c.locale);
    passengerCounter = await translator.translate('passengerCount', c.locale);
    passengersInText = await translator.translate('passengersIn', c.locale);
    setState(() {});
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _control();
  }

  void _control() async {
    await _setTexts();
    Future.delayed(const Duration(milliseconds: 100), () {
      _getVehiclePassengerCounts(false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _getVehiclePassengerCounts(bool refresh) async {
    pp('$mm ... get prior VehiclePassengerCounts ...');
    try {
      setState(() {
        busy = true;
      });
      user = await prefs.getUser();
      final startDate = DateTime.now()
          .toUtc()
          .subtract(const Duration(hours: 8))
          .toIso8601String();
      passengerCounts = await listApiDog.getAmbassadorPassengerCountsByVehicle(
          vehicleId: widget.vehicle.vehicleId!,
          refresh: refresh,
          startDate: startDate);
      passengerCounts.sort((a, b) => b.created!.compareTo(a.created!));
      pp('$mm ... received prior VehiclePassengerCounts ...${E.appleRed} ${passengerCounts.length}');
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
      showAllCounts = true;
    });
  }

  String? lastDate;
  void _submitCounts() async {
    pp('$mm .. _submitCounts ...');
    setState(() {
      busy = true;
    });

    try {
      final loc = await locationBloc.getLocation();
      final passengerCount = lib.AmbassadorPassengerCount(
        ObjectId(),
        associationId: user!.associationId,
        created: DateTime.now().toUtc().toIso8601String(),
        userId: user!.userId,
        vehicleId: widget.vehicle.vehicleId,
        vehicleReg: widget.vehicle.vehicleReg,
        userName: user!.name,
        currentPassengers: currentPassengers,
        passengersIn: passengersIn,
        passengersOut: passengersOut,
        position: lib.Position(
          type: point,
          coordinates: [loc.longitude, loc.latitude],
          latitude: loc.latitude,
          longitude: loc.latitude,
        ),
        routeId: widget.route.routeId,
        routeName: widget.route.name,
      );

      dataApiDog.addAmbassadorPassengerCount(passengerCount);
      pp('$mm .. _submitCounts seems OK!');
      var format = DateFormat.Hms();
      lastDate = format.format(DateTime.now());
      passengersOut = 0;
      passengersIn = 0;
      if (mounted) {
        showToast(
            duration: const Duration(seconds: 2),
            message: 'Passenger Counts saved, thank you!',
            context: context);
      }
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  int passengersIn = 0, passengersOut = 0, currentPassengers = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
            passengerCounter == null ? 'Passenger Counter' : passengerCounter!),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  showAllCounts = !showAllCounts;
                });
                if (showAllCounts) {
                  _getVehiclePassengerCounts(true);
                }
              },
              icon: const Icon(Icons.list)),
          IconButton(
              onPressed: () {
                _getVehiclePassengerCounts(true);
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: getRoundedBorder(radius: 16),
              elevation: 4,
              child: Column(
                children: [
                  const SizedBox(
                    height: 28,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.vehicle.vehicleReg}',
                        style: myTextStyleMediumLargeWithColor(
                            context, Theme.of(context).primaryColor, 32),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Text(
                    '${widget.route.name}',
                    style: myTextStyleMediumLargeWithColor(
                        context, Theme.of(context).primaryColorLight, 14),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      shape: getRoundedBorder(radius: 16),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              passengersInText == null
                                  ? 'Passengers In'
                                  : passengersInText!,
                              style: myTextStyleSmall(context),
                            ),
                            const SizedBox(
                              width: 24,
                            ),
                            NumberDropDown(
                                onNumberPicked: (number) {
                                  setState(() {
                                    passengersIn = number;
                                  });
                                },
                                color: Colors.green.shade700,
                                fontSize: 28),
                            const SizedBox(
                              width: 24,
                            ),
                            Text(
                              '$passengersIn',
                              style: myTextStyleMediumLargeWithColor(
                                  context, Colors.green.shade700, 32),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      shape: getRoundedBorder(radius: 16),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              passengersOutText == null
                                  ? 'Passengers Out'
                                  : passengersOutText!,
                              style: myTextStyleSmall(context),
                            ),
                            const SizedBox(
                              width: 24,
                            ),
                            NumberDropDown(
                                onNumberPicked: (number) {
                                  setState(() {
                                    passengersOut = number;
                                  });
                                },
                                color: Colors.red.shade700,
                                fontSize: 28),
                            const SizedBox(
                              width: 24,
                            ),
                            Text(
                              '$passengersOut',
                              style: myTextStyleMediumLargeWithColor(
                                  context, Colors.red.shade700, 32),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      shape: getRoundedBorder(radius: 16),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              currentPassengersText == null
                                  ? 'Current Passengers'
                                  : currentPassengersText!,
                              style: myTextStyleSmall(context),
                            ),
                            const SizedBox(
                              width: 24,
                            ),
                            NumberDropDown(
                                onNumberPicked: (number) {
                                  setState(() {
                                    currentPassengers = number;
                                  });
                                },
                                color: Colors.blue.shade700,
                                fontSize: 28),
                            const SizedBox(
                              width: 24,
                            ),
                            Text(
                              '$currentPassengers',
                              style: myTextStyleMediumLargeWithColor(
                                  context, Colors.blue.shade700, 32),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 48,
                  ),
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                        onPressed: () {
                          _submitCounts();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                              saveCounts == null ? 'Save Counts' : saveCounts!),
                        )),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  lastDate == null
                      ? const SizedBox()
                      : Row(
                          children: [
                            const Text('Last Count'),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              '$lastDate',
                              style: myTextStyleMediumLargeWithColor(
                                  context, Theme.of(context).primaryColor, 24),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
          busy
              ? const Positioned(
                  child: Center(
                  child: SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      backgroundColor: Colors.amber,
                    ),
                  ),
                ))
              : const SizedBox(),
        ],
      ),
    ));
  }
}

class NumberDropDown extends StatelessWidget {
  const NumberDropDown(
      {Key? key,
      required this.onNumberPicked,
      required this.color,
      required this.fontSize})
      : super(key: key);

  final Function(int) onNumberPicked;
  final Color color;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> items = [];
    for (var i = 0; i < 20; i++) {
      items.add(DropdownMenuItem(
          value: i,
          child: Text(
            '$i',
            style: myTextStyleMediumLargeWithColor(context, color, fontSize),
          )));
    }
    return DropdownButton<int>(
        items: items,
        onChanged: (number) {
          if (number != null) {
            onNumberPicked(number);
          }
        });
  }
}
