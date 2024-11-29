import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/route_list_minimum.dart';
import 'package:kasie_transie_library/widgets/vehicle_passenger_count.dart';
import 'package:page_transition/page_transition.dart';

import '../../bloc/list_api_dog.dart';
import '../../utils/emojis.dart';
import 'kasie/kasie_ai_scanner.dart';

class ScanVehicleForCounts extends StatefulWidget {
  const ScanVehicleForCounts({super.key});

  @override
  ScanVehicleForCountsState createState() => ScanVehicleForCountsState();
}

class ScanVehicleForCountsState extends State<ScanVehicleForCounts>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final mm = '☕️☕️☕️☕️☕️☕️☕️☕️☕️ ScanVehicleForCounts: 🍎🍎';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

  lib.Vehicle? vehicle;
  List<lib.Route> routes = [];
  lib.Route? selectedRoute;
  bool busy = false;
  lib.Association? association;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _getAssociation();
    // _findNearestRoutes();
  }

  void _getAssociation() async {
    association = prefs.getAssociation();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // void _findNearestRoutes() async {
  //   setState(() {
  //     busy = true;
  //   });
  //   try {
  //     final loc = await locationBloc.getLocation();
  //     routes = await localFinder.findNearestRoutes(
  //         latitude: loc.latitude,
  //         longitude: loc.longitude,
  //         radiusInMetres: 100);
  //   } catch (e) {
  //     pp(e);
  //   }
  //   pp('$mm ........ _findNearestRoutes: ${routes.length} ... ${E.redDot} ');
  //
  //   setState(() {
  //     busy = false;
  //     // _showRoutes = true;
  //   });
  // }

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
    pp('$mm ........ navigate to VehicleMediaHandler ... ${E.redDot} for car: ${vehicle!.vehicleReg}');

    NavigationUtils.navigateTo(
        context: context,
        widget: VehiclePassengerCount(
          vehicle: vehicle!,
          route: selectedRoute!,
        ),
        transitionType: PageTransitionType.leftToRight);

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
    final c = prefs.getColorAndLocale();
    passengerCounts = await translator.translate('passengerCount', c.locale);
    scanVehicle = await translator.translate('scanVehicle', c.locale);
    scanTheVehicle = await translator.translate('scanTheVehicle', c.locale);
    startPassengerCount =
        await translator.translate('startPassengerCount', c.locale);
    noVehicleScanned = await translator.translate('noVehicleScanned', c.locale);
    selectRoute = await translator.translate('selectRoute', c.locale);

    pp('$mm ... _setTexts ... setting state, passengerCounts: $passengerCounts with locale: ${c.locale}');

    setState(() {});
  }

  bool _showRoutes = true;
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

  void _navigateToScan() async {
    final mCar = await NavigationUtils.navigateTo(
        context: context,
        widget: KasieAIScanner(onScanned: (json ) {
          onCarScanned(lib.Vehicle.fromJson(json));
        },),
        transitionType: PageTransitionType.leftToRight);
    if (mCar != null) {
      vehicle = lib.Vehicle.fromJson(mCar);
      pp('$mm ... back from on car scanned: ${vehicle!.vehicleReg}');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: Text(
            passengerCounts == null ? 'Passenger Counts' : passengerCounts!),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(_showRoutes ? 28 : 400),
            child: _showRoutes
                ? gapH16
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      gapH16,
                      selectedRoute == null
                          ? gapW16
                          : SizedBox(
                              height: 80,
                              child: Column(
                                children: [
                                  const Text('Taxi Route Name'),
                                  gapH16,
                                  Text(
                                    '${selectedRoute!.name}',
                                    style: myTextStyleMediumLargeWithColor(
                                        context,
                                        Theme.of(context).primaryColor,
                                        18),
                                  ),
                                ],
                              ),
                            ),
                      gapH32,
                      gapH32,
                      GestureDetector(
                        onTap: () {
                          _navigateToScan();
                        },
                        child: Text(
                          scanVehicle == null ? 'Scan Vehicle' : scanVehicle!,
                          style: myTextStyleMediumLargeWithColor(
                              context, Theme.of(context).primaryColor, 28),
                        ),
                      ),
                      gapH32,
                      GestureDetector(
                        onTap: () {
                          _navigateToScan();
                        },
                        child: Text(
                          scanTheVehicle == null
                              ? 'Scan the vehicle that you want to work with'
                              : scanTheVehicle!,
                          style: myTextStyleSmall(context),
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  )),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              )),
        ],
      ),
      body: Stack(
        children: [
          _showRoutes
              ? Positioned(
                  child: association == null
                      ? gapW16
                      : RouteListMinimum(
                          isMappable: false,
                          onRoutePicked: (route) {
                            setState(() {
                              selectedRoute = route;
                              _showRoutes = false;
                            });
                          },
                          association: association!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      gapH8,
                      vehicle != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                gapH16,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${vehicle!.vehicleReg}',
                                      style: myTextStyleMediumLargeWithColor(
                                          context,
                                          Theme.of(context).primaryColor,
                                          40),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                showStartButton
                                    ? ElevatedButton(
                                        style: const ButtonStyle(
                                            elevation:
                                                WidgetStatePropertyAll(8.0)),
                                        onPressed: () {
                                          navigateToPassengerCount();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                              startPassengerCount == null
                                                  ? 'Start Passenger Count'
                                                  : startPassengerCount!),
                                        ))
                                    : const SizedBox(),
                              ],
                            )
                          : gapW16,
                    ],
                  ),
                ),
        ],
      ),
    ));
  }
}
