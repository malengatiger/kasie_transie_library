import 'dart:async';
import 'dart:collection';
import 'dart:math';

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
import 'package:kasie_transie_library/widgets/route_widgets/multi_route_chooser.dart';

import '../isolates/routes_isolate.dart';

class AssociationRouteMaps extends StatefulWidget {
  const AssociationRouteMaps({
    Key? key,
    this.latitude,
    this.longitude,
    this.radiusInMetres,
  }) : super(key: key);

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
    _control();
  }

  void _control() async {
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
      if (widget.latitude != null && widget.longitude != null) {
        pp('\n\n$mm .......... find Association Routes by location ...');
        routes = await localFinder.findNearestRoutes(
            latitude: widget.latitude!,
            longitude: widget.longitude!,
            radiusInMetres:
            widget.radiusInMetres == null ? 2000 : widget.radiusInMetres!);
      } else {
        pp('\n\n$mm .......... get all Association Routes ...');
        routes = await listApiDog
            .getRoutes(AssociationParameter(_user!.associationId!, false));
      }
    } catch (e) {
      pp(e);
      showSnackBar(
          backgroundColor: Colors.amber[700],
          textStyle: myTextStyleMediumBlack(context),
          message: 'Error: $e',
          context: context);
    }
    setState(() {
      busy = false;
    });
    // _showMultiRouteDialog();

  }

  var routesPicked = <lib.Route>[];

  void _showMultiRouteDialog() async {
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: Text(
            'Select Routes', style: myTextStyleMediumLargeWithColor(context,
            Theme
                .of(context)
                .primaryColorLight, 24)),
        content: MultiRouteChooser(onRoutesPicked: (routesPicked) {
          setState(() {
            this.routesPicked = routesPicked;
          });
          Navigator.of(context).pop();
          _buildHashMap();
        }),
      );
    });
  }

  // void _showRouteDialog() async {
  //   final type = getThisDeviceType();
  //   showDialog(
  //       context: context,
  //       builder: (ctx) {
  //         return AlertDialog(
  //           content: SizedBox(width: 300, height: type == 'phone'? 300: 500,
  //             child: Card(
  //               shape: getDefaultRoundedBorder(),
  //               elevation: 8,
  //               child: Padding(
  //                 padding: const EdgeInsets.all(16.0),
  //                 child: ListView.builder(
  //                     itemCount: routes.length,
  //                     itemBuilder: (ctx, index) {
  //                       final route = routes.elementAt(index);
  //                       return GestureDetector(
  //                         onTap: () {
  //                           setState(() {
  //                             routeSelected = route;
  //                           });
  //                           Navigator.of(context).pop();
  //                           _getRouteMap(route);
  //                         },
  //                         child: Card(
  //                           shape: getRoundedBorder(radius: 12),
  //                           elevation: 12,
  //                           child: Padding(
  //                             padding: const EdgeInsets.all(8.0),
  //                             child: Text(
  //                               '${route.name}',
  //                               style: myTextStyleSmall(context),
  //                             ),
  //                           ),
  //                         ),
  //                       );
  //                     }),
  //               ),
  //             ),
  //           ),
  //         );
  //       });
  // }

  // void _getRouteMap(lib.Route route) async {
  //   color = getColor(route.color!);
  //   await _getRoutePoints(route, false);
  //   await _getRouteLandmarks(route, false);
  //   await _buildMap();
  //   _zoomToBeginningOfRoute(route);
  // }

  @override
  void dispose() {
    super.dispose();
  }

  Color newColor = Colors.black;
  String? stringColor;

  Future _getRouteLandmarks(lib.Route route, bool refresh) async {
    routeLandmarks =
    await listApiDog.getRouteLandmarks(route.routeId!, refresh);
    pp('$mm _getRouteLandmarks ...  route: ${route
        .name}; found: ${routeLandmarks.length} ');

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
      _user = await prefs.getUser();
      pp('$mm getting existing RoutePoints .......');
      existingRoutePoints =
      await routesIsolate.getRoutePoints(routeSelected!.routeId!, refresh);
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  // Future<void> _buildMap() async {
  //   pp('$mm .......... existingRoutePoints ....  🍎 found: '
  //       '${existingRoutePoints.length} points');
  //   if (existingRoutePoints.isEmpty) {
  //     setState(() {
  //       busy = false;
  //     });
  //     _showNoPointsDialog();
  //     //return;
  //   }
  //   _addPolyLine();
  //   landmarkIndex = 0;
  //   for (var rl in routeLandmarks) {
  //     _markers.add(Marker(
  //         markerId: MarkerId(rl.landmarkId!),
  //         icon: numberMarkers.elementAt(landmarkIndex),
  //         position:
  //             LatLng(rl.position!.coordinates[1], rl.position!.coordinates[0]),
  //         infoWindow: InfoWindow(
  //             title: rl.landmarkName, snippet: '🍎Part of ${rl.routeName}')));
  //     landmarkIndex++;
  //   }
  //   setState(() {});
  //   var point = existingRoutePoints.first;
  //   var latLng = LatLng(
  //       point.position!.coordinates.last, point.position!.coordinates.first);
  //   _myCurrentCameraPosition = CameraPosition(
  //     target: latLng,
  //     zoom: defaultZoom,
  //   );
  //   final GoogleMapController controller = await _mapController.future;
  //   controller.animateCamera(
  //       CameraUpdate.newCameraPosition(_myCurrentCameraPosition!));
  // }

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

    pp('$mm .......... get current location ....  🍎 found: ${_currentPosition!
        .toJson()}');
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

  void _addLandmarks(List<lib.RouteLandmark> routeLandmarks,
      List<BitmapDescriptor> icons) {
    pp('$mm .......... _addLandmarks ....... .');

    int landmarkIndex = 0;
    for (var routeLandmark in routeLandmarks) {
      _markers.add(Marker(
          markerId: MarkerId(routeLandmark.landmarkId!),
          icon: icons.elementAt(landmarkIndex),
          position:
          LatLng(routeLandmark.position!.coordinates[1],
              routeLandmark.position!.coordinates[0]),
          infoWindow: InfoWindow(
              title: routeLandmark.landmarkName,
              snippet: '🍎Part of ${routeLandmark.routeName}')));
      landmarkIndex++;
    }
  }

  Random random = Random(DateTime
      .now()
      .millisecondsSinceEpoch);
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
      final points = await routesIsolate.getRoutePoints(route.routeId!, false);
      final marks = await listApiDog.getRouteLandmarks(route.routeId!, false);
      final icons = <BitmapDescriptor>[];
      for (var i = 0; i < marks.length; i++) {
        final icon = await getBitmapDescriptor(
            path: "assets/numbers/number_${i + 1}.png",
            width: 84, color: route.color!);
        icons.add(icon);
      }
      final bag = MapBag(route, points, marks, icons);
      hashMap[route.routeId!] = bag;
    }
    pp('$mm ... _buildHashMap: hashMap built: ${hashMap.length}');

    _markers.clear();
    _polyLines.clear();

    for (var bag in hashMap.values.toList()) {
      _addPolyLine(bag.routePoints, getColor(bag.route.color!));
      _addLandmarks(bag.routeLandmarks, bag.landmarkIcons);
    }
    if (hashMap.isNotEmpty) {
      _zoomToBeginningOfRoute(hashMap.values
          .toList()
          .first
          .route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: ElevatedButton(
              style: const ButtonStyle(
                elevation: MaterialStatePropertyAll(8.0),
              ),
              onPressed: () {
                _showMultiRouteDialog();
              },
              child: Text('${routes.length} Routes')),
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
          // Positioned(
          //     right: 12,
          //     top: 40,
          //     child: Card(
          //       elevation: 8,
          //       shape: getRoundedBorder(radius: 12),
          //       child: Row(
          //         children: [
          //           IconButton(
          //               onPressed: () {
          //                 if (routeSelected != null) {
          //                   _refreshRoute(routeSelected!);
          //                 }
          //               },
          //               icon: Icon(
          //                 Icons.toggle_on,
          //                 color: Theme.of(context).primaryColor,
          //               )),
          //           const SizedBox(
          //             width: 28,
          //           ),
          //         ],
          //       ),
          //     )),
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
      items.add(DropdownMenuItem<lib.Route>(
          value: r,
          child: Text(
            r.name!,
            style: myTextStyleSmall(context),
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
