import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/counter_bag.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/maps/location_response_map.dart';
import 'package:kasie_transie_library/maps/vehicle_monitor_map.dart';
import 'package:kasie_transie_library/messaging/fcm_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/counts_widget.dart';

import '../../bloc/data_api_dog.dart';
import '../../bloc/list_api_dog.dart';
import '../../l10n/translation_handler.dart';
import '../../utils/emojis.dart';
import '../../utils/navigator_utils_old.dart';
import '../../utils/prefs.dart';
import '../days_drop_down.dart';

class CarDetails extends StatefulWidget {
  const CarDetails(
      {super.key, required this.vehicle, this.width, required this.onClose});

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
  int days = 7;
  bool busy = false;
  String? ownerDashboard,
      numberOfCars,
      arrivalsText,
      departuresText,
      heartbeatText,
      daysText,
      locationRequestSent,
      photoRequestSent = 'Photo request sent',
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
  late StreamSubscription<lib.VehicleArrival> arrivalStreamSub;
  late StreamSubscription<lib.VehicleDeparture> departureStreamSub;
  late StreamSubscription<lib.VehicleHeartbeat> heartbeatStreamSub;

  Prefs prefs = GetIt.instance<Prefs>();

  @override
  void dispose() {
    dispatchStreamSub.cancel();
    passengerStreamSub.cancel();
    heartbeatStreamSub.cancel();
    departureStreamSub.cancel();
    arrivalStreamSub.cancel();
    respSub.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _setTexts();
    _getData(false);
  }

  lib.LocationResponse? locationResponse;
  String? routeName;

  void _listen() async {
    pp('$mm ............... listen to FCM .............................');
    arrivalStreamSub = fcmBloc.vehicleArrivalStream.listen((event) {
      pp('$mm vehicleArrivalStream delivered: ${E.leaf2} ${event.vehicleReg} at ${DateTime.now().toIso8601String()}');
      if (event.vehicleId == widget.vehicle.vehicleId) {
        arrivals++;
        if (mounted) {
          setState(() {});
        }
      }
    });
    departureStreamSub = fcmBloc.vehicleDepartureStream.listen((event) {
      pp('$mm vehicleDepartureStream delivered: ${E.leaf2} ${event.vehicleReg} at ${DateTime.now().toIso8601String()}');
      if (event.vehicleId == widget.vehicle.vehicleId) {
        departures++;
        if (mounted) {
          setState(() {});
        }
      }
    });
    respSub = fcmBloc.locationResponseStream.listen((event) {
      pp('$mm locationResponseStream delivered: ${E.leaf2} ${event.vehicleReg} at ${DateTime.now().toIso8601String()}');
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
    heartbeatStreamSub =
        fcmBloc.heartbeatStreamStream.listen((lib.VehicleHeartbeat cunt) {
      pp('$mm ... fcmBloc.heartbeatStreamStream delivered heartbeat for: ${cunt.vehicleReg}');
      if (cunt.vehicleId == widget.vehicle.vehicleId) {
        heartbeats++;
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
    var c = prefs.getColorAndLocale();
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
    photoRequestSent = await translator.translate('photoRequestSent', c.locale);

    locationRequestSent =
        await translator.translate('locationRequestSent', c.locale);

    setState(() {});
  }

  var paCounts = <lib.AmbassadorPassengerCount>[];
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  void _getData(bool refresh) async {
    pp('$mm .............................. getData ...');
    setState(() {
      busy = true;
    });
    try {
      final m = DateTime.now().toUtc().subtract(Duration(days: days));
      await listApiDog.getVehicleRouteAssignments(
          widget.vehicle.vehicleId!, refresh);
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

      final kk = jsonEncode(counts);
      final jj = jsonDecode(kk);
      pp(jj);

      for (var c in counts) {
        switch (c.description) {
          case 'VehicleArrival':
            arrivals = c.count!;
            pp('$mm ${E.blueDot} arrivals: ${c.count}');
            break;
          case 'VehicleDeparture':
            departures = c.count!;
            pp('$mm ${E.blueDot} departures: ${c.count}');

            break;
          case 'VehicleHeartbeat':
            heartbeats = c.count!;
            pp('$mm ${E.blueDot} heartbeats: ${c.count}');

            break;
          case 'DispatchRecord':
            dispatches = c.count!;
            pp('$mm ${E.blueDot} dispatches: ${c.count}');

            break;
          case 'AmbassadorPassengerCount':
            pp('$mm ${E.blueDot} totalPassengers: $totalPassengers');
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

    final user = prefs.getUser();
    final lr = lib.LocationRequest(

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
            textStyle: myTextStyleSmallBlack(context),
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
    final user = prefs.getUser();
    final m = lib.VehicleMediaRequest(

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
    if (mounted) {
      showSnackBar(
          padding: 4,
          duration: const Duration(seconds: 5),
          textStyle: myTextStyleSmallBlack(context),
          message: photoRequestSent == null
              ? 'Vehicle Photos Request has been sent'
              : photoRequestSent!,
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bWidth = MediaQuery.of(context).size.width;
    final bHeight = MediaQuery.of(context).size.height;
    final type = getThisDeviceType();

    return type == 'phone'
        ? SafeArea(
            child: Scaffold(
            appBar: AppBar(
              title: const Text('Vehicle Monitor'),
              actions: [
                IconButton(
                    onPressed: () {
                      navigateWithScale(
                          VehicleMonitorMap(vehicle: widget.vehicle), context);
                    },
                    icon: Icon(
                      Icons.map,
                      color: Theme.of(context).primaryColor,
                    ))
              ],
            ),
            body: SizedBox(
              width: widget.width == null ? bWidth : widget.width!,
              height: bHeight,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.onClose();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        shape: getDefaultRoundedBorder(),
                        elevation: 8,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 24,
                            ),
                            Text(
                              widget.vehicle.vehicleReg!,
                              style: myTextStyleMediumLargeWithColor(context,
                                  Theme.of(context).primaryColorLight, 32),
                            ),
                            SizedBox(
                              height: type == 'phone' ? 12 : 24,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  numberOfDays == null
                                      ? 'Number of Days'
                                      : numberOfDays!,
                                  style: myTextStyleTiny(context),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  '$days',
                                  style: myTextStyleMediumLargeWithColor(
                                      context,
                                      Theme.of(context).primaryColor,
                                      24),
                                ),
                                const SizedBox(
                                  width: 36,
                                ),
                                DaysDropDown(
                                  onDaysPicked: (d) {
                                    setState(() {
                                      days = d;
                                    });
                                    _getData(true);
                                  },
                                  hint: '',
                                )
                              ],
                            ),
                            gapH32,
                            SizedBox(width: 300,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _sendLocationRequest();
                                },
                                label: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(requestLocation == null
                                      ? 'Request Current Location'
                                      : requestLocation!, style: myTextStyleSmall(context),),
                                ),
                                icon: const Icon(Icons.map),
                              ),
                            ),
                            SizedBox(
                              height: type == 'phone' ? 24 : 32,
                            ),
                            SizedBox(width: 300,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _sendMediaRequest();
                                },
                                icon: const Icon(Icons.camera_alt),
                                label: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(requestMedia == null
                                      ? 'Request Photo/Video'
                                      : requestMedia!, style: myTextStyleSmall(context)),
                                ),
                              ),
                            ),
                            arrivalsText == null
                                ? gapW16
                                : Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: CountsGridWidget(
                                        arrivalsText: arrivalsText!,
                                        departuresText: departuresText!,
                                        dispatchesText: dispatchesText!,
                                        heartbeatText: heartbeatText!,
                                        arrivals: arrivals,
                                        departures: departures,
                                        heartbeats: heartbeats,
                                        dispatches: dispatches,
                                        passengerCountsText:
                                            passengerCountsText!,
                                        passengerCounts: totalPassengers,
                                      ),
                                    ),
                                  ),
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
            ),
          ))
        : SizedBox(
            width: widget.width == null ? bWidth : widget.width!,
            height: bHeight,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    widget.onClose();
                  },
                  child: Card(
                    // shape: getDefaultRoundedBorder(),
                    elevation: 4,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          widget.vehicle.vehicleReg!,
                          style: myTextStyleMediumLargeWithColor(
                              context, Theme.of(context).primaryColor, 28),
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
                        SizedBox(
                          height: type == 'phone' ? 12 : 24,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              numberOfDays == null
                                  ? 'Number of Days'
                                  : numberOfDays!,
                              style: myTextStyleTiny(context),
                            ),
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
                                _getData(true);
                              },
                              hint: daysText == null ? 'Days' : daysText!,
                            )
                          ],
                        ),
                        Expanded(
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
                        TextButton(
                            onPressed: () {
                              _sendLocationRequest();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(requestLocation == null
                                  ? 'Request Current Location'
                                  : requestLocation!),
                            )),
                        SizedBox(
                          height: type == 'phone' ? 8 : 32,
                        ),
                        TextButton(
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
