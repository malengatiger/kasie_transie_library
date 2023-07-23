import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poly;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/isolates/routes_isolate.dart';
import 'package:kasie_transie_library/maps/route_creator_map2.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';

import '../widgets/color_pad.dart';
import '../widgets/tiny_bloc.dart';
import 'package:kasie_transie_library/l10n/translation_handler.dart';

class RouteMapViewer extends StatefulWidget {
  final String routeId;
  final Function onRouteUpdated;
  const RouteMapViewer({
    Key? key,
    required this.onRouteUpdated,
    required this.routeId,
  }) : super(key: key);

  @override
  RouteMapViewerState createState() => RouteMapViewerState();
}

class RouteMapViewerState extends State<RouteMapViewer> {
  static const defaultZoom = 14.0;
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition? _myCurrentCameraPosition;
  static const mm = '😡😡😡😡😡😡😡 RouteMapViewer: 💪 ';
  final _key = GlobalKey<ScaffoldState>();
  bool busy = false;
  bool isHybrid = true;
  lib.User? _user;
  geo.Position? _currentPosition;
  final Set<Marker> _markers = HashSet();
  final Set<Circle> _circles = HashSet();
  final Set<Polyline> _polyLines = {};
  final List<lib.RoutePoint> rpList = [];
  List<lib.RoutePoint> existingRoutePoints = [];

  List<poly.PointLatLng>? polylinePoints;
  Color color = Colors.black;
  var routeLandmarks = <lib.RouteLandmark>[];
  int landmarkIndex = 0;
  lib.Route? route;

  @override
  void initState() {
    super.initState();
    _setTexts();
    _getCurrentLocation();
    _getUser();
  }

  Future _setTexts() async {
    final c = await prefs.getColorAndLocale();
    routeMapViewer = await translator.translate('routeMapViewer', c.locale);
    changeColor = await translator.translate('changeColor', c.locale);

    setState(() {});
  }
  Future _getRoute() async {
    setState(() {
      busy = true;
    });
    try {
      route = await listApiDog.getRoute(widget.routeId);
      if (route == null) {
        throw Exception('Route not afraid');
      }
      color = getColor(route!.color!);
      _zoomToStartCity();
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color newColor = Colors.black;
  String? stringColor;
  String routeMapViewer = 'Viewer', changeColor = '';

  void changeRouteColorOnBackend() async {
    pp('$mm ... updateRouteColor ...color: $stringColor');
    color = newColor;
    _addPolyLine();
    setState(() {});
    try {
      final m = await dataApiDog.updateRouteColor(
          routeId: widget.routeId!, color: stringColor!);
      pp('$mm ... color has been updated ... result: $m ; 0 is good!');
      tinyBloc.setRouteId(widget.routeId);
      _getRouteLandmarks();
    } catch (e) {
      pp(e);
    }
    //
  }

  void _showModalSheet() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Card(
            shape: getDefaultRoundedBorder(),
            elevation: 8,
            child: Column(
              children: [
                const SizedBox(
                  height: 28,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(changeColor,
                      style: myTextStyleLarge(context),
                    ),
                    const SizedBox(
                      width: 28,
                    ),
                    Container(
                      height: 48,
                      width: 48,
                      color: newColor,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                ColorPad(
                  onColorPicked: (mColor, string) {
                    pp('$mm ....... 🍎🍎🍎🍎🍎🍎 onColorPicked picked ... $stringColor');
                    setState(() {
                      newColor = mColor;
                      stringColor = string;
                    });
                    Navigator.pop(context);
                    _updateRouteColor();
                  },
                ),
              ],
            ),
          );
        });
  }

  void _updateRouteColor() {
    pp('$mm ....... 🍎🍎🍎🍎🍎🍎 onColorPicked start update ... $stringColor');
    changeRouteColorOnBackend();
  }

  Future _getRouteLandmarks() async {
    routeLandmarks = await listApiDog.getRouteLandmarks(widget.routeId, false);
    pp('$mm _getRouteLandmarks ...  route: ${widget.routeId}; found: ${routeLandmarks.length} ');

    landmarkIndex = 0;
    await _buildLandmarkIcons(routeLandmarks.length);
    for (var landmark in routeLandmarks) {
      final latLng = LatLng(landmark.position!.coordinates.last,
          landmark.position!.coordinates.first);
      _markers.add(Marker(
          markerId: MarkerId('${landmark.landmarkId}'),
          icon: numberMarkers.elementAt(landmarkIndex),
          onTap: () {
            pp('$mm .............. marker tapped, index: $index, $latLng - '
                'landmarkId: ${landmark.landmarkId} - routeId: ${landmark.routeId}');
          },
          infoWindow: InfoWindow(
              snippet:
                  '\nThis landmark is part of the route:\n ${route!.name}\n\n',
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
              shape: getDefaultRoundedBorder(),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('This route has no points defined yet.\n\n'
                    'Do you want to start mapping the route?'),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    _popOut();
                  },
                  child: const Text('No')),
              TextButton(
                  onPressed: () {
                    _popOut();
                    navigateWithScale(RouteCreatorMap2(route: route!), context);
                  },
                  child: const Text('Yes')),
            ],
          );
        });
  }

  void _popOut() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future _getRoutePoints(bool refresh) async {
    setState(() {
      busy = true;
    });
    try {
      _user = await prefs.getUser();
      pp('$mm getting existing RoutePoints .......');
      existingRoutePoints =
          await routesIsolate.getRoutePoints(widget.routeId, refresh);

      pp('$mm .......... existingRoutePoints ....  🍎 found: '
          '${existingRoutePoints.length} points');
      if (existingRoutePoints.isEmpty) {
        setState(() {
          busy = false;
        });
        _showNoPointsDialog();
        return;
      }
      _addPolyLine();
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
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  Future _getUser() async {
    _user = await prefs.getUser();
    _makeDotMarker();
  }

  Future _makeDotMarker() async {
    var intList = await getBytesFromAsset("assets/markers/dot2.png", 40);
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

  Future<void> _zoomToStartCity() async {
    if (route == null) {
      return;
    }
    if (route!.routeStartEnd != null) {
      final latLng = LatLng(
          route!.routeStartEnd!.startCityPosition!.coordinates.last,
          route!.routeStartEnd!.startCityPosition!.coordinates.first);
      var cameraPos = CameraPosition(target: latLng, zoom: 16.0);
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
      setState(() {});
    }
  }

  int index = 0;
  final numberMarkers = <BitmapDescriptor>[];
  Future _buildLandmarkIcons(int cnt) async {
    for (var i = 0; i < cnt; i++) {
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

  String waitingForGPS = 'waitingForGPS';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        body: _myCurrentCameraPosition == null
            ? Center(
                child: Text(
                  waitingForGPS,
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
                    _mapController.complete(controller);
                    await _getRoute();
                    await _getRoutePoints(false);
                    _getRouteLandmarks();
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
                    left: 12,
                    top: 40,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: route == null
                            ? const SizedBox()
                            : Card(
                                color: Colors.black26,
                                elevation: 24,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 100,
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(routeMapViewer,
                                          style:
                                              myTextStyleMediumLargeWithColor(
                                                  context, Colors.white, 24),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.arrow_back_ios,
                                              size: 24,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${route!.name}',
                                                style:
                                                    myTextStyleMediumWithColor(
                                                        context, Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${route!.associationName}',
                                          style: myTextStyleTiny(context),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ))),
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
                                _getRoutePoints(true);
                              },
                              icon: Icon(
                                Icons.toggle_on,
                                color: Theme.of(context).primaryColor,
                              )),
                          const SizedBox(
                            width: 28,
                          ),
                          IconButton(
                              onPressed: () {
                                _showModalSheet();
                              },
                              icon: Icon(
                                Icons.color_lens,
                                color: Theme.of(context).primaryColor,
                              ))
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
                              strokeWidth: 4,
                              backgroundColor: Colors.pink,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ]));
  }
}
