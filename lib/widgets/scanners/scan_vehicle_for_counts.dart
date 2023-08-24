import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/local_finder.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/qr_scanner.dart';
import 'package:kasie_transie_library/widgets/vehicle_passenger_count.dart';

import '../../utils/emojis.dart';

class ScanVehicleForCounts extends StatefulWidget {
  const ScanVehicleForCounts({Key? key}) : super(key: key);

  @override
  ScanVehicleForCountsState createState() => ScanVehicleForCountsState();
}

class ScanVehicleForCountsState extends State<ScanVehicleForCounts>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final mm = '☕️☕️☕️☕️☕️☕️☕️☕️☕️ ScanVehicleForCounts: 🍎🍎';

  lib.Vehicle? vehicle;
  List<lib.Route> routes = [];
  lib.Route? selectedRoute;
  bool busy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _findNearestRoutes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _findNearestRoutes() async {
    setState(() {
      busy = true;
    });
    try {
      final loc = await locationBloc.getLocation();
      routes = await localFinder.findNearestRoutes(
          latitude: loc.latitude,
          longitude: loc.longitude,
          radiusInMetres: 100);
    } catch (e) {
      pp(e);
    }

    setState(() {
      busy = false;
    });
  }

  void navigateToPassengerCount() async {
    if (selectedRoute == null) {
      showSnackBar(
          message: selectRoute == null ? 'Please select Route' : selectRoute!,
          context: context);
      return;
    }
    if (vehicle == null) {
      showSnackBar(
          message: scanVehicle == null ? 'Please scan vehicle' : scanVehicle!,
          context: context);
      return;
    }
    //
    pp('$mm ........ navigate to VehicleMediaHandler ... ${E.redDot} for car: ${vehicle!
        .vehicleReg}');

    Navigator.of(context).pop();

    navigateWithScale(VehiclePassengerCount(
      vehicle: vehicle!,
      route: selectedRoute!,
    ), context);
    //
    setState(() {
      showStartButton = false;
      //vehicle = null;
    });
  }

  void onCarScanned(lib.Vehicle car) async {
    pp('$mm ... onCarScanned; scanner returned ${vehicle!.vehicleReg} ...');
    vehicle = car;
    _checkStart();
    if (selectedRoute == null) {
      setState(() {
        _showRoutes = true;
      });
    }
  }

  void onError() {}
  String? passengerCounts,
      selectRoute,
      scanVehicle,
      scanTheVehicle,
      startPassengerCount,
      noVehicleScanned;

  void _setTexts() async {
    pp('$mm ... _setTexts ...');
    final c = await prefs.getColorAndLocale();
    passengerCounts = await translator.translate('passengerCount', c.locale);
    scanVehicle = await translator.translate('scanVehicle', c.locale);
    scanTheVehicle = await translator.translate('scanTheVehicle', c.locale);
    startPassengerCount =
    await translator.translate('startPassengerCount', c.locale);
    noVehicleScanned = await translator.translate('noVehicleScanned', c.locale);
    selectRoute = await translator.translate('selectRoute', c.locale);

    pp(
        '$mm ... _setTexts ... setting state, passengerCounts: $passengerCounts with locale: ${c
            .locale}');

    setState(() {});
  }

  bool _showRoutes = false;
  bool showStartButton = true;

  void _checkStart() {
    if (vehicle == null) {
      pp('$mm _checkStart ... car is null');
      return;
    }
    if (selectedRoute == null) {
      pp('$mm _checkStart ... selectedRoute is null');
      setState(() {
        _showRoutes = true;
      });
      return;
    }

    pp('$mm _checkStart ... setState  showStartButton true');

    navigateToPassengerCount();
  }

  void onRouteSelected(lib.Route route) {
    selectedRoute = route;
    _showRoutes = false;
    _checkStart();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(

          appBar: AppBar(
            leading: const SizedBox(),

            title: Text(
                passengerCounts == null
                    ? 'Passenger Counts'
                    : passengerCounts!),
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(420),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 64,
                    ),
                    Text(
                      scanVehicle == null ? 'Scan Vehicle' : scanVehicle!,
                      style: myTextStyleMediumLargeWithColor(
                          context, Theme
                          .of(context)
                          .primaryColor, 28),
                    ),
                    Text(
                      scanTheVehicle == null
                          ? 'Scan the vehicle that you want to work with'
                          : scanTheVehicle!,
                      style: myTextStyleSmall(context),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    GestureDetector(
                      onTap: () {
                        pp('$mm .... will try to restart a scan ...');
                      },
                      child: QRScanner(
                        onCarScanned: (car) {
                          setState(() {
                            vehicle = car;
                          });
                          onCarScanned(car);
                        },
                        onUserScanned: (u) {},
                        onError: onError,
                        quitAfterScan: true,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                )),
            actions: [
              IconButton(onPressed: (){
                Navigator.of(context).pop();
              }, icon: Icon(Icons.close, color: Theme.of(context).primaryColor,)),
            ],
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    vehicle != null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${vehicle!.vehicleReg}',
                              style: myTextStyleMediumLargeWithColor(context,
                                  Theme
                                      .of(context)
                                      .primaryColor, 40),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        selectedRoute == null
                            ? TextButton(
                            onPressed: () {
                              setState(() {
                                _showRoutes = true;
                              });
                            },
                            child: Text(selectRoute == null
                                ? 'Please select Route'
                                : selectRoute!))
                            : TextButton(
                            onPressed: () {
                              setState(() {
                                _showRoutes = true;
                              });
                            },
                            child: Text(
                              '${selectedRoute!.name}',
                              style: myTextStyleMediumBold(context),
                            )),
                        const SizedBox(
                          height: 8,
                        ),
                        showStartButton ? ElevatedButton(
                            style: const ButtonStyle(
                                elevation: MaterialStatePropertyAll(8.0)),
                            onPressed: () {
                              navigateToPassengerCount();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(startPassengerCount == null
                                  ? 'Start Passenger Count'
                                  : startPassengerCount!),
                            )) : const SizedBox(),
                      ],
                    )
                        : Text(
                      noVehicleScanned == null
                          ? 'No Vehicle Scanned yet'
                          : noVehicleScanned!,
                      style: myTextStyleMediumLargeWithColor(
                          context, Colors.grey.shade700, 14),
                    ),
                  ],
                ),
              ),
              _showRoutes
                  ? Positioned(
                  child: SizedBox(
                      height: 300,
                      child: Card(
                        shape: getDefaultRoundedBorder(),
                        elevation: 2,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 24,
                            ),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: routes.length,
                                  itemBuilder: (_, index) {
                                    final route = routes.elementAt(index);
                                    return GestureDetector(
                                      onTap: () {
                                        onRouteSelected(route);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Card(
                                          shape: getDefaultRoundedBorder(),
                                          elevation: 8,
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.airport_shuttle,
                                              color: Theme
                                                  .of(context)
                                                  .primaryColor,
                                            ),
                                            title: Text('${route.name}',
                                              style: myTextStyleSmall(
                                                  context),),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      )))
                  : const SizedBox(),
            ],
          ),
        ));
  }
}
