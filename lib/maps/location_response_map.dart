import 'dart:async';
import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/messaging/fcm_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';

class LocationResponseMap extends StatefulWidget {
  const LocationResponseMap({super.key, required this.vehicle, this.locationResponse});

  final lib.Vehicle vehicle;
  final lib.LocationResponse? locationResponse;

  @override
  LocationResponseMapState createState() => LocationResponseMapState();
}

class LocationResponseMapState extends State<LocationResponseMap>
    with SingleTickerProviderStateMixin {
  final mm = '🍅🍅🍅🍅VehicleMap 🍐🍅🍐';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  late AnimationController _controller;
  final Completer<GoogleMapController> _googleMapCompleter = Completer();
  late GoogleMapController googleMapController;
  CameraPosition initialCameraPosition =
      const CameraPosition(target: LatLng(-25.760, 27.852), zoom: 10);

  var telemetry = <lib.VehicleTelemetry>[];
  lib.VehicleData? vehicleData;
  int hours = 24;
  bool busy = false;
  String title = "Maps";

  // late StreamSubscription<lib.LocationResponse> respSub;
  late StreamSubscription<lib.VehicleTelemetry> telemetryStreamSub;
  late FCMService fcmService = GetIt.instance<FCMService>();

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      reverseDuration: const Duration(milliseconds: 300),
    );
    super.initState();
    _listen();
    pp('$mm location response: ......');
    if (widget.locationResponse != null) {
      myPrettyJsonPrint(widget.locationResponse!.toJson());
    }
  }

  void _listen() async {
    telemetryStreamSub = fcmService.vehicleTelemetryStream
        .listen((lib.VehicleTelemetry telemetry) async {
      pp('$mm ... vehicleTelemetryStream delivered heartbeat for: ${telemetry.vehicleReg} at ${telemetry.created}');
      if (telemetry.vehicleId == widget.vehicle.vehicleId) {
        await _putCarOnMap(
            vehicleReg: telemetry.vehicleReg!,
            created: telemetry.created?? DateTime.now().toIso8601String(),
            latitude: telemetry.position!.coordinates[1],
            longitude: telemetry.position!.coordinates[0]);
      }
    });
  }

  Future<void> _putResponseOnMap() async {
    if (widget.locationResponse != null) {
      await _putCarOnMap(
          vehicleReg: widget.vehicle.vehicleReg!,
          created: widget.locationResponse!.created!,
          latitude: widget.locationResponse!.position!.coordinates[1],
          longitude: widget.locationResponse!.position!.coordinates[0]);
    }
  }

  SemCache semCache = GetIt.instance<SemCache>();
  String? startDate, endDate;

  Future _getVehicleData() async {
    pp('$mm ... _getVehicleData that shows the last ${E.blueDot} $hours hours .... ');

    var now = DateTime.now().subtract(const Duration(hours: 24));
    startDate =
        DateTime(now.year, now.month, now.day, 0, 0, 0).toIso8601String();

    var end = DateTime.now();
    endDate =
        DateTime(end.year, end.month, end.day, 23, 59, 59).toIso8601String();

    final sd = DateTime.parse(startDate!).toUtc().toIso8601String();
    final ed = DateTime.parse(endDate!).toUtc().toIso8601String();

    setState(() {
      busy = true;
    });
    try {
      vehicleData = await listApiDog.getVehicleData(
          vehicleId: widget.vehicle.vehicleId!, startDate: sd, endDate: ed);
      if (mounted) {
        if (vehicleData != null) {
          telemetry = vehicleData!.vehicleTelemetry;
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
    setState(() {
      busy = false;
    });
  }

  Future<void> _getRoutes() async {
    try {
      pp('$mm ..... getRoutes ..');
      routes = await semCache.getRoutes(
          associationId: widget.vehicle.associationId!);
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
    var semCache = GetIt.instance<SemCache>();
    final hash = HashMap<String, List<lib.RoutePoint>>();
    _routeMarkers.clear();
    _polyLines.clear();
    lib.RouteLandmark? mLandmark;
    for (var route in routes) {
      final points =
          await semCache.getRoutePoints(route.routeId!, route.associationId!);
      final marks = await semCache.getRouteLandmarks(
          routeId: route.routeId!, associationId: route.associationId!);
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

  Future _putCarOnMap(
      {required String vehicleReg,
      required String created,
      required double latitude,
      required double longitude}) async {
    telemetry.sort((a, b) => a.created!.compareTo(b.created!));
    if (mounted) {
      setState(() {
        showDot = true;
      });
    }
    final icon2 = await getTaxiMapIcon(
        iconSize: 360,
        text: vehicleReg,
        style: myTextStyle(color: Colors.white),
        path: 'assets/car2.png');

    final icon = await getMarkerBitmap(120,
        text: vehicleReg,
        color: 'yellow',
        fontSize: 16,
        fontWeight: FontWeight.w300);

    pp('$mm _putCarOnMap: latitude: $latitude longitude: $longitude');
    final latLng = LatLng(latitude, longitude);

    final key = DateTime.parse(created);
    allMarkers.clear();
    allMarkers.add(Marker(
        markerId: MarkerId('hb_$key'),
        icon: icon,
        zIndex: 4,
        position: latLng,
        onTap: () {
          pp('$mm ... on Marker tapped ...');
          _showVehicleDataBottomSheet();
        },
        infoWindow: InfoWindow(
            title: vehicleReg,
            onTap: () async {
              pp('$mm ... on infoWindow tapped...$vehicleReg');
              _showVehicleDataBottomSheet();
            },
            snippet: getFormattedDateLong(created))));
    //
    // getAllMarkers();
    if (mounted) {
      setState(() {});
    }

    try {
      await _zoomToPosition(LatLng(latitude, longitude));
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
      final then = DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day, 23, 59, 59)
          .toUtc()
          .toIso8601String();

      vehicleData = await listApiDog.getVehicleData(
          vehicleId: widget.vehicle.vehicleId!, startDate: date, endDate: then);
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
    pp('$mm _zoomToPosition: latitude: ${latLng.latitude} longitude: ${latLng.longitude}');
    var cameraPos =
        CameraPosition(target: latLng, zoom: 8);
    try {
      await googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPos));
      setState(() {
        showDot = true;
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
    telemetryStreamSub.cancel();
    super.dispose();
  }

  bool showDot = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Current Vehicle Location:',
              style: myTextStyle(),
            ),
            gapW16,
            Text('${widget.vehicle.vehicleReg}',
              style: myTextStyleBold(),
            ),
          ],
        )
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
                  _putResponseOnMap();
                },
              )),
            ],
          ),
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

// ... other imports

  void _showVehicleDataBottomSheet() async {
    await _getVehicleData();
    if (mounted) {
      // 2. Create a Tween for the offset animation
      Tween<Offset> offsetTween = Tween<Offset>(
        begin: const Offset(0, 1), // Start below the screen
        end: Offset.zero, // End at the normal position
      );
      // 3. Create an animation from the Tween and controller
      Animation<Offset> offsetAnimation = offsetTween.animate(_controller);
      showModalBottomSheet(
        context: context,
        isDismissible: true,
        builder: (context) {
          // 4. Wrap the bottom sheet content with a SlideTransition
          return SlideTransition(
            position: offsetAnimation,
            child: _buildVehicleDataContent(),
          );
        },

        // 5. Set `transitionAnimationController` to control the animation
        transitionAnimationController: _controller,
      ).whenComplete(() {
        pp('$mm when complete');
      });
    }
  }

// ... rest of your code

  Widget _buildVehicleDataContent() {
    final df = DateFormat('dd MMM yyyy HH:mm');
    var sd = df.format(DateTime.parse(startDate!));
    var ed = df.format(DateTime.parse(endDate!));
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            startDate == null
                ? gapW32
                : Text(
                    '$sd - $ed',
                    style: myTextStyle(weight: FontWeight.w900, fontSize: 16),
                  ),
            gapH8,
            VehicleDataWidget(vehicleData: vehicleData!),
          ],
        ),
      ),
    );
  }
}

class VehicleDataWidget extends StatelessWidget {
  const VehicleDataWidget({super.key, required this.vehicleData, this.padding});

  final lib.VehicleData vehicleData;
  final Padding? padding;

  @override
  Widget build(BuildContext context) {
    int passengers = 0;
    for (var count in vehicleData.passengerCounts) {
      passengers += count.passengersIn!;
    }
    double cash = 0.00;
    for (var count in vehicleData.commuterCashPayments) {
      cash += count.amount!;
    }
    double rfcash = 0.00;
    for (var payment in vehicleData.rankFeeCashPayments) {
      rfcash += payment.amount!;
    }
    return SizedBox(
        height: 400,
        child: ListView(
          children: [
            Item(title: 'Trips', count: vehicleData.trips.length,
              padding: padding,
              style: myTextStyle(weight: FontWeight.w900, color: Colors.black, fontSize: 22),
            ),
            Item(
                title: 'Dispatches', count: vehicleData.dispatchRecords.length),
            Item(
              title: 'Total Passengers',
              count: passengers,
              padding: padding,
              style: myTextStyle(
                  weight: FontWeight.w900,
                  fontSize: 28,
                  color: Colors.red.shade600),
            ),
            Item(title: 'Arrivals', count: vehicleData.vehicleArrivals.length,
              style: myTextStyle(weight: FontWeight.normal, color: Colors.blue),
            ),
            Item(
              title: 'Telemetry',
              padding: padding,
              count: vehicleData.vehicleTelemetry.length,
              style: myTextStyle(weight: FontWeight.normal, color: Colors.grey),
            ),
            Item(
                title: 'Commuter Cash',
                amount: cash,
                padding: padding,
                style: myTextStyle(
                    weight: FontWeight.w900,
                    color: Colors.green.shade800,
                    fontSize: 22)),
            Item(
                title: 'Rank Fee Cash',
                amount: rfcash,
                padding: padding,
                style: myTextStyle(
                    weight: FontWeight.w900,
                    color: Colors.green.shade800,
                    fontSize: 16)),
          ],
        ));
  }
}

class Item extends StatelessWidget {
  const Item(
      {super.key, required this.title, this.count, this.amount, this.style, this.padding});

  final String title;
  final int? count;
  final double? amount;
  final TextStyle? style;
  final Padding? padding;

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('###,###,###');
    final af = NumberFormat('###,###,##0.00');
    return Card(
        elevation: 8,
        child: padding?? Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                SizedBox(
                    width: 140,
                    child: Text(
                      title,
                      style: myTextStyle(
                          weight: FontWeight.w900, color: Colors.grey),
                    )),
                count == null
                    ? gapW32
                    : Text(
                        nf.format(count),
                        style: style == null
                            ? myTextStyle(
                                weight: FontWeight.w900,
                                fontSize: 20,
                                color: Colors.blue.shade700)
                            : style!,
                      ),
                amount == null
                    ? gapW32
                    : Text(
                        af.format(amount),
                        style: style == null
                            ? myTextStyle(
                                weight: FontWeight.w900,
                                fontSize: 20,
                                color: Colors.amber.shade700)
                            : style!,
                      ),
              ],
            )));
  }
}
