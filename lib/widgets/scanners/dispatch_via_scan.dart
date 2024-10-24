import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/widgets/passenger_count.dart';
import 'package:kasie_transie_library/widgets/qr_scanner.dart';
import 'package:kasie_transie_library/widgets/route_widget.dart';
import 'package:badges/badges.dart' as bd;

import '../../isolates/local_finder.dart';
import '../media_reminder.dart';
import 'dispatch_helper.dart';


class DispatchViaScan extends StatefulWidget {
  const DispatchViaScan({super.key});

  @override
  DispatchViaScanState createState() => DispatchViaScanState();
}

class DispatchViaScanState extends State<DispatchViaScan>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  DeviceLocationBloc locationBloc = GetIt.instance<DeviceLocationBloc>();
  final mm = '${E.heartOrange}${E.heartOrange}${E.heartOrange}${E.heartOrange}'
      ' ScanDispatch: ${E.heartOrange}${E.heartOrange} ';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

  String? dispatchText,
      selectRouteText,
      scannerWaiting,
      cancelText,
      working,
      dispatchTaxi,
      confirmDispatch,
      no,
      yes,
      dispatchFailed,
      allPhotosVideos;
  lib.Vehicle? scannedVehicle;
  lib.Route? selectedRoute;
  bool quitAfterScan = false;
  var cars = <lib.Vehicle>[];
  var dispatches = <lib.DispatchRecord>[];
  lib.User? user;
  var requests = <lib.VehicleMediaRequest>[];

  // var routeLandmarks = <lib.RouteLandmark>[];
  var routes = <lib.Route>[];
  bool _showRoutes = true, busy = false;
  bool _showDispatches = false, _showDispatchButton = false;
  Future _setTexts() async {
    final c = prefs.getColorAndLocale();
    final loc = c.locale;
    dispatchText = await translator.translate('dispatch', loc);
    selectRouteText = await translator.translate('pleaseSelectRoute', loc);
    scannerWaiting = await translator.translate('scannerWaiting', loc);
    cancelText = await translator.translate('cancel', loc);
    working = await translator.translate('working', loc);
    confirmDispatch = await translator.translate('confirmDispatch', loc);
    no = await translator.translate('no', loc);
    yes = await translator.translate('yes', loc);
    dispatchTaxi = await translator.translate('dispatchTaxi', loc);

    setState(() {});
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _getRoutes();
    _getAssociationVehicleMediaRequests(false);
  }

  Future _getAssociationVehicleMediaRequests(bool refresh) async {
    user = prefs.getUser();
    final startDate = DateTime.now()
        .toUtc()
        .subtract(const Duration(days: 30))
        .toIso8601String();

    requests = await listApiDog.getAssociationVehicleMediaRequests(
        user!.associationId!, startDate, refresh);
  }

  Future _getRoutes() async {
    final loc = await locationBloc.getLocation();
    //
    // const liist  = await localFinder.findNearestRoutes(
    //     latitude: loc.latitude,
    //     longitude: loc.longitude,
    //     radiusInMetres: 500.0);

    //check ... selected ...
    final prevRoute = prefs.getRoute();
    bool found = false;
    if (selectedRoute != null) {
      for (var value in routes) {
        if (value.routeId == selectedRoute!.routeId) {
          found = true;
          break;
        }
      }
    }
    if (prevRoute != null) {
      for (var value in routes) {
        if (value.routeId == prevRoute.routeId) {
          found = true;
          selectedRoute = value;
          break;
        }
      }
    }
    if (!found) {
      selectedRoute = null;
      _showRoutes = true;
      _showDispatches = false;
    } else {
      pp('$mm ... previous route found: ${selectedRoute!.name}');
      _showRoutes = false;
      _showDispatches = true;
    }
    setState(() {});
    pp('$mm ... routes found around here: ${routes.length} ... _showRoutes: $_showRoutes');
  }

  lib.RouteLandmark? selectedRouteLandmark;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  onCarScanned(lib.Vehicle car) {
    scannedVehicle = car;
    if (selectedRoute == null) {
      showSnackBar(message: 'Please select route', context: context);
      return;
    }
    _confirmPassengerCount();
  }

  void onRoutePicked(lib.Route route) async {
    selectedRoute = route;
     prefs.saveRoute(route);
    setState(() {
      _showRoutes = false;
      _showDispatches = true;
    });
  }

  bool _checkIfVehicleMediaRequested() {
    if (scannedVehicle == null) {
      return false;
    }
    for (var value in requests) {
      if (value.vehicleId == scannedVehicle!.vehicleId) {
        return true;
      }
    }
    return false;
  }

  onError() {}
  Future _doDispatch() async {
    pp('$mm ... start dispatch for .... ${scannedVehicle!.vehicleReg}');
    _confirmPassengerCount();
    //await _sendTheDispatchRecord();
    setState(() {
      busy = false;
    });
  }

  void _confirmPassengerCount() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            elevation: 16.0,
            shape: getDefaultRoundedBorder(),
            title: Text(
              dispatchTaxi == null ? 'Dispatch Taxi?' : dispatchTaxi!,
              style: myTextStyleMediumLargeWithColor(
                  context, Theme.of(context).primaryColor, 24),
            ),
            content: Padding(
              padding: const EdgeInsets.all(2.0),
              child: SizedBox(
                height: 420,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 24,
                    ),
                    Text(confirmDispatch == null
                        ? 'Please confirm YES to dispatch this taxi'
                        : confirmDispatch!),
                    const SizedBox(
                      height: 48,
                    ),
                    scannedVehicle == null?gapH16: Text(
                      '${scannedVehicle!.vehicleReg}',
                      style: myNumberStyleLargest(context),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      children: [
                        PassengerCount(
                          onCountPicked: (n) {
                            setState(() {
                              passengerCount = n;
                            });
                            Navigator.of(context).pop();
                            _confirmPassengerCount();
                          },
                        ),
                        const SizedBox(
                          width: 24,
                        ),
                        Text(
                          '$passengerCount',
                          style: myNumberStyleLargest(context),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const MediaReminder(),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    _clearFields();
                    Navigator.of(context).pop();
                  },
                  child: Text(no == null ? 'No' : no!)),

              SizedBox(width: 300,
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showRoutes = false;
                      });
                      _sendTheDispatchRecord();

                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(yes == null ? 'Yes' : yes!),
                    )),
              ),
            ],
          );
        });
  }

  Future<lib.RouteLandmark?> findNearestLandmark(Position loc) async {
    final m = await localFinder.findNearestRouteLandmark(
        latitude: loc.latitude, longitude: loc.longitude, radiusInMetres: 200);
    if (m != null) {
      pp('$mm ... findNearestLandmark found: ${m.landmarkName} ${E.pear}  route: ${m.routeName}');
    }
    return m;
  }

  int passengerCount = 0;
  Future<void> _sendTheDispatchRecord() async {
    late lib.DispatchRecord m;
    Navigator.of(context).pop();
    try {
      setState(() {
        busy = true;
      });
      final loc = await locationBloc.getLocation();
      lib.RouteLandmark? mark = await findNearestLandmark(loc);
      m = lib.DispatchRecord(
          dispatchRecordId: DateTime.now().toIso8601String(),
          routeName: selectedRoute!.name,
          routeId: selectedRoute!.routeId,
          created: DateTime.now().toUtc().toIso8601String(),
          vehicleId: scannedVehicle!.vehicleId,
          vehicleReg: scannedVehicle!.vehicleReg,
          associationId: scannedVehicle!.associationId,
          ownerId: scannedVehicle!.ownerId,
          marshalId: user!.userId,
          marshalName: user!.name,
          dispatched: true,
          passengers: passengerCount,
          associationName: scannedVehicle!.associationName,
          position: lib.Position(
            type: 'Point',
            coordinates: [loc.longitude, loc.latitude],
            latitude: loc.latitude,
            longitude: loc.longitude,
          ),
          landmarkName: mark?.landmarkName,
          routeLandmarkId: mark?.landmarkId);
      //
      dispatches.insert(0, m);
      dispatchHelper.sendDispatch(m);
      _clearFields();
      //dispatchIsolate.addDispatchRecord(m);
      //Navigator.of(context).pop();
      if (mounted) {
        showToast(
                  padding: 24,
                  backgroundColor: Colors.green.shade900,
                  duration: const Duration(seconds: 5),
                  textStyle: const TextStyle(color: Colors.white),
                  message: 'Dispatch sent OK', context: context);
      }
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  bool showMediaRequestMessage = true;

  void _clearFields() {
    setState(() {
      selectedRouteLandmark = null;
      scannedVehicle = null;
      passengerCount = 0;
      _showDispatches = true;
      _showRoutes = false;
      showMediaRequestMessage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          dispatchText == null ? 'Dispatch' : dispatchText!,
          style: myTextStyleLarge(context),
        ),
      ),
      body: SizedBox(
        width: width,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Card(
                shape: getDefaultRoundedBorder(),
                elevation: 4,
                child: Column(
                  children: [
                   gapH32,
                    selectedRoute == null
                        ? Text(
                            selectRouteText == null
                                ? 'Please select route'
                                : selectRouteText!,
                            style: myTextStyleMediumLargeWithColor(context,
                                Theme.of(context).primaryColorLight, 20),
                          )
                        : TextButton(
                            onPressed: () {
                              setState(() {
                                _showRoutes = !_showRoutes;
                                _showDispatches = false;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${selectedRoute!.name}',
                                style: myTextStyleMediumLargeWithColor(context,
                                    Theme.of(context).primaryColorLight, 16),
                              ),
                            )),
                    gapH32,
                    scannedVehicle == null
                        ? gapH32
                        : Text(
                            '${scannedVehicle!.vehicleReg}',
                            style: myTextStyleMediumLargeWithColor(
                                context, Theme.of(context).primaryColor, 32),
                          ),
                    busy
                        ? const Row(mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  backgroundColor: Colors.pink,
                                ),
                              ),
                            SizedBox(width: 24,),
                          ],
                        )
                        : const SizedBox(),
                    selectedRoute == null
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Card(
                              shape: getDefaultRoundedBorder(),
                              elevation: 12,
                              child: QRScanner(
                                  onCarScanned: onCarScanned,
                                  onUserScanned: (user) {},
                                  onError: onError,
                                  quitAfterScan: quitAfterScan, onClear: (){
                                setState(() {
                                  scannedVehicle = null;
                                });
                              },),
                            ),
                          ),
                    Expanded(
                      child: Stack(
                        children: [
                          _showRoutes
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RouteWidgetList(
                                    routes: routes,
                                    onRouteSelected: (r) {
                                      onRoutePicked(r);
                                    },
                                  ),
                                )
                              : const SizedBox(),
                          _showDispatches
                              ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: DispatchGrid(
                                    dispatches: dispatches,
                                    title: dispatchText!,
                                  ),
                              )
                              : const SizedBox(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            _showDispatchButton
                ? Positioned(
                    bottom: 36,
                    top: 200,
                    left: 4,
                    right: 4,
                    child: Center(
                      child: Card(
                        shape: getDefaultRoundedBorder(),
                        elevation: 8,
                        child: SizedBox(
                          height: 300,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 48.0, vertical: 48),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showDispatchButton = false;
                                      });
                                    },
                                    child: Text(
                                      cancelText == null
                                          ? 'Cancel'
                                          : cancelText!,
                                      style: myTextStyleSmall(context),
                                    )),
                                ElevatedButton(
                                    style: const ButtonStyle(
                                        elevation:
                                            WidgetStatePropertyAll(8.0)),
                                    onPressed: () {
                                      setState(() {
                                        _showDispatchButton = false;
                                      });
                                      _doDispatch();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(dispatchTaxi == null
                                          ? 'Dispatch Taxi'
                                          : dispatchTaxi!),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            // busy
            //     ? const Center(
            //         child: SizedBox(
            //           height: 32,
            //           width: 32,
            //           child: CircularProgressIndicator(
            //             strokeWidth: 6,
            //             backgroundColor: Colors.green,
            //           ),
            //         ),
            //       )
            //     : const SizedBox(),
          ],
        ),
      ),
    ));
  }
}

class DispatchGrid extends StatelessWidget {
  const DispatchGrid({super.key, required this.dispatches, required this.title});
  final String title;
  final List<lib.DispatchRecord> dispatches;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 1, crossAxisSpacing: 1),
        itemCount: dispatches.length,
        itemBuilder: (ctx, index) {
          final car = dispatches.elementAt(index);
          return DispatchCarPlate(dispatchRecord: car);
        });
  }
}

//
class DispatchCarPlate extends StatelessWidget {
  const DispatchCarPlate({super.key, required this.dispatchRecord});
  final lib.DispatchRecord dispatchRecord;

  @override
  Widget build(BuildContext context) {
    var color = Colors.red.shade700;
    if (dispatchRecord.passengers! < 6) {
      color = Colors.amber.shade900;
    }
    if (dispatchRecord.passengers! >= 6) {
      color = Colors.teal.shade700;
    }
    if (dispatchRecord.passengers! > 16) {
      color = Colors.pink.shade700;
    }
    if (dispatchRecord.passengers! == 0) {
      color = Colors.grey;
    }
    final fmt = DateFormat('HH:mm:ss');
    final date = fmt.format(DateTime.parse(dispatchRecord.created!));
    return SizedBox(
      height: 80,
      width: 80,
      child: bd.Badge(
        badgeContent: Text(
          '${dispatchRecord.passengers}',
          style: myTextStyleSmall(context),
        ),
        position: bd.BadgePosition.topEnd(top: 2, end: -2),
        badgeStyle: bd.BadgeStyle(
          badgeColor: color,
          elevation: 8,
          padding: const EdgeInsets.all(6),
        ),
        child: Card(
          shape: getRoundedBorder(radius: 8),
          elevation: 8,
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 48,
                ),
                Text(
                  '${dispatchRecord.vehicleReg}',
                  style: myTextStyleMediumLarge(context, 16),
                ),
                Text(date, style: myTextStyleSmall(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
