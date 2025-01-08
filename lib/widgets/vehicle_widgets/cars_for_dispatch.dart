import 'dart:async';

import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/messaging/fcm_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/widgets/scanners/kasie/last_scanner_widget.dart';
import 'package:kasie_transie_library/widgets/vehicle_widgets/vehicle_search.dart';

import '../../maps/map_viewer.dart';
import 'dispatch_taxi.dart';

class CarForDispatch extends StatefulWidget {
  const CarForDispatch({super.key, required this.route});

  final lib.Route route;

  @override
  State<CarForDispatch> createState() => _CarForDispatchState();
}

class _CarForDispatchState extends State<CarForDispatch> {
  static const mm = '🍄🍄🍄🍄CarForDispatch 🍄';

  FCMService fcmService = GetIt.instance<FCMService>();
  late StreamSubscription commuterRequestSub;

  List<lib.CommuterRequest> requests = [];

  @override
  void initState() {
    super.initState();
    _listen();
    _startTimer();
  }

  _listen() async {
    await fcmService.initialize();
    await fcmService.subscribeForRouteCommuterRequests(
        routeId: widget.route.routeId!, app: 'Marshal');

    commuterRequestSub = fcmService.commuterRequestStream.listen((req) {
      pp('\n\n$mm fcmService.commuterRequestStream delivered a request: ');
      myPrettyJsonPrint(req.toJson());
      requests.insert(0, req);
      _filterCommuterRequests(requests);
      if (mounted) {
        setState(() {});
      }
    });
  }

  late Timer timer;

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      pp('$mm Timer tick #${timer.tick} - _filterCommuterRequests ...');
      _filterCommuterRequests(requests);
    });
  }

  List<lib.CommuterRequest> _filterCommuterRequests(
      List<lib.CommuterRequest> requests) {
    pp('$mm _filterCommuterRequests : ${requests.length}');

    List<lib.CommuterRequest> filtered = [];
    DateTime now = DateTime.now().toUtc();
    for (var r in requests) {
      var date = DateTime.parse(r.dateRequested!);
      var difference = now.difference(date);
      pp('$mm _filterCommuterRequests difference: $difference');

      if (difference <= const Duration(hours: 1)) {
        filtered.add(r);
      }
    }
    pp('$mm _filterCommuterRequests filtered: ${filtered.length}');
    setState(() {
      requests = filtered;
    });
    return filtered;
  }

  _search() async {
    var vehicle = await NavigationUtils.navigateTo(
      context: context,
      widget: VehicleSearch(
        associationId: widget.route.associationId!,
      ),
    );

    if (vehicle != null) {
      pp('$mm vehicle found: ${vehicle!.vehicleReg}');
      _navigateToDispatch(vehicle);
    }
  }

  void _navigateToDispatch(lib.Vehicle vehicle) {
    pp('$mm vehicle to dispatch: ${vehicle.vehicleReg} on ${widget.route.name}');

    if (mounted) {
      NavigationUtils.navigateTo(
        context: context,
        widget: DispatchTaxi(
            route: widget.route,
            onDispatched: (dr) {
              pp('$mm DispatchTaxi onDispatched fired : Car dispatched: ');
              myPrettyJsonPrint(dr.toJson());
            },
            vehicle: vehicle),
      );
    }
  }

  _scan() async {
    var vehicle = await NavigationUtils.navigateTo(
      context: context,
      widget: const ScanTaxi(),
    );

    await fcmService.subscribeForRouteCommuterRequests(
        routeId: widget.route.routeId!, app: 'Marshal');
    if (vehicle != null && vehicle is lib.Vehicle) {
      pp('$mm  _scan(): ....... vehicle scanned for dispatch: ${vehicle!.vehicleReg} on ${widget.route.name}');
      _navigateToDispatch(vehicle);
    } else {
      pp('$mm  _scan(): ... something wrong here : $vehicle');
      var car = lib.Vehicle.fromJson(vehicle);
      _navigateToDispatch(car);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Taxi Dispatch', style: myTextStyle()), actions: [
        IconButton(
            onPressed: () {
              NavigationUtils.navigateTo(
                  context: context,
                  widget: MapViewer(
                    route: widget.route,
                    commuterRequests: requests,
                  ));
            },
            icon: const FaIcon(FontAwesomeIcons.mapLocation))
      ]),
      body: SafeArea(
          child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Route'),
                gapH8,
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            widget.route.name!,
                            style: myTextStyle(
                                fontSize: 20,
                                weight: FontWeight.w900,
                                color: Theme.of(context).primaryColor),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                gapH32,
                gapH32,
                gapH32,
                Text('Select a taxi using one or the other method',
                    style: myTextStyle(color: Colors.grey)),
                gapH32,
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                      style: const ButtonStyle(
                          elevation: WidgetStatePropertyAll(8),
                          backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                      onPressed: _search,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Search Taxi',
                          style: myTextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      )),
                ),
                gapH32,
                gapH32,
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                      onPressed: _scan,
                      style: const ButtonStyle(
                          elevation: WidgetStatePropertyAll(8),
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.green)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Scan Taxi',
                          style: myTextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
          Positioned(
            right: 32,
            bottom: 16,
            child: ElevatedButton(
              style: const ButtonStyle(elevation: WidgetStatePropertyAll(4)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Done'),
              ),
            ),
          ),
          requests.isNotEmpty
              ? Positioned(
                  top: 24,
                  left: 24,
                  right: 24,
                  child: Row(
                    children: [
                      Text(
                        'Passengers on Route',
                        style: myTextStyle(color: Colors.grey, weight: FontWeight.w900),
                      ),
                      gapW8,
                      bd.Badge(
                        badgeContent: Text(
                          '${_getPassengers()}',
                          style: myTextStyle(color: Colors.white,, weight: FontWeight.w900),
                        ),
                        badgeStyle: bd.BadgeStyle(
                          elevation: 8,
                          padding: EdgeInsets.all(16),
                          badgeColor: Colors.red,
                        ),
                      ),
                      gapW8,
                      Text('Requests', style: myTextStyle(color: Colors.grey, fontSize: 12)),
                      gapW8,
                      bd.Badge(
                        badgeContent: Text(
                          '${requests.length}',
                          style: myTextStyle(color: Colors.white),,
                        ),
                        badgeStyle: bd.BadgeStyle(
                          elevation: 8,
                          padding: EdgeInsets.all(12),
                          badgeColor: Colors.grey,
                        ),
                      ),
                    ],
                  ))
              : gapW32,
        ],
      )),
    );
  }

  int _getPassengers() {
    var cnt = 0;
    for (var r in requests) {
      cnt += r.numberOfPassengers!;
    }
    return cnt;
  }
}

class ScanTaxi extends StatefulWidget {
  const ScanTaxi({super.key});

  @override
  State<ScanTaxi> createState() => _ScanTaxiState();
}

class _ScanTaxiState extends State<ScanTaxi> {
  @override
  void initState() {
    super.initState();
    _navigateToScanner();
  }

  static const mm = '🍎🍎🍎🍎 ScanTaxi 🍎';

  void _navigateToScanner() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      try {
        await NavigationUtils.navigateTo(
            context: context,
            widget: LastScannerWidget(onScanned: (json) {
              pp('$mm ScanTaxi: onScanned; ... will pop');
              if (json['vehicleId'] != null && json['vehicleReg'] != null) {
                myPrettyJsonPrint(json);
                var car = lib.Vehicle.fromJson(json);
                Navigator.of(context).pop(car);
              } else {
                showErrorToast(
                    duration: const Duration(seconds: 2),
                    toastGravity: ToastGravity.BOTTOM,
                    message: 'The QR Code scanned is not a vehicle',
                    context: context);
              }
            }));
      } catch (e, s) {
        pp('$e $s');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Scan Taxi'), actions: [
          IconButton(
              onPressed: () {},
              icon: const FaIcon(FontAwesomeIcons.mapLocation))
        ]),
        body: SafeArea(
            child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: 300,
                child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: const WidgetStatePropertyAll(8),
                    backgroundColor:
                        WidgetStatePropertyAll(Colors.blue.shade600),
                  ),
                  onPressed: () {
                    _navigateToScanner();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Start Scan',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        )));
  }
}
