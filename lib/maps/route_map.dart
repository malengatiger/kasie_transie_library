import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';

import '../bloc/data_api_dog.dart';
import '../bloc/sem_cache.dart';
import '../utils/emojis.dart';

class RouteMap extends StatefulWidget {
  const RouteMap({
    super.key,
    required this.route,
  });

  final lib.Route route;
  @override
  RouteMapState createState() => RouteMapState();
}

class RouteMapState extends State<RouteMap> {
  static const defaultZoom = 14.0;
  final Completer<GoogleMapController> _mapController = Completer();
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  //Latitude: -25.7605348, Longitude: 27.8525771
  CameraPosition? _myCurrentCameraPosition = const CameraPosition(
    target: LatLng(-25.7805348, 27.8225771),
    zoom: defaultZoom,
  );
  static const mm = '😡😡😡😡😡😡😡 RouteMap: 💪 ';
  final _key = GlobalKey<ScaffoldState>();
  bool busy = false;
  bool isHybrid = true;
  lib.User? _user;
  geo.Position? _currentPosition;
  final Set<Marker> _markers = HashSet();
  final Set<Circle> _circles = HashSet();
  final Set<Polyline> _polyLines = {};
  BitmapDescriptor? _dotMarker;

  // List<BitmapDescriptor> _numberMarkers = [];
  final List<lib.RoutePoint> rpList = [];
  List<lib.RoutePoint> existingRoutePoints = [];

  // List<lib.Landmark> _landmarks = [];

  List<LatLng>? polylinePoints;
  Color color = Colors.black;
  var routeLandmarks = <lib.RouteLandmark>[];
  int landmarkIndex = 0;

  @override
  void initState() {
    super.initState();
    _setTexts();
    _getUser();
  }

  String? waitingForGPS, youAreHere, currentLocation;

  void _setTexts() async {
    final c = prefs.getColorAndLocale();
    waitingForGPS = await translator.translate('errorCount', c.locale);
    youAreHere = await translator.translate('youAreHere', c.locale);
    currentLocation = await translator.translate('currentLocation', c.locale);
  }

  void _getRouteMap() async {
    color = getColor(widget.route.color!);
    await _getRoutePoints(widget.route, false);
    await _getRouteLandmarks(widget.route, false);
    await _buildMap();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color newColor = Colors.black;
  String? stringColor;

  Future _getRouteLandmarks(lib.Route route, bool refresh) async {
    routeLandmarks =
        await listApiDog.getRouteLandmarks(route.routeId!, refresh, route.associationId!);
    pp('$mm _getRouteLandmarks ...  route: ${route.name}; found: ${routeLandmarks.length} ');

    setState(() {});
  }

  void _showNoPointsDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            elevation: 12,
            title: Text(
              'Route Point Mapping',
              style: myTextStyleLarge(context),
            ),
            content: Card(
              shape: getDefaultRoundedBorder(),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('This route has not been completely defined yet.'),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    _popOut();
                  },
                  child: const Text('Close')),
            ],
          );
        });
  }

  void _popOut() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future _getRoutePoints(lib.Route route, bool refresh) async {
    setState(() {
      busy = true;
    });
    try {
      var semCache = GetIt.instance<SemCache>();

      _user = prefs.getUser();
      pp('$mm getting existing RoutePoints .......');
      existingRoutePoints =
          await semCache.getRoutePoints(route.routeId!, route.associationId!);
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  Future<void> _buildMap() async {
    pp('$mm .......... existingRoutePoints ....  🍎 found: '
        '${existingRoutePoints.length} points');
    if (existingRoutePoints.isEmpty) {
      setState(() {
        busy = false;
      });
      _showNoPointsDialog();
      //return;
    }
    _addPolyLine();
    landmarkIndex = 0;
    for (var rl in routeLandmarks) {
      final icon = await getMarkerBitmap(text: '${landmarkIndex + 1}',
          80, color: widget.route.color!,
          fontSize: 20, fontWeight: FontWeight.w900);
      _markers.add(Marker(
          markerId: MarkerId(rl.landmarkId!),
          icon: icon,
          zIndex: 1,
          position:
              LatLng(rl.position!.coordinates[1], rl.position!.coordinates[0]),
          infoWindow: InfoWindow(
              title: rl.landmarkName, snippet: '🍎Part of ${rl.routeName}')));
      landmarkIndex++;
    }
    //add current location
    final loc = await locationBloc.getLocation();
    final latLng = LatLng(loc.latitude, loc.longitude);

    final icon = await getTaxiMapIcon(iconSize: 180, text: 'You are here',
        style:const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
        path: 'assets/car2.png');
    _markers.add(Marker(
        markerId: const MarkerId('myLocation'),
        position: latLng,
        icon: icon,
        zIndex: 4.0,
        infoWindow: InfoWindow(
            title:
                currentLocation == null ? 'Current Location' : currentLocation!,
            snippet: youAreHere == null ? 'You are here at ' : youAreHere!)));

    _zoomToCurrentLocation(loc.latitude, loc.longitude);
    pp('$mm ....................... ${E.redDot} my location $loc');
    setState(() {});
  }

  Future _getUser() async {
    _user = prefs.getUser();
    _makeDotMarker();
  }

  Future _makeDotMarker() async {
    var intList = await getBytesFromAsset("assets/markers/dot2.png", 40);
    _dotMarker = BitmapDescriptor.fromBytes(intList);
    pp('$mm custom marker 💜 assets/markers/dot2.png created');
  }

  Future _getMyLocation() async {
    pp('$mm .......... get current location ....');
    _currentPosition = await locationBloc.getLocation();
    _putCarOnMap();
    pp('$mm .......... get current location ....  🍎 found: ${_currentPosition!.toJson()}');
    _myCurrentCameraPosition = CameraPosition(
      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      zoom: defaultZoom,
    );
    setState(() {});
  }

  Future<void> _zoomToCurrentLocation(double latitude, double longitude) async {
    final latLng = LatLng(latitude, longitude);
    var cameraPos = CameraPosition(target: latLng, zoom: defaultZoom);
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
    setState(() {});
  }

  int index = 0;
  final numberMarkers = <BitmapDescriptor>[];

  void _putCarOnMap() {
    pp('$mm .......... _putCarOnMap ....  🍎 put it here: ${_currentPosition!.toJson()}');

    var latLng =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    _markers.add(Marker(
      markerId: MarkerId('${DateTime.now().millisecondsSinceEpoch}'),
      // icon: carIcon,
      zIndex: 1.0,
      position: latLng,
      infoWindow:
          const InfoWindow(title: 'Current Location', snippet: 'You are here'),
    ));
    pp('$mm .......... _putCarOnMap ....  🍎 set state');

    setState(() {});
  }


  _clearMap() {
    _polyLines.clear();
    _markers.clear();
  }

  void _addPolyLine() {
    pp('$mm .......... _addPolyLine ....... .');
    _polyLines.clear();
    var mPoints = <LatLng>[];
    existingRoutePoints.sort((a, b) => a.index!.compareTo(b.index!));
    for (var rp in existingRoutePoints) {
      mPoints.add(LatLng(
          rp.position!.coordinates.last, rp.position!.coordinates.first));
    }
    _clearMap();
    var polyLine = Polyline(
        color: color,
        width: 8,
        points: mPoints,
        polylineId: PolylineId(DateTime.now().toIso8601String()));

    _polyLines.add(polyLine);
    setState(() {});
  }

  lib.Route? routeSelected;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.route.name}',
            style: myTextStyleSmall(context),
          ),
        ),
        key: _key,
        body: _myCurrentCameraPosition == null
            ? Center(
                child: Text(
                  waitingForGPS == null
                      ? 'Waiting for GPS location ...'
                      : waitingForGPS!,
                  style: myTextStyleMediumBold(context),
                ),
              )
            : Stack(children: [
                GoogleMap(
                  mapType: isHybrid ? MapType.hybrid : MapType.normal,
                  myLocationEnabled: true,
                  markers: _markers,
                  circles: _circles,
                  polylines: _polyLines,
                  initialCameraPosition: _myCurrentCameraPosition!,
                  onTap: (latLng) {
                    pp('$mm .......... on map tapped : $latLng .');
                  },
                  onMapCreated: (GoogleMapController controller) async {
                    pp('$mm .......... on onMapCreated .....');
                    _mapController.complete(controller);
                    _getRouteMap();
                  },
                ),
                Positioned(
                    right: 12,
                    top: 120,
                    child: Container(
                      color: Colors.black45,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                isHybrid = !isHybrid;
                              });
                            },
                            icon: Icon(
                              Icons.album_outlined,
                              color: isHybrid ? Colors.yellow : Colors.white,
                            )),
                      ),
                    )),
                busy
                    ? const Positioned(
                        top: 160,
                        left: 48,
                        child: Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 12,
                              backgroundColor: Colors.pink,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ]));
  }
}

class RouteDropDown extends StatelessWidget {
  const RouteDropDown(
      {super.key, required this.routes, required this.onRoutePicked});
  final List<lib.Route> routes;
  final Function(lib.Route) onRoutePicked;

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<lib.Route>>[];
    for (var r in routes) {
      items.add(
        DropdownMenuItem<lib.Route>(
          value: r,
          child: Text(
            r.name!, overflow: TextOverflow.clip,
            softWrap: false,
            style: myTextStyleSmall(context),
          ),
        ),
      );
    }
    return DropdownButton(
        hint: Text(
          'Select Route',
          style: myTextStyleSmall(context),
        ),
        items: items,
        onChanged: (r) {
          if (r != null) {
            onRoutePicked(r);
          }
        });
  }
}
