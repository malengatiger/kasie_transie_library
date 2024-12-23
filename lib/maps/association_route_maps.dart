import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/route_widgets/multi_route_chooser.dart';

import '../bloc/list_api_dog.dart';
import '../bloc/sem_cache.dart';
import '../data/route_data.dart';
import '../utils/device_location_bloc.dart';
import '../utils/emojis.dart';
import '../utils/prefs.dart';
import '../widgets/timer_widget.dart';

class AssociationRouteMaps extends StatefulWidget {
  const AssociationRouteMaps({
    super.key,
    this.latitude,
    this.longitude,
    this.radiusInMetres,
  });

  final double? latitude, longitude, radiusInMetres;

  @override
  AssociationRouteMapsState createState() => AssociationRouteMapsState();
}

class AssociationRouteMapsState extends State<AssociationRouteMaps> {
  static const defaultZoom = 14.0;
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition? _myCurrentCameraPosition = const CameraPosition(
    target: LatLng(-25.8656, 27.7564),
    zoom: defaultZoom,
  );
  static const mm = '😡😡😡😡😡😡😡 AssociationRouteMaps: 💪 ';
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
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

  List<LatLng>? polylinePoints;
  Color color = Colors.black;
  var routeLandmarks = <lib.RouteLandmark>[];
  int landmarkIndex = 0;
  var routes = <lib.Route>[];

  AssociationRouteData? routeData;
  @override
  void initState() {
    super.initState();
  }

  Future _getRoutes(bool refresh) async {
    setState(() {
      busy = true;
    });

    try {
      _user = prefs.getUser();
      routeData =
          await listApiDog.getAssociationRouteData(_user!.associationId!, refresh);
      if (routeData != null) {
        for (var rd in routeData!.routeDataList) {
          routes.add(rd.route!);
        }
      }
      await _filter();
      _printMe();
      if (mounted) {
        showToast(
            backgroundColor: Colors.black,
            textStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            padding: 24.0,
            duration: const Duration(seconds: 3),
            message: 'Please select routes',
            context: context);
      }

      // _showBottomSheet();
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(
            backgroundColor: Colors.amber[700],
            textStyle: myTextStyleMediumBlack(context),
            message: 'Error: $e',
            context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  void _printMe() {
    int cnt = 1;
    for (var r in routes) {
      pp('$mm route #:$cnt ${E.appleRed} ${r.name}');
      cnt++;
    }
  }

  Future<void> _filter() async {
    List<lib.Route> filtered = [];
    var semCache = GetIt.instance<SemCache>();

    for (var rd in routeData!.routeDataList) {
      final marks = rd.landmarks;
      if (marks.isNotEmpty) {
        filtered.add(rd.route!);
      }
    }
    pp('routes have been filtered .. ${filtered.length}');
    routes = filtered;

  }

 List<lib.Route> routesPicked = [];
  void _showBottomSheet() async {
    final type = getThisDeviceType();
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Padding(
            padding:
                EdgeInsets.symmetric(horizontal: type == 'phone' ? 12.0 : 48),
            child: MultiRouteChooser(
              hideAppBar: true,
              onRoutesPicked: (routesPicked) {
                setState(() {
                  this.routesPicked = routesPicked;
                });
                Navigator.of(context).pop();
                _buildHashMap();
              },
              routes: routes,
              quitOnDone: false,
            ),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color newColor = Colors.black;
  String? stringColor;

  DeviceLocationBloc locationBloc = GetIt.instance<DeviceLocationBloc>();

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
      var cameraPos = CameraPosition(target: latLng, zoom: 12.0);
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
      setState(() {});
    }
  }

  int index = 0;
  final numberMarkers = <BitmapDescriptor>[];

  Future<void> _addLandmarks(
      {required List<lib.RouteLandmark> routeLandmarks,
      required List<BitmapDescriptor> icons,
      required String color}) async {
    pp('$mm .......... _addLandmarks ....... .routeLandmarks: ${routeLandmarks.length}');

    int landmarkIndex = 0;
    try {
      for (var routeLandmark in routeLandmarks) {
        _markers.add(Marker(
            markerId: MarkerId(routeLandmark.landmarkId!),
            icon: icons.elementAt(landmarkIndex),
            position: LatLng(routeLandmark.position!.coordinates[1],
                routeLandmark.position!.coordinates[0]),
            infoWindow: InfoWindow(
                title: routeLandmark.landmarkName,
                snippet: '🍎Part of ${routeLandmark.routeName}')));
        landmarkIndex++;
      }
    } catch (e, stack) {
      pp('$mm $e - $stack');
    }
  }

  Random random = Random(DateTime.now().millisecondsSinceEpoch);
  var widthIndex = 0;

  void _addPolyLine(List<lib.RoutePoint> points, Color color) {
    pp('$mm .......... _addPolyLine ....... points: ${points.length}.');
    var mPoints = <LatLng>[];
    points.sort((a, b) => a.index!.compareTo(b.index!));
    for (var rp in points) {
      mPoints.add(LatLng(
          rp.position!.coordinates.last, rp.position!.coordinates.first));
    }
    int width = (widthIndex + 1) * 6;
    if (width > 12) {
      width = 10;
    }
    var polyLine = Polyline(
        color: color,
        width: 8,
        points: mPoints,
        onTap: () {
          pp('$mm ... polyLine tapped; route: ${points.first.routeName}');
          if (mounted) {
            showToast(message: '${points.first.routeName}', context: context);
          }
        },
        consumeTapEvents: true,
        polylineId: PolylineId(DateTime.now().toIso8601String()));

    _polyLines.add(polyLine);
    widthIndex++;
    setState(() {});
  }

  lib.Route? routeSelected;
  final hashMap = HashMap<String, MapBag>();

  void _buildHashMap() async {
    pp('$mm ... _buildHashMap: routesPicked: ${routesPicked.length}');

    for (var route in routesPicked) {
      for (var rd in routeData!.routeDataList) {
        if (rd.route!.routeId! == route.routeId) {
          final points = rd.routePoints;
          final marks =rd.landmarks;
          final icons = <BitmapDescriptor>[];
          for (var i = 0; i < marks.length; i++) {
            final icon = await getMarkerBitmap(72,
                text: '${i + 1}',
                color: route.color!,
                fontSize: 28,
                fontWeight: FontWeight.w900);
            icons.add(icon);
          }
          final bag = MapBag(route, points, marks, icons);
          hashMap[route.routeId!] = bag;
        }
      }
    }
    pp('$mm ... _buildHashMap: hashMap built: ${hashMap.length}');

    _markers.clear();
    _polyLines.clear();

    final list = hashMap.values.toList();
    for (var bag in list) {
      _addPolyLine(bag.routePoints, getColor(bag.route.color!));
      _addLandmarks(
          routeLandmarks: bag.routeLandmarks,
          icons: bag.landmarkIcons,
          color: bag.route.color!);
    }
    if (hashMap.isNotEmpty) {
      _zoomToBeginningOfRoute(hashMap.values.toList().first.route);
    }
  }

  int distanceInKM = 100;
  bool showSheet = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Association Route Maps'),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: const ButtonStyle(
                            elevation: WidgetStatePropertyAll(8.0),
                          ),
                          onPressed: () {
                            _showBottomSheet();
                          },
                          child: SizedBox(
                            width: 300,
                            child: Text('Tap to select some of ${routes.length} Routes'),
                          )),
                      gapW8,
                    ],
                  ),
                  gapH16,
                ],
              )),
        ),
        key: _key,
        body: _myCurrentCameraPosition == null
            ? const Center(
                child: TimerWidget(title: 'Loading ...', isSmallSize: false),
              )
            : Stack(children: [
                GoogleMap(
                  mapType: isHybrid ? MapType.hybrid : MapType.normal,
                  myLocationEnabled: true,
                  markers: _markers,
                  circles: _circles,
                  polylines: _polyLines,
                  initialCameraPosition: _myCurrentCameraPosition!,
                  // onTap: (latLng) {
                  //   pp('$mm .......... on map tapped : $latLng .');
                  // },
                  onMapCreated: (GoogleMapController controller) {
                    pp('$mm .......... on onMapCreated .....');
                    _mapController.complete(controller);
                    showSheet = true;
                    _getCurrentLocation();
                    _getRoutes(false);
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
      items.add(DropdownMenuItem<lib.Route>(
          value: r,
          child: SizedBox(
            // width: 600,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    r.name!,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: myTextStyleSmall(context),
                  ),
                ),
              ],
            ),
          )));
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

class MapBag {
  late lib.Route route;
  List<lib.RoutePoint> routePoints = [];
  List<lib.RouteLandmark> routeLandmarks = [];
  List<BitmapDescriptor> landmarkIcons = [];

  MapBag(this.route, this.routePoints, this.routeLandmarks, this.landmarkIcons);
}
