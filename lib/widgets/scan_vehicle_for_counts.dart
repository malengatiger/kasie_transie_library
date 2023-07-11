import 'package:flutter/material.dart';
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/local_finder.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/qr_scanner.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/widgets/vehicle_media_handler.dart';
import 'package:kasie_transie_library/widgets/vehicle_passenger_count.dart';

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
      showSnackBar(message: 'Please select Route', context: context);
      return;
    }
    pp('$mm ... navigate to VehicleMediaHandler ... for car: ${vehicle!.vehicleReg}');
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return VehiclePassengerCount(
        vehicle: vehicle!,
        route: selectedRoute!,
      );
    }));
  }

  void onCarScanned(lib.Vehicle car) async {
    pp('$mm ... onCarScanned; scanner returned ${vehicle!.vehicleReg} ...');
    setState(() {
      vehicle = car;
    });

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

    pp('$mm ... _setTexts ... setting state, passengerCounts: $passengerCounts with locale: ${c.locale}');

    setState(() {});
  }

  bool _showRoutes = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
            passengerCounts == null ? 'Passenger Counts' : passengerCounts!),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(380),
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Text(
                  scanVehicle == null ? 'Scan Vehicle' : scanVehicle!,
                  style: myTextStyleMediumLargeWithColor(
                      context, Theme.of(context).primaryColor, 28),
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
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${vehicle!.vehicleReg}',
                                style: myTextStyleMediumLargeWithColor(context,
                                    Theme.of(context).primaryColor, 40),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 24,
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
                            height: 24,
                          ),
                          ElevatedButton(
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
                              )),
                        ],
                      )
                    : Text(
                        noVehicleScanned == null
                            ? 'No Vehicle Scanned yet'
                            : noVehicleScanned!,
                        style: myTextStyleMediumLargeWithColor(
                            context, Colors.grey.shade700, 17),
                      ),
              ],
            ),
          ),
          _showRoutes
              ? Positioned(
                  child: SizedBox(
                      height: 300,
                      child: Card(
                        shape: getRoundedBorder(radius: 16),
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
                                        setState(() {
                                          selectedRoute = route;
                                          _showRoutes = false;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Card(
                                          shape: getRoundedBorder(radius: 16),
                                          elevation: 8,
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.airport_shuttle,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            title: Text('${route.name}', style: myTextStyleSmall(context),),
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
