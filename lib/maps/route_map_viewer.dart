import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/maps/route_creator_map2.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:page_transition/page_transition.dart';

import '../bloc/data_api_dog.dart';
import '../bloc/list_api_dog.dart';
import '../data/data_schemas.dart';
import '../data/route_data.dart';
import '../utils/prefs.dart';
import '../widgets/timer_widget.dart';

class RouteMapViewer extends StatefulWidget {
  final lib.Route route;
  final Function onRouteUpdated;

  const RouteMapViewer({
    super.key,
    required this.route,
    required this.onRouteUpdated,
  });

  @override
  RouteMapViewerState createState() => RouteMapViewerState();
}

class RouteMapViewerState extends State<RouteMapViewer> {
  static const defaultZoom = 13.0;
  final Completer<GoogleMapController> _mapController = Completer();
  late GoogleMapController googleMapController;
  CameraPosition? _myCurrentCameraPosition;
  static const mm = '😡😡😡😡😡😡😡 RouteMapViewer: 💪 ';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  final _key = GlobalKey<ScaffoldState>();
  bool busy = false;
  bool isHybrid = true;
  lib.User? _user;
  Position? _currentPosition;
  final Set<Marker> _markers = HashSet();
  final Set<Circle> _circles = HashSet();
  final Set<Polyline> _polyLines = {};
  final List<lib.RoutePoint> rpList = [];
  List<lib.RoutePoint> existingRoutePoints = [];

  List<LatLng>? polylinePoints;
  Color color = Colors.black;
  var routeLandmarks = <lib.RouteLandmark>[];
  int landmarkIndex = 0;
  lib.Route? route;
  String? stringColor;
  String routeMapViewer = 'Viewer', changeColor = '';

  @override
  void initState() {
    super.initState();
    _setTexts();
    _setRouteColor();
    _getCurrentRouteLocation();
    _getUser();
  }

  Future _setTexts() async {
    final c = prefs.getColorAndLocale();
    routeMapViewer = await translator.translate('routeMapViewer', c.locale);
    changeColor = await translator.translate('changeColor', c.locale);

    setState(() {});
  }

  Future _setRouteColor() async {
    route = widget.route;
    color = getColor(route!.color!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _getRouteLandmarks() async {
    routeLandmarks = routeData!.landmarks;
    pp('$mm _getRouteLandmarks ...  route: ${widget.route.routeId!}; found: ${routeLandmarks.length} ');

    landmarkIndex = 0;
    for (var landmark in routeLandmarks) {
      final latLng = LatLng(landmark.position!.coordinates.last,
          landmark.position!.coordinates.first);

      final icon = await getMarkerBitmap(72,
          text: '${landmarkIndex + 1}',
          color: route!.color ?? 'black',
          fontSize: 14,
          fontWeight: FontWeight.w900);

      _markers.add(Marker(
          markerId: MarkerId('${landmark.landmarkId}'),
          icon: icon,
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
                    NavigationUtils.navigateTo(
                        context: context,
                        widget: RouteCreatorMap2(route: route!),
                        );
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

  SemCache semCache = GetIt.instance<SemCache>();

  Future _getRoutePoints(bool refresh) async {
    setState(() {
      busy = true;
    });
    try {
      _user = prefs.getUser();
      pp('$mm getting existing RoutePoints .......');
      existingRoutePoints = routeData!.routePoints;

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
    _user = prefs.getUser();
  }

  RouteData? routeData;
  Future _getCurrentRouteLocation() async {
    pp('$mm .......... get current route ....');

    routeData = await semCache.getRouteData(
        associationId: widget.route.associationId!,
        routeId: widget.route.routeId!);
    if (routeData != null) {
      route = routeData!.route!;
      _myCurrentCameraPosition = CameraPosition(
        target: LatLng(route!.routeStartEnd!.startCityPosition!.coordinates[1],
            route!.routeStartEnd!.startCityPosition!.coordinates[0]),
        zoom: defaultZoom,
      );
    } else {
      _myCurrentCameraPosition = const CameraPosition(
        target: LatLng(-24.0, 26.0),
        zoom: defaultZoom,
      );
    }
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
  bool showColors = false;
  var topHeight = 100.0;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: _key,
        body: _myCurrentCameraPosition == null
            ? Center(
                child: TimerWidget(title: waitingForGPS, isSmallSize: true),
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
                                        Text(
                                          routeMapViewer,
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
                                Icons.refresh,
                                color: Theme.of(context).primaryColor,
                              )),
                          const SizedBox(
                            width: 28,
                          ),
                          // IconButton(
                          //     onPressed: () {
                          //       _showColorChoices();
                          //     },
                          //     icon: Icon(
                          //       Icons.color_lens,
                          //       color: Theme.of(context).primaryColor,
                          //     ))
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
