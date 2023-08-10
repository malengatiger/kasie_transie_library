import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poly;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/isolates/landmark_isolate.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';

import '../isolates/routes_isolate.dart';
import '../widgets/tiny_bloc.dart';

class LandmarkCreatorMap extends StatefulWidget {
  final lib.Route route;

  const LandmarkCreatorMap({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  LandmarkCreatorMapState createState() => LandmarkCreatorMapState();
}

class LandmarkCreatorMapState extends State<LandmarkCreatorMap> {
  static const defaultZoom = 16.0;
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition? _myCurrentCameraPosition;
  static const mm = '🍐🍐🍐🍐🍐🍐🍐🍐 LandmarkCreatorMap: 💪 ';
  late StreamSubscription<List<lib.RouteLandmark>> completionSub;
  final _key = GlobalKey<ScaffoldState>();
  bool busy = false;
  bool isHybrid = false;
  lib.User? _user;
  geo.Position? _currentPosition;
  final Set<Marker> _markers = HashSet();
  final Set<Circle> _circles = HashSet();
  final Set<Polyline> _polyLines = {};
  BitmapDescriptor? _dotMarker;
  late GoogleMapController googleMapController;
  final numberMarkers = <BitmapDescriptor>[];

  // List<BitmapDescriptor> _numberMarkers = [];
  final List<lib.RoutePoint> rpList = [];

  // List<lib.Landmark> _landmarks = [];
  List<lib.RoutePoint> existingRoutePoints = [];
  List<lib.Landmark> landmarksFromLocationSearch = [];

  List<poly.PointLatLng>? polylinePoints;
  int totalLandmarks = 0;

  int index = 0;
  bool sending = false;
  Timer? timer;
  int totalPoints = 0;
  lib.SettingsModel? settingsModel;
  int radius = 5;
  bool displayLandmark = false;
  late StreamSubscription<lib.RouteLandmark> _sub;
  var routeLandmarks = <lib.RouteLandmark>[];
  var landmarkIndex = 0;

  @override
  void initState() {
    super.initState();
    _listen();
    _setup();
  }

  void _setup() async {
    await _getSettings();
    await _getCurrentLocation();
    _getUser();
  }

  Future _getSettings() async {
    settingsModel = await prefs.getSettings();
    if (settingsModel != null) {
      radius = settingsModel!.vehicleGeoQueryRadius!;
      if (radius > 5) {
        radius = 5;
      }
    }
  }

  Future _buildLandmarkIcons(int total, int width) async {
    numberMarkers.clear();
    total++;
    for (var i = 0; i < total; i++) {
      var intList =
          await getBytesFromAsset("assets/numbers/number_${i + 1}.png", width);
      numberMarkers.add(BitmapDescriptor.fromBytes(intList));
    }
    pp('$mm have built ${numberMarkers.length} markers for landmarks');
  }

  void _listen() async {
    completionSub =
        landmarkIsolate.completionStream.listen((resultRouteLandmarks) {
      pp('\n\n$mm landmarkIsolate.completionStream delivered ...  '
          '${E.appleRed} routeLandmarks: ${routeLandmarks.length}  ');
      routeLandmarks = resultRouteLandmarks;
      pendingCount = 0;
      if (mounted) {
        _putLandmarksOnMap();
      }
    });
  }

  void _controlReads() async {
    setState(() {
      busy = true;
    });
    try {
      await _getRouteLandmarks();
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  Future _getRouteLandmarks() async {
    routeLandmarks =
        await listApiDog.getRouteLandmarks(widget.route.routeId!, true);
    pp('\n\n$mm RouteLandmarks ...  ${E.appleRed} '
        'route: ${widget.route.name}; found: ${routeLandmarks.length} ');
    await _putLandmarksOnMap();
    //
    await _getRoutePoints(false);
  }

  Future _putLandmarksOnMap() async {
    pp('$mm ..._putLandmarksOnMap: routeLandmarks: ${routeLandmarks.length}');

    landmarkIndex = 0;
    if (routeLandmarks.isEmpty) {
      return;
    }
    // await _buildLandmarkIcons(routeLandmarks.length, 84);

    for (var routeLandmark in routeLandmarks) {
      final ic2 = await getMarkerBitmap(72, color: widget.route.color!,
          text: '${landmarkIndex + 1}',
           fontSize: 32, fontWeight: FontWeight.w900);


      final latLng = LatLng(routeLandmark.position!.coordinates.last,
          routeLandmark.position!.coordinates.first);
      // final icon = await getMarkerBitmap(72,
      //     text: '${landmarkIndex + 1}',
      //     color: widget.route.color!,
      //     borderColor: Colors.black,
      //     fontSize: 28,
      //     fontWeight: FontWeight.w900);

      _markers.add(Marker(
          markerId: MarkerId('${routeLandmark.landmarkId}'),
          icon: ic2,
          onTap: () {
            pp('$mm .............. routeLandmark marker tapped, index: $index $latLng');
            //_deleteRoutePoint(routePoint);
          },
          infoWindow: InfoWindow(
              snippet: 'This routeLandmark is part of the route.',
              title: '🔵 ${routeLandmark.landmarkName}',
              onTap: () {
                pp('$mm ............. infoWindow tapped, point index: $index');
                //_deleteLandmark(routeLandmark);
              }),
          position: latLng));
      landmarkIndex++;
      pp('$mm ... routeLandmark added to markers: ${_markers.length}');
    }
    pp('$mm ... setting state .... and animating camera ...');
    setState(() {});
    var last = routeLandmarks.last;
    final latLng = LatLng(
        last.position!.coordinates.last, last.position!.coordinates.first);
    totalLandmarks = routeLandmarks.length;
    _animateCamera(latLng, 16);
  }

  Future _getRoutePoints(bool refresh) async {
    try {
      _user = await prefs.getUser();
      pp('$mm ...... getting existing RoutePoints .......');
      existingRoutePoints =
          await routesIsolate.getRoutePoints(widget.route.routeId!, refresh);

      pp('$mm .......... existingRoutePoints ....  🍎 found: '
          '${existingRoutePoints.length} points');
      //_buildExistingRoutePointMarkers();
      _addPolyLine();
    } catch (e) {
      pp(e);
    }
  }

  void _addPolyLine() {
    pp('$mm .......... _addPolyLine ....... .');
    if (existingRoutePoints.isEmpty) {
      pp('$mm route points empty. WTF?');
      return;
    }
    _polyLines.clear();
    var mPoints = <LatLng>[];
    existingRoutePoints.sort((a, b) => a.index!.compareTo(b.index!));
    for (var rp in existingRoutePoints) {
      mPoints.add(LatLng(
          rp.position!.coordinates.last, rp.position!.coordinates.first));
    }
    final color = getColor(widget.route.color!);
    var polyLine = Polyline(
      color: color,
      width: 8,
      points: mPoints,
      polylineId: PolylineId(DateTime.now().toIso8601String()),
      consumeTapEvents: true,
      onTap: () {
        pp('$mm polyline tapped .... find underlying routePoint');
      },
    );

    _polyLines.add(polyLine);
    //
    var last = existingRoutePoints.last;
    final latLng = LatLng(
        last.position!.coordinates.last, last.position!.coordinates.first);
    totalPoints = existingRoutePoints.length;
    // routePointIndex = existingRoutePoints.length;

    _animateCamera(latLng, 16);
    setState(() {});
  }

  Future<void> _buildExistingRoutePointMarkers() async {
    pp('$mm .......... _buildExistingRoutePointMarkers starting ... ');

    if (existingRoutePoints.isEmpty) {
      pp('$mm route points empty. WTF?');
      return;
    }

    // final ic = await getTaxiMapIcon(
    //     iconSize: 160,
    //     text: '${landmarkIndex + 1}',
    //     style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
    //     path: 'assets/landmark.png');

    final ic2 = await getMarkerBitmap(84,
        color: widget.route.color!,  fontSize: 32, fontWeight: FontWeight.w900);

    totalPoints = existingRoutePoints.length;
    // _clearMap();
    for (var routePoint in existingRoutePoints) {
      var latLng = LatLng(routePoint.position!.coordinates.last,
          routePoint.position!.coordinates.first);
      _markers.add(Marker(
          markerId: MarkerId('${routePoint.routePointId}'),
          icon: ic2,
          onTap: () {
            pp('$mm .............. ${E.pear}${E.pear}${E.pear} '
                'marker tapped: routePoint: ${routePoint.toJson()}');
            setState(() {
              routePointForLandmark = routePoint;
              _showLandmark = true;
            });
          },
          position: LatLng(latLng.latitude, latLng.longitude)));
    }
    setState(() {});
    //
    var last = existingRoutePoints.last;
    final latLng = LatLng(
        last.position!.coordinates.last, last.position!.coordinates.first);
    totalPoints = existingRoutePoints.length;
    index = existingRoutePoints.length - 1;
    await _animateCamera(latLng, 16);
  }

  Future<void> _animateCamera(LatLng latLng, double zoom) async {
    var cameraPos = CameraPosition(target: latLng, zoom: zoom);
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPos));
  }

  bool _showLandmark = false;

  void _clearMap() {
    _polyLines.clear();
    _markers.clear();
    setState(() {});
  }

  @override
  void dispose() {
    completionSub.cancel();
    super.dispose();
  }

  Future _getUser() async {
    _user = await prefs.getUser();
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
    if (widget.route.routeStartEnd != null) {
      final latLng = LatLng(
          widget.route.routeStartEnd!.startCityPosition!.coordinates.last,
          widget.route.routeStartEnd!.startCityPosition!.coordinates.first);
      await _animateCamera(latLng, 20);
      setState(() {});
    }
  }

  bool checkDistance(LatLng latLng) {
    double? mLat, mLng;
    if (index > 1) {
      mLat = rpList.elementAt(index - 2).position!.coordinates.last;
      mLng = rpList.elementAt(index - 2).position!.coordinates.first;
      var dist = locationBloc.getDistance(
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          toLatitude: mLat,
          toLongitude: mLng);
      if (dist > 20) {
        pp('$mm ... this is probably a rogue routePoint: ${E.redDot} '
            'distance from previous point: $dist metres');
        return false;
      } else {
        pp('$mm distance from previous point: ${E.appleGreen} $dist metres');
      }
    }
    return true;
  }

  TextEditingController nameEditController = TextEditingController();

  int pendingCount = 0;

  void _addNewLandmark() async {
    if (routePointForLandmark == null) {
      pp('....... routePointForLandmark == null, ignore!');
      return;
    }
    pendingCount++;

    landmarkIndex = (routeLandmarks.length - 1) + pendingCount;

    final ic2 = await getMarkerBitmap(72, color: widget.route.color!,
        text: '${landmarkIndex + 1}',
       fontSize: 32, fontWeight: FontWeight.w900);

    pp('....... _addNewLandmark: landmarkIndex: $landmarkIndex');

    _markers.add(Marker(
        markerId: MarkerId('${routePointForLandmark!.routePointId}'),
        icon: ic2,
        onTap: () {
          pp('$mm .............. marker tapped: $index');
          //_deleteRoutePoint(routePoint);
        },
        infoWindow: InfoWindow(
            snippet: 'This landmark is part of the route.',
            title: '🔵 $landmarkName',
            onTap: () {
              pp('$mm ............. infoWindow tapped, point index: $index');
              //_deleteLandmark(landmark);
            }),
        position: LatLng(routePointForLandmark!.position!.coordinates.last,
            routePointForLandmark!.position!.coordinates.first)));

    setState(() {});

    var latLng = LatLng(routePointForLandmark!.position!.coordinates.last,
        routePointForLandmark!.position!.coordinates.first);
    _animateCamera(latLng, 16);
    //
    if (mounted) {
      showSnackBar(
          duration: const Duration(seconds: 5),
          padding: 16,
          message: 'New Route landmark is being processed '
              'and will show up in a few seconds',
          context: context);
    }
    _processNewLandmark();
  }

  String? landmarkName;

  Future<void> _processNewLandmark() async {
    final parameters = LandmarkParameters(
        latitude: routePointForLandmark!.position!.coordinates.last,
        longitude: routePointForLandmark!.position!.coordinates.first,
        routeId: widget.route.routeId!,
        radius: radius.toDouble(),
        landmarkName: landmarkName!,
        limit: 10,
        index: landmarkIndex,
        routePointId: routePointForLandmark!.routePointId!,
        routePointIndex: routePointForLandmark!.index!,
        associationId: widget.route.associationId!,
        routeName: widget.route.name!,
        authToken: '');
    landmarkIsolate.addRouteLandmark(parameters);
    pp('$mm landmark isolate started! ... 😎😎😎 Good Fucking Luck!!');
  }

  void _deleteLandmark(lib.Landmark point) async {
    setState(() {
      busy = true;
    });
    try {
      var id = point.landmarkId!;
      var res = _markers.remove(Marker(markerId: MarkerId(id)));
      totalPoints--;
      pp('$mm ... removed marker from map: $res, ${E.nice} = true, if not, we fucked!');
      myPrettyJsonPrint(point.toJson());
      try {
        pp('$mm ... start delete ...');
        final result = await dataApiDog.deleteLandmark(id);
        pp('$mm ... removed landmark from database: $result; ${E.nice} 0 is good, Boss!');
        await _getRoutePoints(true);
      } catch (e) {}
    } catch (e) {
      pp('$mm $e');
    }
    setState(() {
      busy = false;
    });
  }

  lib.RoutePoint? routePointForLandmark;

  void findRoutePoint(LatLng latLng) {
    routePointForLandmark = tinyBloc.findRoutePoint(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        points: existingRoutePoints);
    if (routePointForLandmark != null) {
      setState(() {
        _showLandmark = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        body: _myCurrentCameraPosition == null
            ? Center(
                child: SizedBox(
                  height: 100,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                          backgroundColor: Colors.pink,
                        ),
                      ),
                      const SizedBox(
                        height: 48,
                      ),
                      Text(
                        'Waiting for GPS location ...',
                        style: myTextStyleMediumBold(context),
                      ),
                    ],
                  ),
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
                  onLongPress: (latLng) {
                    pp('$mm ....... on map long pressed: $latLng ');
                    findRoutePoint(latLng);
                  },
                  onMapCreated: (GoogleMapController controller) async {
                    _mapController.complete(controller);
                    googleMapController = controller;
                    _zoomToStartCity();
                    _controlReads();
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
                        child: Card(
                          color: Colors.black38,
                          shape: getDefaultRoundedBorder(),
                          elevation: 24,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SizedBox(
                              height: 108,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Route Landmarks',
                                          style: myTextStyleMediumLarge(
                                              context, 20),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.arrow_back_ios,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          '${widget.route.name}',
                                          style: myTextStyleMediumWithColor(
                                            context,
                                            Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${widget.route.associationName}',
                                      style: myTextStyleTiny(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ))),
                Positioned(
                    left: 16,
                    bottom: 40,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 120,
                        child: Column(
                          children: [
                            Text(
                              '$totalLandmarks',
                              style: myNumberStyleLargerWithColor(
                                  Colors.black26, 32, context),
                            ),
                            Text(
                              '$totalPoints',
                              style: myNumberStyleLargerWithColor(
                                  Colors.black26, 24, context),
                            ),
                          ],
                        ),
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
                              onPressed: () async {
                                _controlReads();
                              },
                              icon: Icon(
                                Icons.toggle_on,
                                color: Theme.of(context).primaryColor,
                              ))
                        ],
                      ),
                    )),
                _showLandmark
                    ? Positioned(
                        bottom: 80,
                        left: 20,
                        right: 20,
                        child: SizedBox(
                          height: 320,
                          width: 400,
                          child: Card(
                            shape: getDefaultRoundedBorder(),
                            elevation: 12,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _showLandmark = false;
                                            });
                                          },
                                          icon: const Icon(Icons.close,
                                              color: Colors.white))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'New Landmark',
                                    style: myTextStyleMediumLarge(context, 20),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextField(
                                    controller: nameEditController,
                                    decoration: InputDecoration(
                                      label:
                                          const Text('Landmark/Taxi Stop Name'),
                                      labelStyle: myTextStyleSmall(context),
                                      hintText: 'Enter the name of the place',
                                      icon: const Icon(
                                          Icons.water_damage_outlined),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 48,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        if (nameEditController
                                            .value.text.isEmpty) {
                                          showSnackBar(
                                              message: 'Please enter the name',
                                              context: context,
                                              padding: 16);
                                        } else {
                                          setState(() {
                                            _showLandmark = false;
                                          });
                                          landmarkName =
                                              nameEditController.value.text;
                                          _addNewLandmark();
                                        }
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.only(
                                            left: 28.0,
                                            right: 28,
                                            top: 16,
                                            bottom: 16),
                                        child: Text('Save Landmark'),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ))
                    : const SizedBox(),
                busy
                    ? const Positioned(
                        left: 300,
                        top: 300,
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 12,
                            backgroundColor: Colors.purple,
                          ),
                        ))
                    : const SizedBox(),
              ]));
  }
}
