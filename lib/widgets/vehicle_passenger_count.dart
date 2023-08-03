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
import 'package:realm/realm.dart';

import '../maps/route_map.dart';
import '../utils/parsers.dart';
import 'drop_down_widgets.dart';

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

  var currentCounts = <lib.AmbassadorPassengerCount>[];

  bool busy = false;
  bool showAllCounts = false;
  lib.User? user;
  String? passengersInText,
      passengerCounter,
      passengersOutText,
      currentPassengersText,
      passengerCountsaved,
      lastCount,
      errorCount,
      saveCounts;

  Future _setTexts() async {
    final c = await prefs.getColorAndLocale();
    passengersInText = await translator.translate('passengersIn', c.locale);
    passengersOutText = await translator.translate('passengersOut', c.locale);
    currentPassengersText =
    await translator.translate('currentPassengers', c.locale);
    saveCounts = await translator.translate('saveCounts', c.locale);
    passengerCounter = await translator.translate('passengerCount', c.locale);
    lastCount = await translator.translate('lastCount', c.locale);
    passengerCountsaved =
    await translator.translate('passengerCountsaved', c.locale);
    errorCount = await translator.translate('errorCount', c.locale);

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
      pp('$mm ... received prior VehiclePassengerCounts ...${E
          .appleRed} ${passengerCounts.length}');
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
        ownerId: widget.vehicle.ownerId,
        ownerName: widget.vehicle.ownerName,
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
      currentCounts.add(passengerCount);
      _calculateCurrentPassengers();
      if (mounted) {
        showToast(
            duration: const Duration(seconds: 2),
            padding: 20,
            backgroundColor: Theme
                .of(context)
                .primaryColorDark,
            message: passengerCountsaved == null
                ? 'Passenger Counts saved, thank you!'
                : passengerCountsaved!,
            context: context);
      }
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
      showSubmit = false;
    });
  }

  void _navigateToPhotoHandler() {
    pp('$mm ... _navigateToPhotoHandler');

    navigateWithScale(
        PhotoHandler(
            vehicle: widget.vehicle,
            onPhotoTaken: (file, thumb) {
              pp('$mm photo and thumbnail files returned from handler');
            }),
        context);
  }

  void _calculateCurrentPassengers() {
    pp('$mm ... _calculateCurrentPassengers');
    if (currentCounts.isEmpty) {
      return;
    }
    if (currentCounts.length == 1) {
      setState(() {
        currentPassengers = currentCounts.first.passengersIn!;
      });
      return;
    }
    //
    var startPassengers = 0;
    for (var count in currentCounts) {
      startPassengers += count.passengersIn!;
      startPassengers -= count.passengersOut!;
    }
    currentPassengers = startPassengers;
  }

  int passengersIn = 0,
      passengersOut = 0,
      currentPassengers = 0;
  bool showSubmit = false;

  void _navigateToRouteMap() {
    navigateWithScale(RouteMap(route: widget.route), context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: const SizedBox(),
            title: Text(
                passengerCounter == null
                    ? 'Passenger Counter'
                    : passengerCounter!),
            actions: [
              IconButton(
                  onPressed: () {
                    _navigateToPhotoHandler();
                  },
                  icon: Icon(
                    Icons.camera_alt,
                    color: Theme
                        .of(context)
                        .primaryColor,
                  )),
              IconButton(
                  onPressed: () {
                    _navigateToRouteMap();
                  },
                  icon: Icon(Icons.map, color: Theme
                      .of(context)
                      .primaryColor)),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.close,
                    color: Theme
                        .of(context)
                        .primaryColor,
                  )),
            ],
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: getDefaultRoundedBorder(),
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
                                context, Theme
                                .of(context)
                                .primaryColor, 32),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Text(
                        '${widget.route.name}',
                        style: myTextStyleMediumLargeWithColor(
                            context, Theme
                            .of(context)
                            .primaryColorLight, 14),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          shape: getDefaultRoundedBorder(),
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
                                        showSubmit = true;
                                      });
                                    },
                                    color: Colors.green.shade800,
                                    fontSize: 28, count: 30,),
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
                          shape: getDefaultRoundedBorder(),
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
                                      if (number > currentPassengers) {
                                        showSnackBar(
                                            duration: const Duration(
                                                seconds: 10),
                                            backgroundColor:
                                            Theme
                                                .of(context)
                                                .primaryColorDark,
                                            message: errorCount == null
                                                ? "There can be more than the current number of people in the taxi. Please check the number and try again "
                                                : errorCount!,
                                            context: context);
                                        return;
                                      }
                                      setState(() {
                                        passengersOut = number;
                                        showSubmit = true;
                                      });
                                    },
                                    color: Colors.red.shade700,
                                    fontSize: 28, count: 30,),
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
                          shape: getDefaultRoundedBorder(),
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currentPassengersText == null
                                      ? 'Current Passengers'
                                      : currentPassengersText!,
                                  style: myTextStyleSmall(context),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                // NumberDropDown(
                                //     onNumberPicked: (number) {
                                //       setState(() {
                                //         currentPassengers = number;
                                //         showSubmit = true;
                                //       });
                                //     },
                                //     color: Colors.blue.shade700,
                                //     fontSize: 28),
                                // const SizedBox(
                                //   width: 24,
                                // ),
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
                      showSubmit
                          ? SizedBox(
                        width: 300,
                        child: ElevatedButton(
                            style: const ButtonStyle(
                              elevation: MaterialStatePropertyAll(8.0),
                            ),
                            onPressed: () {
                              _submitCounts();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(saveCounts == null
                                  ? 'Save Counts'
                                  : saveCounts!),
                            )),
                      )
                          : const SizedBox(),
                      const SizedBox(
                        height: 32,
                      ),
                      lastDate == null
                          ? const SizedBox()
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(lastCount == null ? 'Last Count' : lastCount!),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            '$lastDate',
                            style: myTextStyleMediumLargeWithColor(
                                context, Theme
                                .of(context)
                                .primaryColor, 24),
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
