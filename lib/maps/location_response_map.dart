import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/local_finder.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:permission_handler/permission_handler.dart';

import '../isolates/routes_isolate.dart';
import '../l10n/translation_handler.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';

class LocationResponseMap extends StatefulWidget {
  const LocationResponseMap({Key? key, required this.locationResponse})
      : super(key: key);

  final lib.LocationResponse locationResponse;

  @override
  LocationResponseMapState createState() => LocationResponseMapState();
}

class LocationResponseMapState extends State<LocationResponseMap> {
  static const mm = '😡😡😡😡😡😡😡 LocationResponseMap: 💪 ';
  final _key = GlobalKey<ScaffoldState>();
  bool busy = false;
  bool hybrid = true;
  final initialCameraPosition =
      const CameraPosition(target: LatLng(-25.7, 27.6), zoom: 14.6);
  final Completer<GoogleMapController> _mapController = Completer();
  late GoogleMapController googleMapController;

  final _markers = <Marker>{};
  final _polyLines = <Polyline>{};
  var routes = <lib.Route>[];
  var routePoints = [<lib.RoutePoint>[]];
  var routeLandmarks = [<lib.RouteLandmark>[]];

  String? locationResponseText, dateText, taxiCurrentLocation, loadingRoutes;
  lib.User? user;
  var bags = <RouteDataBag>[];

  @override
  void initState() {
    super.initState();
    pp('$mm at least I get to initState ... ${E.heartRed} ${widget.locationResponse.vehicleReg}');
    _setTexts();
  }

  Future _findRoutesNearby() async {
    pp('$mm _findRoutesNearby ........ ${E.leaf2}');

    var status = await Permission.location.status;
    if (!status.isGranted) {
      try {
        await Permission.location.request();
      } catch (e) {
        pp('$mm $e');
      }
    }

    setState(() {
      busy = true;
    });
    user = await prefs.getUser();
    try {
      final loc = await locationBloc.getLocation();
      routes = await localFinder.findNearestRoutes(
          latitude: loc.latitude,
          longitude: loc.longitude,
          radiusInMetres: 5000);
      var marks = await localFinder.findNearestRouteLandmarks(
          latitude: loc.latitude,
          longitude: loc.longitude,
          radiusInMetres: 5000);
      pp('$mm ... marks: ${marks.length}');
      pp('$mm ... routes: ${routes.length}');
      if (routes.isNotEmpty) {
        pp('$mm  check for null: ${routes.first.name} color: ${routes.first.color}');
      }
      for (var value in routes) {
        final lrs = await listApiDog.getRouteLandmarks(value.routeId!, false);
        final points =
            await routesIsolate.getRoutePoints(value.routeId!, false);
        final bag = RouteDataBag(
            route: value, routeLandmarks: lrs, routePoints: points);
        bags.add(bag);

        pp('$mm ... routeLandmarks: ${value.name} has ${lrs.length} landmarks');
        pp('$mm ... routePoints: ${value.name} has ${points.length} points');
      }

      pp('$mm ... route bags: ${bags.length}');

      _buildPolyLines();
      await _buildLandmarks();
      //putResponseOnMap();
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(message: 'Error getting routes: $e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  void _buildPolyLines() {
    pp('$mm _buildPolyLines ...');
    var routeIndex = 0;

    for (var route in routes) {
      final bag = bags[routeIndex];
      final latLngs = <LatLng>[];
      for (var point in bag.routePoints) {
        final latLng = LatLng(
            point.position!.coordinates[1], point.position!.coordinates[0]);
        latLngs.add(latLng);
      }
      final polyLine = Polyline(
        polylineId: PolylineId(route.routeId!),
        points: latLngs,
        width: 12,
        onTap: () {
          pp('$mm ... polyline tapped ... point below ...');
        },
        consumeTapEvents: true,
        color: getColor(route.color!),
      );
      _polyLines.add(polyLine);

      routeIndex++;
    }
  }

  Future<BitmapDescriptor> buildIcon(
      {required int index,
      required String color,
      required Color borderColor,
      required Color textColor,
      required TextStyle style}) async {
    final icon = getMarkerBitmap(72,
        text: '${index + 1}',
        color: color,
        borderColor: borderColor,
        fontSize: 32,
        fontWeight: FontWeight.w900);
    return icon;
  }

  Future _buildLandmarks() async {
    pp('$mm _buildLandmarks on map ...');
    var routeIndex = 0;
    for (var route in routes) {
      pp('$mm route: ${route.name} - ${route.routeId} ${E.blueDot} color: ${route.color}');
      final bag = bags[routeIndex];
      var index = 0;

      for (var mark in bag.routeLandmarks) {
        final latLng = LatLng(
            mark.position!.coordinates[1], mark.position!.coordinates[0]);

        final icon = await getMarkerBitmap(72,
            text: '${index + 1}',
            color: route.color!, borderColor: Colors.black, fontSize: 28, fontWeight: FontWeight.normal);

        _markers.add(Marker(
            markerId: MarkerId(mark.landmarkId!),
            icon: icon,
            position: latLng,
            onTap: () {
              pp('$mm landmark tapped ...');
              myPrettyJsonPrint(mark.toJson());
            },
            infoWindow: InfoWindow(
              title: mark.landmarkName,
              snippet: mark.routeName,
            )));
        index++;
      }

      pp('$mm route landmarks: ${route.name} has ${bag.routeLandmarks.length} '
          'landmarks with ${bag.routePoints.length} routePoints');
      routeIndex++;
    }
  }

  Future<void> putResponseOnMap() async {
    pp('$mm _putResponseOnMap .......................'
        '${widget.locationResponse.vehicleReg}');

    final latLng = LatLng(widget.locationResponse.position!.coordinates[1],
        widget.locationResponse.position!.coordinates[0]);

    // var intList = await getBytesFromAsset("assets/markers/footprint.png", 108);
    // final icon = BitmapDescriptor.fromBytes(intList);
    final ic = await getMarkerBitmap(
      128,
      text: widget.locationResponse.vehicleReg!,
      color: 'black',
      borderColor: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w900,
    );
    _markers.add(Marker(
        markerId: MarkerId(widget.locationResponse.vehicleId!),
        icon: ic,
        zIndex: 2,
        position: latLng,
        onTap: () {
          pp('$mm ... car tapped. find routes ...');
          _findRoutesNearby();
        },
        infoWindow: InfoWindow(
          title: widget.locationResponse.vehicleReg,
        )));

    setState(() {});
    _zoomTo(latLng);
  }

  Future<void> _zoomTo(LatLng latLng) async {
    pp('$mm ....... zoom to $latLng');
    var cameraPos = CameraPosition(target: latLng, zoom: 14.0);
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPos));

  }

  void _setTexts() async {
    final c = await prefs.getColorAndLocale();
    final locale = c.locale;
    locationResponseText =
        await translator.translate('locationResponse', locale);
    dateText = await translator.translate('date', locale);
    loadingRoutes = await translator.translate('loadingRoutes', locale);
    taxiCurrentLocation =
        await translator.translate('taxiCurrentLocation', locale);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localDate = DateTime.parse(widget.locationResponse.created!)
        .toLocal()
        .toIso8601String();
    final date = getFormattedDateLong(localDate);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox(),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                locationResponseText == null
                    ? 'Response Map'
                    : locationResponseText!,
                style: myTextStyleMediumLargeWithColor(
                    context, Theme.of(context).primaryColor, 18),
              ),
            ],
          ),
          // actions: [
          //   IconButton(
          //       onPressed: () {
          //         Navigator.of(context).pop();
          //       },
          //       icon: const Icon(Icons.close)),
          // ],
        ),
        body: busy
            ? Center(
                child: Card(
                  elevation: 8,
                  shape: getDefaultRoundedBorder(),
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 72,
                        ),
                        const CircularProgressIndicator(),
                        const SizedBox(
                          height: 24,
                        ),
                        Text(loadingRoutes == null
                            ? 'Loading route data ...'
                            : loadingRoutes!),
                      ],
                    ),
                  ),
                ),
              )
            : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: initialCameraPosition,
                    buildingsEnabled: true,
                    mapType: hybrid ? MapType.hybrid : MapType.normal,
                    compassEnabled: true,
                    mapToolbarEnabled: true,
                    polylines: _polyLines,
                    markers: _markers,
                    onMapCreated: (cont) {
                      pp('\n$mm .......... on onMapCreated .....');
                      googleMapController = cont;
                      try {
                        _mapController.complete(cont);
                      } catch (e) {
                        pp('$mm error ignored: $e');
                      }
                      putResponseOnMap();
                    },
                  ),
                  Positioned(
                      child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Card(
                      shape: getDefaultRoundedBorder(),
                      color: Colors.black38,
                      elevation: 8,
                      child: SizedBox(
                        width: 220,
                        height: 64,
                        child: Center(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                '${widget.locationResponse.vehicleReg}',
                                style: myTextStyleMediumLargeWithColor(
                                    context, Colors.white, 20),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                date,
                                style: myTextStyleSmall(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ))
                ],
              ),
      ),
    );
  }
}

class RouteDataBag {
  lib.Route route;
  List<lib.RouteLandmark> routeLandmarks;
  List<lib.RoutePoint> routePoints;

  RouteDataBag(
      {required this.route,
      required this.routeLandmarks,
      required this.routePoints});
}
