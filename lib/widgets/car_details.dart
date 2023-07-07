import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/counter_bag.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/maps/location_response_map.dart';
import 'package:kasie_transie_library/messaging/fcm_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/widgets/counts_widget.dart';
import 'package:kasie_transie_library/widgets/number_widget.dart';
import 'package:realm/realm.dart';

import '../bloc/data_api_dog.dart';
import '../l10n/translation_handler.dart';
import '../utils/emojis.dart';
import '../utils/prefs.dart';
import 'days_drop_down.dart';

class CarDetails extends StatefulWidget {
  const CarDetails(
      {Key? key, required this.vehicle, this.width, required this.onClose})
      : super(key: key);

  final lib.Vehicle vehicle;
  final double? width;
  final Function onClose;

  @override
  CarDetailsState createState() => CarDetailsState();
}

class CarDetailsState extends State<CarDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🐦🐦🐦🐦🐦🐦🐦 CarDetails 🍎🍎';
  var counts = <CounterBag>[];
  int days = 30;
  bool busy = false;
  String? ownerDashboard,
      numberOfCars,
      arrivalsText,
      departuresText,
      heartbeatText,
      daysText, locationRequestSent,
      historyCars,
      dispatchesText;
  int arrivals = 0, departures = 0, heartbeats = 0, dispatches = 0;
  late StreamSubscription<lib.LocationResponse> respSub;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _setTexts();
    _getData();
  }

  lib.LocationResponse? locationResponse;

  void _listen() async {
    respSub = fcmBloc.locationResponseStream.listen((event) {
      pp('\n\n\n$mm locationResponseStream delivered: ${E.leaf2} ${event.vehicleReg} at ${DateTime.now().toIso8601String()}');
      locationResponse = event;
      if (mounted) {
        _navigateToMap();
      }
    });
  }

  bool busyWithMap = false;
  Future<void> _navigateToMap() async {
    pp('$mm _navigateToMap: location using response just arrived: ${locationResponse!.vehicleReg!}');
    if (busyWithMap) {
      pp('\n\n$mm ... ${E.redDot} I refuse to navigate to map, map is busy! ${E.redDot}');
      return;
    }
    // await navigateWithScale(LocationResponseMap(locationResponse: locationResponse!), context);
    if (mounted) {
      busyWithMap = true;
      await Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
            return LocationResponseMap(locationResponse: locationResponse!,);
          }));
    }
    pp('\n\n$mm _navigateToMap: .... ${E.blueDot} back from map: ${locationResponse!.vehicleReg!}');
    busyWithMap = false;
  }
  void _setTexts() async {
    var c = await prefs.getColorAndLocale();
    numberOfCars = await translator.translate('numberOfCars', c.locale);
    arrivalsText = await translator.translate('arrivals', c.locale);
    departuresText = await translator.translate('departures', c.locale);
    heartbeatText = await translator.translate('heartbeats', c.locale);
    dispatchesText = await translator.translate('dispatches', c.locale);
    ownerDashboard = await translator.translate('ownerDash', c.locale);
    daysText = await translator.translate('days', c.locale);
    historyCars = await translator.translate('historyCars', c.locale);
    requestLocation = await translator.translate('requestLocation', c.locale);
    numberOfDays = await translator.translate('numberOfDays', c.locale);
    tapToClose = await translator.translate('tapToClose', c.locale);
    locationRequestSent = await translator.translate('locationRequestSent', c.locale);

    setState(() {});
  }

  void _getData() async {
    pp('$mm ... getData ...');
    setState(() {
      busy = true;
    });
    try {
      final m = DateTime.now().toUtc().subtract(Duration(days: days));
      counts = await listApiDog.getVehicleCountsByDate(
          widget.vehicle.vehicleId!, m.toIso8601String());
      pp('$mm ... counts retrieved ...');
      for (var c in counts) {
        switch (c.description) {
          case 'VehicleArrival':
            arrivals = c.count!;
            break;
          case 'VehicleDeparture':
            departures = c.count!;
            break;
          case 'VehicleHeartbeat':
            heartbeats = c.count!;
            break;
          case 'DispatchRecord':
            dispatches = c.count!;
            break;
        }
      }
    } catch (e) {
      pp(e);
    }

    setState(() {
      busy = false;
    });
  }

  String? tapToClose, numberOfDays, requestLocation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendLocationRequest() async {
    pp('$mm ............... _sendLocationRequest ...');
    setState(() {
      busy = true;
    });

    final user = await prefs.getUser();
    final lr = lib.LocationRequest(
      ObjectId(),
      vehicleId: widget.vehicle.vehicleId,
      userId: user!.userId,
      userName: user.name,
      vehicleReg: widget.vehicle.vehicleReg,
      associationId: user.associationId,
      created: DateTime.now().toUtc().toIso8601String(),
    );
    try {
      final res = await dataApiDog.addLocationRequest(lr);
      pp('$mm ............... ${E.leaf} _sendLocationRequest seems cool ... $res');
      if (mounted) {
        showSnackBar(
            padding: 4,
            duration: const Duration(seconds: 5),
            message: locationRequestSent == null?
            'Vehicle Location Request has been sent': locationRequestSent!,
            context: context);
      }
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: widget.width == null ? bWidth : widget.width!,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              widget.onClose();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: getRoundedBorder(radius: 16),
                elevation: 4,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 24,
                    ),
                    Text(
                      widget.vehicle.vehicleReg!,
                      style: myTextStyleMediumLargeWithColor(
                          context, Theme.of(context).primaryColor, 36),
                    ),
                    Text(
                      tapToClose == null
                          ? 'Tap anywhere to close'
                          : tapToClose!,
                      style: myTextStyleTiny(context),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(numberOfDays == null
                            ? 'Number of Days'
                            : numberOfDays!),
                        const SizedBox(
                          width: 12,
                        ),
                        Text(
                          '$days',
                          style: myTextStyleMediumLargeWithColor(
                              context, Theme.of(context).primaryColor, 24),
                        ),
                        const SizedBox(
                          width: 36,
                        ),
                        DaysDropDown(
                          onDaysPicked: (d) {
                            setState(() {
                              days = d;
                            });
                            _getData();
                          },
                          hint: daysText == null ? 'Days' : daysText!,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: counts.isEmpty
                            ? const SizedBox()
                            : CountsGridWidget(
                                arrivalsText: arrivalsText!,
                                departuresText: departuresText!,
                                dispatchesText: dispatchesText!,
                                heartbeatText: heartbeatText!,
                                arrivals: arrivals,
                                departures: departures,
                                heartbeats: heartbeats,
                                dispatches: dispatches,
                              ),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          _sendLocationRequest();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(requestLocation == null
                              ? 'Request Current Location'
                              : requestLocation!),
                        )),
                    const SizedBox(
                      height: 32,
                    )
                  ],
                ),
              ),
            ),
          ),
          busy
              ? const Positioned(
                  left: 20,
                  right: 20,
                  top: 48,
                  bottom: 48,
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        backgroundColor: Colors.amber,
                      ),
                    ),
                  ))
              : const SizedBox(),
        ],
      ),
    );
  }
}
