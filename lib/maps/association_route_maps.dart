import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poly;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/providers/kasie_providers.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/local_finder.dart';
import 'package:kasie_transie_library/utils/prefs.dart';

class AssociationRouteMaps extends StatefulWidget {
  const AssociationRouteMaps({
    Key? key,
  }) : super(key: key);

  @override
  AssociationRouteMapsState createState() => AssociationRouteMapsState();
}

class AssociationRouteMapsState extends State<AssociationRouteMaps> {
  static const defaultZoom = 16.0;
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition? _myCurrentCameraPosition = const CameraPosition(
    target: LatLng(-25.8656, 27.7564),
    zoom: defaultZoom,
  );
  static const mm = '😡😡😡😡😡😡😡 RouteMapStatic: 💪 ';
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

  List<poly.PointLatLng>? polylinePoints;
  Color color = Colors.black;
  var routeLandmarks = <lib.RouteLandmark>[];
  int landmarkIndex = 0;
  var routes = <lib.Route>[];

  @override
  void initState() {
    super.initState();
    _buildLandmarkIcons();
    _getCurrentLocation();
    _getUser();
  }

  Future _getRoutes() async {
    setState(() {
      busy = true;
    });
    try {
      _user = await prefs.getUser();
      final loc = await locationBloc.getLocation();
      pp('\n\n$mm .......... findAssociationRoutesByLocation ...');

      routes = await localFinder.findNearestRoutes(latitude: loc.latitude, longitude: loc.longitude,
          radiusInMetres: 1000 * 100);

    } catch (e) {
      pp(e);
      showSnackBar(
          backgroundColor: Colors.pink[300],
          textStyle: myTextStyleMediumBlack(context),
          message: 'Error: $e',
          context: context);
    }
    setState(() {
      busy = false;
    });
  }

  void _getRouteMap(lib.Route route) async {
    color = getColor(route.color!);
    await _getRoutePoints(route, false);
    await _getRouteLandmarks(route, false);
    await _buildMap();
    _zoomToBeginningOfRoute(route);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color newColor = Colors.black;
  String? stringColor;

  Future _getRouteLandmarks(lib.Route route, bool refresh) async {
    routeLandmarks =
        await listApiDog.getRouteLandmarks(route.routeId!, refresh);
    pp('$mm _getRouteLandmarks ...  route: ${route.name}; found: ${routeLandmarks.length} ');

    landmarkIndex = 0;
    for (var landmark in routeLandmarks) {
      final latLng = LatLng(landmark.position!.coordinates.last,
          landmark.position!.coordinates.first);
      _markers.add(Marker(
          markerId: MarkerId('${landmark.landmarkId}'),
          icon: numberMarkers.elementAt(landmarkIndex),
          onTap: () {
            pp('$mm .............. marker tapped: $index');
          },
          infoWindow: InfoWindow(
              snippet:
                  '\nThis landmark is part of the route:\n ${route.name}\n\n',
              title: '🍎 ${landmark.landmarkName}',
              onTap: () {
                pp('$mm ............. infoWindow tapped, point index: $index');
                //_deleteLandmark(landmark);
              }),
          position: latLng));
      landmarkIndex++;
    }
    setState(() {});
  }

  void _showNoPointsDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            elevation: 12,
            title: Text(
              'Route Mapping',
              style: myTextStyleLarge(context),
            ),
            content: Card(
              shape: getRoundedBorder(radius: 16),
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
      _user = await prefs.getUser();
      pp('$mm getting existing RoutePoints .......');
      existingRoutePoints =
          await listApiDog.getRoutePoints(route.routeId!, refresh);
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
      _markers.add(Marker(markerId: MarkerId(rl.landmarkId!),
      icon: numberMarkers.elementAt(landmarkIndex),
      position: LatLng(rl.position!.coordinates[1], rl.position!.coordinates[0]),
        infoWindow: InfoWindow(
          title: rl.landmarkName,
          snippet: '🍎Part of ${rl.routeName}'
        )
      ));
      landmarkIndex++;
    }
    setState(() {});
    var point = existingRoutePoints.first;
    var latLng = LatLng(
        point.position!.coordinates.last, point.position!.coordinates.first);
    _myCurrentCameraPosition = CameraPosition(
      target: latLng,
      zoom: defaultZoom,
    );
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(_myCurrentCameraPosition!));
  }

  Future _getUser() async {
    _user = await prefs.getUser();
    _makeDotMarker();
  }

  Future _makeDotMarker() async {
    var intList = await getBytesFromAsset("assets/markers/dot2.png", 40);
    _dotMarker = BitmapDescriptor.fromBytes(intList);
    pp('$mm custom marker 💜 assets/markers/dot2.png created');
  }

  Future _getCurrentLocation() async {
    pp('$mm .......... get current location ....');
    _currentPosition = await locationBloc.getLocation();

    pp('$mm .......... get current location ....  🍎 found: ${_currentPosition!.toJson()}');
    _myCurrentCameraPosition = CameraPosition(
      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      zoom: defaultZoom,
    );
    setState(() {});
  }

  Future<void> _zoomToBeginningOfRoute(lib.Route route) async {
    if (route.routeStartEnd != null) {
      final latLng = LatLng(
          route.routeStartEnd!.startCityPosition!.coordinates.last,
          route.routeStartEnd!.startCityPosition!.coordinates.first);
      var cameraPos = CameraPosition(target: latLng, zoom: 11.0);
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
      setState(() {});
    }
  }

  int index = 0;
  final numberMarkers = <BitmapDescriptor>[];

  Future _buildLandmarkIcons() async {
    for (var i = 0; i < 100; i++) {
      var intList =
          await getBytesFromAsset("assets/numbers/number_${i + 1}.png", 84);
      numberMarkers.add(BitmapDescriptor.fromBytes(intList));
    }
    pp('$mm have built ${numberMarkers.length} markers for landmarks');
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

  void _refreshRoute(lib.Route route) async {
    pp('$mm .... _refreshRoute ....');
    setState(() {
      busy = true;
    });
    try {
      final bag = await listApiDog.refreshRoute(route.routeId!);
      existingRoutePoints = bag.routePoints;
      _buildMap();
      if (mounted) {
        showSnackBar(
            padding: 20,
            backgroundColor: Theme.of(context).primaryColorLight,
            message: 'Route has been refreshed',
            context: context);
      }
    } catch (e) {
      pp(e);
      showSnackBar(message: 'Error: $e', context: context);
    }
    setState(() {
      busy = true;
    });
  }

  lib.Route? routeSelected;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: RouteDropDown(
                    routes: routes,
                    onRoutePicked: (r) {
                      setState(() {
                        routeSelected = r;
                      });
                      _getRouteMap(r);
                    }),
              ),
            ],
          ),
        ),
        key: _key,
        body: _myCurrentCameraPosition == null
            ? Center(
                child: Text(
                  'Waiting for GPS location ...',
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
                  onMapCreated: (GoogleMapController controller) {
                    pp('$mm .......... on onMapCreated .....');
                    _mapController.complete(controller);
                    _getRoutes();
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
                Positioned(
                    right: 12,
                    top: 40,
                    child: Card(
                      elevation: 8,
                      shape: getRoundedBorder(radius: 12),
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                if (routeSelected != null) {
                                  _refreshRoute(routeSelected!);
                                }
                              },
                              icon: Icon(
                                Icons.toggle_on,
                                color: Theme.of(context).primaryColor,
                              )),
                          const SizedBox(
                            width: 28,
                          ),
                        ],
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
      {Key? key, required this.routes, required this.onRoutePicked})
      : super(key: key);
  final List<lib.Route> routes;
  final Function(lib.Route) onRoutePicked;

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<lib.Route>>[];
    for (var r in routes) {
      items.add(DropdownMenuItem<lib.Route>(value: r, 
          child: Text(r.name!, style: myTextStyleSmall(context),)));
    }
    return DropdownButton(
        hint:  Text('Select Route', style: myTextStyleSmall(context),),
        items: items,
        onChanged: (r) {
          if (r != null) {
            onRoutePicked(r);
          }
        });
  }
}
