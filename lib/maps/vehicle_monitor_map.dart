import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/data/vehicle_bag.dart';
import 'package:kasie_transie_library/maps/passenger_count_card.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/vehicle_widgets/vehicle_dispatches.dart';

import '../bloc/list_api_dog.dart';
import '../isolates/routes_isolate.dart';
import '../messaging/fcm_bloc.dart';
import '../utils/emojis.dart';
import '../widgets/counts_widget.dart';

class VehicleMonitorMap extends StatefulWidget {
  const VehicleMonitorMap({super.key, required this.vehicle});

  final lib.Vehicle vehicle;

  @override
  VehicleMonitorMapState createState() => VehicleMonitorMapState();
}

class VehicleMonitorMapState extends State<VehicleMonitorMap>
    with SingleTickerProviderStateMixin {
  final mm = '🍐🍐🍐🍐VehicleMonitorMap 🍐🍐';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  late AnimationController _controller;
  final Completer<GoogleMapController> _googleMapCompleter = Completer();
  late GoogleMapController googleMapController;
  CameraPosition initialCameraPosition =
      const CameraPosition(target: LatLng(-27.6, 27.4), zoom: 14);

  var dispatches = <lib.DispatchRecord>[];
  var heartbeats = <lib.VehicleHeartbeat>[];
  var arrivals = <lib.VehicleArrival>[];
  var departures = <lib.VehicleDeparture>[];
  var passengerCounts = <lib.AmbassadorPassengerCount>[];

  VehicleBag? bag;
  int hours = 24 * 7;
  bool busy = false;
  String title = "Maps";

  // late StreamSubscription<lib.LocationResponse> respSub;
  late StreamSubscription<lib.DispatchRecord> dispatchStreamSub;
  late StreamSubscription<lib.AmbassadorPassengerCount> passengerStreamSub;
  late StreamSubscription<lib.VehicleArrival> arrivalStreamSub;
  late StreamSubscription<lib.VehicleDeparture> departureStreamSub;
  late StreamSubscription<lib.VehicleHeartbeat> heartbeatStreamSub;
  int totalPassengers = 0;
  bool showPassengerCount = false;
  bool retryDone = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _control();
  }

  void _listen() async {
    arrivalStreamSub = fcmBloc.vehicleArrivalStream.listen((event) async {
      pp('$mm ... vehicleArrivalStream delivered: ${E.leaf2} ${event.vehicleReg} at ${event.created}');
      if (event.vehicleId == widget.vehicle.vehicleId) {
        arrivals.add(event);
        // if (mounted) {
        //   setState(() {});
        // }
      }
    });
    departureStreamSub = fcmBloc.vehicleDepartureStream.listen((event) {
      pp('$mm ... vehicleDepartureStream delivered: ${E.leaf2} ${event.vehicleReg} at ${event.created}');
      if (event.vehicleId == widget.vehicle.vehicleId) {
        departures.add(event);
        // if (mounted) {
        //   setState(() {});
        // }
      }
    });

    dispatchStreamSub =
        fcmBloc.dispatchStream.listen((lib.DispatchRecord dRec) async {
      pp('$mm ... dispatchStream delivered dispatch for: ${dRec.vehicleReg} at ${dRec.landmarkName} at ${dRec.created}');
      if (dRec.vehicleId == widget.vehicle.vehicleId) {
        dispatches.add(dRec);
        totalPassengers += dRec.passengers!;
        // if (mounted) {
        //   setState(() {});
        // }
      }
    });
    passengerStreamSub = fcmBloc.passengerCountStream
        .listen((lib.AmbassadorPassengerCount cunt) {
      pp('$mm ... passengerCountStream delivered count for: ${cunt.vehicleReg} at ${cunt.created}');
      if (cunt.vehicleId == widget.vehicle.vehicleId) {
        totalPassengers += cunt.passengersIn!;
        passengerCounts.add(cunt);
        //
        if (mounted) {
          try {
            setState(() {
              showPassengerCount = true;
            });
          } catch (e) {
            pp('$mm ERROR SETTING STATE: $e');
          }
        }
      }
    });
    heartbeatStreamSub = fcmBloc.heartbeatStreamStream
        .listen((lib.VehicleHeartbeat heartbeat) async {
      pp('$mm ... heartbeatStreamStream delivered heartbeat for: ${heartbeat.vehicleReg} at ${heartbeat.created}');
      if (heartbeat.vehicleId == widget.vehicle.vehicleId) {
        await _putLastHeartbeatOnMap(heartbeat);
      }
    });
  }

  void _control() async {
    setState(() {
      busy = true;
    });
    try {
      await _getVehicleBag();
      await _getRoutes();
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(message: 'Error: $e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  lib.VehicleHeartbeat? lastHeartbeat;
  Future _getVehicleBag() async {
    pp('$mm ... getVehicleBag that shows the last ${E.blueDot} $hours hours .... ');

    final date = DateTime.now()
        .toUtc()
        .subtract(Duration(hours: hours))
        .toIso8601String();
    try {
      bag = await listApiDog.getVehicleBag(widget.vehicle.vehicleId!, date);
      if (mounted) {
        if (bag!.isEmpty()) {
          showSnackBar(
              message:
                  'There is no data within $hours hours. Please try again with higher hours or wait for data from the vehicle',
              context: context);
          setState(() {
            busy = false;
          });
          Navigator.of(context).pop();
          return;
        } else {
          if (bag!.heartbeats.isNotEmpty) {
            bag!.heartbeats.sort((a, b) => b.created!.compareTo(a.created!));
            lastHeartbeat = bag!.heartbeats.last;
            _putLastHeartbeatOnMap(lastHeartbeat!);
          }
        }
      }
    } catch (e, stack) {
      pp('$e - $stack');
      if (mounted) {
        showSnackBar(
            backgroundColor: Colors.red,
            message: 'Could not get data for you. Please try again',
            context: context);
      }
    }
  }

  Future<void> _getRoutes() async {
    try {
      var routesIsolate = GetIt.instance<RoutesIsolate>();
      pp('$mm ..... getRoutes ..');
        routes =
            await routesIsolate.getRoutesMappable(widget.vehicle.associationId!, false);
      // }
      _printRoutes();
      if (routes.isNotEmpty) {
        _putRoutesOnMap(false);
      }
    } catch (e, stack) {
      pp('$mm $e $stack');
    }
  }

  var routes = <lib.Route>[];

  lib.Route? routeSelected;
  final Set<Marker> _routeMarkers = HashSet();
  final Set<Marker> _heartbeatMarkers = HashSet();
  final Set<Marker> _lastHeartbeatMarkers = HashSet();

  final Set<Circle> _circles = HashSet();
  final Set<Polyline> _polyLines = {};

  Future _putRoutesOnMap(bool zoomTo) async {
    pp('\n\n$mm ... _putRoutesOnMap: number of routes: ${E.blueDot} ${routes.length}');
    var routesIsolate = GetIt.instance<RoutesIsolate>();
    final hash = HashMap<String, List<lib.RoutePoint>>();
    _routeMarkers.clear();
    _polyLines.clear();
    lib.RouteLandmark? mLandmark;
    for (var route in routes) {
      final points = await routesIsolate.getRoutePoints(route.routeId!, false);
      final marks = await listApiDog.getRouteLandmarks(route.routeId!, false);
      hash[route.routeId!] = points;
      //add polyline
      final List<LatLng> latLngs = [];
      points.sort((a, b) => a.index!.compareTo(b.index!));
      for (var rp in points) {
        latLngs.add(
            LatLng(rp.position!.coordinates[1], rp.position!.coordinates[0]));
      }
      var polyLine = Polyline(
          color: getColor(route.color!),
          width: 6,
          points: latLngs,
          zIndex: 0,
          onTap: () {
            pp('$mm ... polyLine tapped; route: ${points.first.routeName}');
            if (mounted) {
              showToast(message: '${points.first.routeName}', context: context);
            }
          },
          consumeTapEvents: true,
          polylineId: PolylineId(route.routeId!));

      _polyLines.add(polyLine);

      int index = 0;
      if (marks.isNotEmpty) {
        mLandmark = marks.first;
      }
      for (var routeLandmark in marks) {
        final icon = await getMarkerBitmap(64,
            text: '${index + 1}',
            color: route.color!,
            fontSize: 28,
            fontWeight: FontWeight.w900);

        _routeMarkers.add(Marker(
            markerId: MarkerId(routeLandmark.landmarkId!),
            icon: icon,
            zIndex: 1,
            position: LatLng(routeLandmark.position!.coordinates[1],
                routeLandmark.position!.coordinates[0]),
            infoWindow: InfoWindow(
                title: routeLandmark.landmarkName,
                snippet:
                    '🍎Landmark on route:\n\n ${routeLandmark.routeName}')));
        index++;
      }
    }
    getAllMarkers();
    if (zoomTo) {
      if (mLandmark != null) {
        final latLng = LatLng(mLandmark.position!.coordinates.last,
            mLandmark.position!.coordinates.first);
        _zoomToPosition(latLng);
      }
    } else {
      setState(() {});
    }
  }

  Set<Marker> allMarkers = {};

  // Method to get all markers from all sets
  void getAllMarkers() {
    allMarkers.clear();
    allMarkers.addAll(_routeMarkers);
    allMarkers.addAll(_heartbeatMarkers);
    allMarkers.addAll(_lastHeartbeatMarkers);
  }

  Future _putHeartbeatOnMap(lib.VehicleHeartbeat heartbeat) async {
    heartbeats.sort((a, b) => a.created!.compareTo(b.created!));
    _heartbeatMarkers.clear();
    if (mounted) {
      setState(() {
        showDot = true;
      });
    }

    var style = GoogleFonts.secularOne(
        textStyle: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 36,
            color: hybrid ? Colors.white : Colors.black),
        fontWeight: FontWeight.w900,
        fontSize: 44,
        color: hybrid ? Colors.white : Colors.black);

    for (var value in heartbeats) {
      final icon = await getMarkerBitmap(80,
          text: '${value.vehicleReg}',
          color: 'black',
          borderColor: Colors.yellow,
          fontSize: 14,
          fontWeight: FontWeight.bold);

      final latLng = LatLng(
          value.position!.coordinates[1], value.position!.coordinates[0]);

      final key = DateTime.parse(value.created!);
      _heartbeatMarkers.add(Marker(
          markerId: MarkerId('hb_$key'),
          icon: icon,
          zIndex: 0,
          position: latLng,
          onTap: () {
            pp('$mm ... on Marker tapped ...');
          },
          infoWindow: InfoWindow(
              title: value.vehicleReg,
              onTap: () async {
                pp('$mm ... on infoWindow tapped...${value.created}');
                _handleTap();
              },
              snippet:
                  '${E.blueDot} ${getFormattedDateLong(value.created!)}')));
    }
    //
    pp('\n\n$mm put latest heartbeat on map ...');
    final key = DateTime.parse(heartbeat.created!);
    final iconLast = await getTaxiMapIcon(
        iconSize: 360,
        text: '${heartbeat.vehicleReg}',
        style: style,
        path: 'assets/car2.png');

    _lastHeartbeatMarkers.clear();

    _lastHeartbeatMarkers.add(Marker(
        markerId: MarkerId('hb_$key'),
        icon: iconLast,
        zIndex: 4,
        position: LatLng(heartbeat.position!.coordinates.last,
            heartbeat.position!.coordinates.first),
        onTap: () {
          pp('$mm ... on Marker tapped ...');
        },
        infoWindow: InfoWindow(
            title: heartbeat.vehicleReg,
            onTap: () async {
              pp('$mm ... on infoWindow tapped...${getFormattedDate(heartbeat.created!)}');
              _handleTap();
            },
            snippet:
                '${E.blueDot} ${getFormattedDateLong(heartbeat.created!)}')));

    heartbeats.add(heartbeat);

    getAllMarkers();
    if (mounted) {
      setState(() {});
    }

    try {
      await _zoomToPosition(LatLng(heartbeat.position!.coordinates.last,
          heartbeat.position!.coordinates.first));
      if (mounted) {
        setState(() {
          showDot = false;
        });
      }
    } catch (e) {
      pp('$mm some error with zooming? ${E.redDot}${E.redDot}${E.redDot}${E.redDot}'
          ' $e');
    }
  }

  Future _putLastHeartbeatOnMap(lib.VehicleHeartbeat heartbeat) async {
    heartbeats.sort((a, b) => a.created!.compareTo(b.created!));
    _heartbeatMarkers.clear();
    if (mounted) {
      setState(() {
        showDot = true;
      });
    }


    // final icon = await getTaxiMapIcon(
    //     iconSize: 360,
    //     text: '${heartbeat.vehicleReg}',
    //     style: style,
    //     path: 'assets/car2.png');
    final icon = await getMarkerBitmap(160,
        text:  '${heartbeat.vehicleReg}',
        color: 'pink',
        fontSize: 24,
        fontWeight: FontWeight.w900);

      final latLng = LatLng(
          heartbeat.position!.coordinates[1], heartbeat.position!.coordinates[0]);

      final key = DateTime.parse(heartbeat.created!);
      _heartbeatMarkers.add(Marker(
          markerId: MarkerId('hb_$key'),
          icon: icon,
          zIndex: 4,
          position: latLng,
          onTap: () {
            pp('$mm ... on Marker tapped ...');
          },
          infoWindow: InfoWindow(
              title: heartbeat.vehicleReg,
              onTap: () async {
                pp('$mm ... on infoWindow tapped...${heartbeat.created}');
                _handleTap();
              },
              snippet:
              '${E.blueDot} ${getFormattedDateLong(heartbeat.created!)}')));
    //
    getAllMarkers();
    if (mounted) {
      setState(() {});
    }

    try {
      await _zoomToPosition(LatLng(heartbeat.position!.coordinates.last,
          heartbeat.position!.coordinates.first));
      if (mounted) {
        setState(() {
          showDot = false;
        });
      }
    } catch (e) {
      pp('$mm some error with zooming? ${E.redDot}${E.redDot}${E.redDot}${E.redDot}'
          ' $e');
    }
  }

  void _handleTap() async {
    setState(() {
      busy = true;
    });
    try {
      final date = DateTime.now()
          .toUtc()
          .subtract(Duration(hours: hours))
          .toIso8601String();
      bag = await listApiDog.getVehicleBag(widget.vehicle.vehicleId!, date);
      setState(() {
        showDetails = true;
      });
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  bool showDetails = false;

  Future<void> _zoomToPosition(LatLng latLng) async {
    var cameraPos = CameraPosition(target: latLng, zoom: 16.4);
    try {
      await googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPos));
      setState(() {
        showDot = false;
      });
    } catch (e) {
      pp('$mm some error with zooming? ${E.redDot} '
          '$e ${E.redDot} ${E.redDot} ${E.redDot} ');
    }
  }

  void _printRoutes() {
    int cnt = 1;
    for (var r in routes) {
      pp('$mm route #:$cnt ${E.appleRed} ${r.name}');
      cnt++;
    }
  }

  bool hybrid = true;

  @override
  void dispose() {
    _controller.dispose();
    dispatchStreamSub.cancel();
    arrivalStreamSub.cancel();
    departureStreamSub.cancel();
    heartbeatStreamSub.cancel();
    passengerStreamSub.cancel();
    super.dispose();
  }

  bool showDot = false;

  void _showCounts() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return CountsGridWidget(
            arrivals: arrivals.length,
            departures: departures.length,
            dispatches: dispatches.length,
            passengerCounts: passengerCounts.length, //todo calculate passengers
            heartbeats: heartbeats.length,
            arrivalsText: 'Arrivals',
            departuresText: 'Departures',
            dispatchesText: 'Dispatches',
            heartbeatText: 'Heartbeats',
            passengerCountsText: 'Passengers',
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Vehicle Map: ${widget.vehicle.vehicleReg}',
          style: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColor, 20),
        ),
        // bottom: PreferredSize(
        //     preferredSize: const Size.fromHeight(48),
        //     child: Column(
        //       children: [
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Text(
        //               'Hours',
        //               style: myTextStyleSmall(context),
        //             ),
        //             const SizedBox(
        //               width: 16,
        //             ),
        //             Text(
        //               '$hours',
        //               style: myTextStyleMediumLargeWithColor(
        //                   context, Theme.of(context).primaryColor, 20),
        //             ),
        //             const SizedBox(
        //               width: 100,
        //             ),
        //             NumberDropDown(
        //                 onNumberPicked: (number) {
        //                   setState(() {
        //                     hours = number;
        //                   });
        //                   _getVehicleBag();
        //                 },
        //                 color: Theme.of(context).primaryColor,
        //                 count: 49,
        //                 fontSize: 14),
        //             const SizedBox(
        //               width: 48,
        //             ),
        //             showDot ? Text(E.redDot) : gapH12,
        //           ],
        //         ),
        //         gapH12,
        //       ],
        //     )),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  child: GoogleMap(
                initialCameraPosition: initialCameraPosition,
                mapType: hybrid ? MapType.hybrid : MapType.normal,
                markers: allMarkers,
                polylines: _polyLines,
                onMapCreated: (cont) {
                  pp('$mm .......... onMapCreated set up cluster managers ...........');
                  _googleMapCompleter.complete(cont);
                  googleMapController = cont;
                },
              )),
            ],
          ),
          showPassengerCount
              ? Positioned(
                  bottom: 20,
                  left: 8,
                  child: PassengerCountCard(
                      backgroundColor: Colors.black38,
                      passengerCount: passengerCounts.last))
              : gapW12,
          showDetails
              ? Positioned(
                  child: Center(
                      child: VehicleDispatches(
                  dispatchRecords: bag!.dispatchRecords,
                  onClose: () {
                    setState(() {
                      showDetails = false;
                    });
                  },
                )))
              : gapH8,
          busy
              ? const Positioned(
                  child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    backgroundColor: Colors.teal,
                  ),
                ))
              : gapW8,
        ],
      ),
    ));
  }
}
