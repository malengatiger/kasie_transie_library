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
  int days = 1;
  bool busy = false;
  String? ownerDashboard,
      numberOfCars,
      arrivalsText,
      departuresText,
      heartbeatText,
      daysText,
      locationRequestSent,
      historyCars,
      requestMedia,
      passengerCountsText,
      dispatchesText;
  int arrivals = 0,
      departures = 0,
      heartbeats = 0,
      dispatches = 0,
      totalPassengers = 0;
  late StreamSubscription<lib.LocationResponse> respSub;
  late StreamSubscription<lib.DispatchRecord> dispatchStreamSub;
  late StreamSubscription<lib.AmbassadorPassengerCount> passengerStreamSub;
  @override
  void dispose() {
    dispatchStreamSub.cancel();
    passengerStreamSub.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _setTexts();
    _getData();
  }

  lib.LocationResponse? locationResponse;
  String? routeName;
  void _listen() async {
    respSub = fcmBloc.locationResponseStream.listen((event) {
      pp('\n\n\n$mm locationResponseStream delivered: ${E.leaf2} ${event.vehicleReg} at ${DateTime.now().toIso8601String()}');
      locationResponse = event;
      if (mounted) {
        _navigateToMap();
      }
    });
    dispatchStreamSub =
        fcmBloc.dispatchStream.listen((lib.DispatchRecord dRec) {
      pp('$mm ... fcmBloc.dispatchStream delivered dispatch for: ${dRec.vehicleReg}');
      if (dRec.vehicleId == widget.vehicle.vehicleId) {
        dispatches++;
        routeName = dRec.routeName;
        totalPassengers += dRec.passengers!;

        if (mounted) {
          setState(() {});
        }
      }
    });
    passengerStreamSub = fcmBloc.passengerCountStream
        .listen((lib.AmbassadorPassengerCount cunt) {
      pp('$mm ... fcmBloc.passengerCountStream delivered count for: ${cunt.vehicleReg}');
      if (cunt.vehicleId == widget.vehicle.vehicleId) {
        totalPassengers += cunt.passengersIn!;
        routeName = cunt.routeName;

        if (mounted) {
          setState(() {});
        }
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
      await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return LocationResponseMap(
          locationResponse: locationResponse!,
        );
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
    requestMedia = await translator.translate('requestMedia', c.locale);
    passengerCountsText = await translator.translate('passengersIn', c.locale);

    locationRequestSent =
        await translator.translate('locationRequestSent', c.locale);

    setState(() {});
  }

  var paCounts = <lib.AmbassadorPassengerCount>[];
  void _getData() async {
    pp('$mm ... getData ...');
    setState(() {
      busy = true;
    });
    try {
      final m = DateTime.now().toUtc().subtract(Duration(days: days));
      counts = await listApiDog.getVehicleCountsByDate(
          widget.vehicle.vehicleId!, m.toIso8601String());
      paCounts = await listApiDog.getAmbassadorPassengerCountsByVehicle(
          vehicleId: widget.vehicle.vehicleId!,
          refresh: true,
          startDate: m.toIso8601String());
      totalPassengers = 0;
      for (var pa in paCounts) {
        totalPassengers += pa.passengersIn!;
      }

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
          case 'AmbassadorPassengerCount':
            totalPassengers = c.count!;
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
            message: locationRequestSent == null
                ? 'Vehicle Location Request has been sent'
                : locationRequestSent!,
            context: context);
      }
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  void _sendMediaRequest() async {
    pp('$mm r_sendMediaRequest ...........');
    final user = await prefs.getUser();
    final m = lib.VehicleMediaRequest(
      ObjectId(),
      vehicleReg: widget.vehicle.vehicleReg,
      vehicleId: widget.vehicle.vehicleId,
      userId: user!.userId,
      created: DateTime.now().toUtc().toIso8601String(),
      associationId: user.associationId,
      addVideo: true,
      requesterId: user.userId,
      requesterName: user.name,
    );
    final result = await dataApiDog.addVehicleMediaRequest(m);
    pp('$mm result of backend call ...');
    myPrettyJsonPrint(result.toJson());
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
                      height: 8,
                    ),
                    routeName == null
                        ? const SizedBox()
                        : Text(
                            routeName!,
                            style: myTextStyleMediumLargeWithColor(context,
                                Theme.of(context).primaryColorLight, 16),
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
                      height: 0,
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
                                passengerCountsText: passengerCountsText!,
                                passengerCounts: totalPassengers,
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
                    ),
                    ElevatedButton(
                        onPressed: () {
                          _sendMediaRequest();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(requestMedia == null
                              ? 'Request Photo/Video'
                              : requestMedia!),
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
