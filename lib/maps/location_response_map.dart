import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;

import '../bloc/list_api_dog.dart';
import '../l10n/translation_handler.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';

class LocationResponseMap extends StatefulWidget {
  const LocationResponseMap({super.key, required this.locationResponse});

  final lib.LocationResponse locationResponse;

  @override
  LocationResponseMapState createState() => LocationResponseMapState();
}

class LocationResponseMapState extends State<LocationResponseMap> {
  static const mm = '😡😡😡😡😡😡😡 LocationResponseMap: 💪 ';
  final _key = GlobalKey<ScaffoldState>();

  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

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
  SemCache semCache = GetIt.instance<SemCache>();

  Future<void> _getRoutes() async {
    pp('$mm ... getting routes ....');
    final ass = await listApiDog.getVehicleRouteAssignments(
        widget.locationResponse.vehicleId!, false);
    var hash = HashMap<String, String>();

    if (ass.isNotEmpty) {
      for (var a in ass) {
        hash[a.routeId!] = a.routeId!;
      }
      final list = hash.keys.toList();
      pp('$mm ... _filterRoutes found ${list.length} route ids from route assignments');

      for (var routeId in list) {
        final route = await listApiDog.getRoute(routeId: routeId, refresh: false);
        if (route != null) {
          routes.add(route);
        }
      }
    } else {
      routes = await semCache.getRoutes(associationId: widget.locationResponse.associationId!);
    }
    pp('$mm ... ${routes.length} routes to be put on map ...');

    if (routes.isNotEmpty) {
      _putRoutesOnMap(true);
    }
  }

  Future _putRoutesOnMap(bool zoomTo) async {
    pp('$mm ... _putRoutesOnMap: number of routes: ${routes.length}');

    final hash = HashMap<String, List<lib.RoutePoint>>();
    _markers.clear();
    _polyLines.clear();
    var semCache = GetIt.instance<SemCache>();
    for (var route in routes) {
      final points = await semCache.getRoutePoints(route.routeId!, route.associationId!);
      final marks = await semCache.getRouteLandmarks(routeId: route.routeId!, associationId: route.associationId!);
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

      for (var routeLandmark in marks) {
        final icon = await getMarkerBitmap(64,
            text: '${index + 1}',
            color: route.color!,
            fontSize: 28,
            fontWeight: FontWeight.w900);

        _markers.add(Marker(
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

    if (zoomTo) {
      if (hash.isNotEmpty) {
        final m = hash.values.first.first;
        final latLng =
        LatLng(m.position!.coordinates.last, m.position!.coordinates.first);
        _zoomToPosition(latLng);
      }
    }
  }

  Future<void> _zoomToPosition(LatLng latLng) async {
    var cameraPos = CameraPosition(target: latLng, zoom: 13.4);
    try {
      await googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPos));
      setState(() {
      });
    } catch (e) {
      pp('$mm some error with zooming? ${E.redDot} '
          '$e ${E.redDot} ${E.redDot} ${E.redDot} ');
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
        fontSize: 32,
        fontWeight: FontWeight.w900);
    return icon;
  }


  Future<void> putResponseOnMap() async {
    pp('$mm _putResponseOnMap .......................'
        '${widget.locationResponse.vehicleReg}');

    final latLng = LatLng(widget.locationResponse.position!.coordinates[1],
        widget.locationResponse.position!.coordinates[0]);

    final icon = await getTaxiMapIcon(iconSize: 220,
        text: widget.locationResponse.vehicleReg!, style: const TextStyle(
          color: Colors.yellow,
          fontWeight: FontWeight.w900,
          fontSize: 32,
        ), path: 'assets/car2.png');
    _markers.add(Marker(
        markerId: MarkerId(widget.locationResponse.vehicleId!),
        icon: icon,
        zIndex: 2,
        position: latLng,
        onTap: () {
          pp('$mm ... car tapped. find routes ...');
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
    final c = prefs.getColorAndLocale();
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
                    onMapCreated: (cont) async {
                      pp('\n$mm .......... on onMapCreated .....');
                      googleMapController = cont;
                      try {
                        _mapController.complete(cont);
                      } catch (e) {
                        pp('$mm error ignored: $e');
                      }
                      await _getRoutes();
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
