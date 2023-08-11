import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/route_point_list.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/local_finder.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:realm/realm.dart';

import '../isolates/routes_isolate.dart';
import '../l10n/translation_handler.dart';
import '../widgets/color_pad.dart';
import '../widgets/tiny_bloc.dart';

///Using a map, place each route point after another till the route is mapped
class RouteCreatorMap2 extends StatefulWidget {
  final lib.Route route;

  const RouteCreatorMap2({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  RouteCreatorMap2State createState() => RouteCreatorMap2State();
}

class RouteCreatorMap2State extends State<RouteCreatorMap2> {
  static const defaultZoom = 16.0;
  final Completer<GoogleMapController> _mapController = Completer();

  final CameraPosition _myCurrentCameraPosition =
      const CameraPosition(target: LatLng(-26.5, 27.6), zoom: 14.6);
  static const mm = '💟💟💟💟💟💟💟💟💟💟 RouteCreatorMap2: 💪 ';
  final _key = GlobalKey<ScaffoldState>();
  late GoogleMapController googleMapController;
  bool busy = false;
  bool isHybrid = false;
  final Set<Marker> _markers = HashSet();
  final Set<Circle> _circles = HashSet();
  final Set<Polyline> _polyLines = {};

  // List<BitmapDescriptor> _numberMarkers = [];
  final List<lib.RoutePoint> rpList = [];

  // List<lib.Landmark> _landmarks = [];
  List<lib.RoutePoint> existingRoutePoints = [];
  List<LatLng>? polylinePoints;
  final numberMarkers = <BitmapDescriptor>[];

  int routePointIndex = 0;
  bool sending = false;
  Timer? timer;
  int totalPoints = 0;
  var routeLandmarks = <lib.RouteLandmark>[];
  var landmarkIndex = 0;
  var routeMapping = 'routeMapping';

  @override
  void initState() {
    super.initState();
  }

  Future _setTexts() async {
    final c = await prefs.getColorAndLocale();
    deleteRoutePoints =
        await translator.translate('deleteRoutePoints', c.locale);
    no = await translator.translate('no', c.locale);
    yes = await translator.translate('yes', c.locale);
    changeColor = await translator.translate('changeColor', c.locale);
    routeMapping = await translator.translate('routeMapping', c.locale);
    routePointRemoval = await translator.translate('routePointRemoval', c.locale);
    setState(() {});
  }

  void _controlReads(bool refresh) async {
    setState(() {
      busy = true;
    });
    try {
      await _setTexts();
      await getRoutePoints(refresh);
      await getRouteLandmarks(refresh);
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  Future getRouteLandmarks(bool refresh) async {
    routeLandmarks =
        await listApiDog.getRouteLandmarks(widget.route.routeId!, refresh);
    pp('\n\n$mm _getRouteLandmarks ...  ${E.appleRed} route: ${widget.route.name}; found: ${routeLandmarks.length} ');
    routeLandmarks.sort((a, b) => a.created!.compareTo(b.created!));
    landmarkIndex = 0;
    for (var landmark in routeLandmarks) {
      final latLng = LatLng(landmark.position!.coordinates.last,
          landmark.position!.coordinates.first);
      final icon = await getMarkerBitmap(72,
          text: '${landmarkIndex+1}',
          color: widget.route.color!, borderColor: Colors.black, fontSize: 28, fontWeight: FontWeight.w900);
      _markers.add(Marker(
          markerId: MarkerId('${landmark.landmarkId}'),
          icon: icon,
          onTap: () {
            pp('$mm .............. marker tapped: $routePointIndex');
            //_deleteRoutePoint(routePoint);
          },
          infoWindow: InfoWindow(
              snippet:
                  '\nThis landmark is part of the route: \n${widget.route.name}\n\n',
              title: '🔵 ${landmark.landmarkName}',
              onTap: () {
                pp('$mm ............. infoWindow tapped, point index: $routePointIndex');
                //_deleteLandmark(landmark);
              }),
          position: latLng));
      landmarkIndex++;
      pp('$mm ... routeLandmark added to markers: ${_markers.length}');
    }
    setState(() {});

    var last = routeLandmarks.last;
    final latLng = LatLng(
        last.position!.coordinates.last, last.position!.coordinates.first);

    _animateCamera(latLng, 15.0);
  }

  Future<void> _animateCamera(LatLng latLng, double zoom) async {
    var cameraPos = CameraPosition(target: latLng, zoom: zoom);
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
  }

  Future getRoutePoints(bool refresh) async {
    pp('$mm getRoutePoints ... refresh $refresh');
    setState(() {
      busy = true;
    });
    try {
      color = getColor(widget.route.color!);
      pp('$mm getting existing RoutePoints ....... refresh: $refresh');
      setState(() {
        busy = true;
      });
      existingRoutePoints =
          await routesIsolate.getRoutePoints(widget.route.routeId!, refresh);
      pp('$mm .......... existingRoutePoints ....  🍎 found: '
          '${existingRoutePoints.length} points');
      routePointIndex = existingRoutePoints.length;
      _addPolyLine();
    } catch (e) {
      pp(e);
    }
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
    var polyLine = Polyline(
        color: color,
        width: 10,
        points: mPoints,
        polylineId: PolylineId(DateTime.now().toIso8601String()));

    _polyLines.add(polyLine);
    //
    var last = existingRoutePoints.last;
    final latLng = LatLng(
        last.position!.coordinates.last, last.position!.coordinates.first);
    totalPoints = existingRoutePoints.length;
    routePointIndex = existingRoutePoints.length;

    _animateCamera(latLng, 16);
    setState(() {});
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
      timer == null;
    }
    if (rpList.isNotEmpty) {
      _sendRoutePointsToBackend();
    }
    super.dispose();
  }


  Future<void> _zoomToStartCity() async {
    if (widget.route.routeStartEnd != null) {
      final latLng = LatLng(
          widget.route.routeStartEnd!.startCityPosition!.coordinates.last,
          widget.route.routeStartEnd!.startCityPosition!.coordinates.first);
      var cameraPos = CameraPosition(target: latLng, zoom: 13.0);
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
      setState(() {});
    }
  }

  bool checkDistance(LatLng latLng) {
    double? mLat, mLng;
    lib.RoutePoint? prev;
    try {
      prev = rpList.last;
      mLat = prev.position!.coordinates.last;
      mLng = prev.position!.coordinates.first;
    } catch (e) {
      return true;
    }

    try {
      var dist = locationBloc.getDistance(
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          toLatitude: mLat,
          toLongitude: mLng);

      if (dist > 50) {
        pp('\n\n\n$mm ... this is probably a rogue routePoint: ${E.redDot} '
            '${E.redDot}${E.redDot} distance from previous point:  ${E.redDot} $dist metres');
        return false;
      } else {
        pp('$mm distance from previous point: ${E.appleGreen} $dist metres');
      }
    } catch (e) {
      pp('$mm checkDistance failed: ${E.redDot} ');
    }
    return true;
  }

  void _removeRoutePoints(LatLng latLng) async {
    pp('$mm _removeRoutePoints: ...  find nearest route point : $latLng');
    try {
      final k = await localFinder.findNearestRoutePoint(
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          radiusInMetres: 50);
      if (k != null) {
        existingRoutePoints =
            await dataApiDog.deleteRoutePointsFromIndex(k.routeId!, k.index!);
        routePointIndex = existingRoutePoints.length;
        pp('$mm ...  existingRoutePoints remaining : ${existingRoutePoints.length}');
        _addPolyLine();
        return;
      }
    } catch (e) {
      pp(e);
    }
    pp('$mm _removeRoutePoints: ... ${E.redDot} '
        'find nearest route point did not find anything ... quitting!');
  }

  String deleteRoutePoints = 'Do you want to delete all '
      'the route points starting from here';
  String yes = 'yes', no = 'no';
  String routePointRemoval = 'Route Point Removal';

  void _confirmDelete(LatLng latLng) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text(routePointRemoval),
            content: SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      deleteRoutePoints,
                      style: myTextStyleMediumLargeWithColor(
                          context, Theme.of(context).primaryColorLight, 16),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(no)),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _removeRoutePoints(latLng);
                    },
                    child: Text(
                      yes,
                      style: myTextStyleMediumLargeWithColor(
                          context, Theme.of(context).primaryColorLight, 24),
                    )),
              ),
            ],
          );
        });
  }

  void _addNewRoutePoint(LatLng latLng) async {
    if (!checkDistance(latLng)) {
      return;
    }
    var id = Uuid.v4().toString();
    if (timer == null) {
      startTimer();
    }
    totalPoints++;
    pp('$mm RoutePoint added to map; index: $routePointIndex '
        '🔵 🔵 🔵 total points: $totalPoints');

    routePointIndex++;
    var routePoint = lib.RoutePoint(ObjectId(),
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        routeId: widget.route.routeId,
        routeName: widget.route.name,
        index: routePointIndex,
        position: lib.Position(
          coordinates: [latLng.longitude, latLng.latitude],
          latitude: latLng.latitude,
          longitude: latLng.longitude,
        ),
        routePointId: id,
        created: DateTime.now().toUtc().toIso8601String());

    existingRoutePoints.add(routePoint);
    rpList.add(routePoint);

    _addPolyLine();

    _animateCamera(latLng, defaultZoom + 6);
    setState(() {});
  }

  void startTimer() {
    pp('$mm ... startTimer ... ');
    timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      pp('$mm timer ticked: 💛️💛️ ${timer.tick}');
      _sendRoutePointsToBackend();
    });
  }

  void _sendRoutePointsToBackend() async {
    pp('\n\n$mm ... sending route points to backend ... ${rpList.length} ');
    if (rpList.isEmpty) {
      pp('$mm no routePoints to send .... 🔵🔵 will ignore for now ...');
      return;
    }
    if (sending) {
      pp('$mm busy sending .... will ignore for now ...');
    }
    final sList = <lib.RoutePoint>[];
    for (var m in rpList) {
      sList.add(m);
    }
    rpList.clear();
    sending = true;
    var ml = RoutePointList(sList);
    final count = await dataApiDog.addRoutePoints(ml);
    sending = false;
    pp('$mm ... _sendRoutePointsToBackend: ❤️❤️route points saved to Kasie backend: ❤️ $count ❤️ DONE!\n\n');
  }

  Color newColor = Colors.black;
  String changeColor = 'Change Colour', stringColor = 'black';

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
                      color = mColor;
                      stringColor = string;
                    });
                    Navigator.pop(context);
                    changeRouteColorOnBackend();
                  },
                ),
              ],
            ),
          );
        });
  }
  Color color = Colors.black;

  void changeRouteColorOnBackend() async {
    pp('$mm ... changeRouteColorOnBackend ...color: $stringColor');
    _addPolyLine();
    setState(() {
      busy = true;
    });
    try {
      final m = await dataApiDog.updateRouteColor(
          routeId: widget.route.routeId!, color: stringColor!);
      pp('$mm ... color has been updated ... result: $m ; 0 is good!');
      tinyBloc.setRouteId(widget.route.routeId!);

    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
    //
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        body: Stack(children: [
          GoogleMap(
            mapType: isHybrid ? MapType.hybrid : MapType.normal,
            myLocationEnabled: true,
            markers: _markers,
            circles: _circles,
            polylines: _polyLines,
            initialCameraPosition: _myCurrentCameraPosition!,
            onTap: _addNewRoutePoint,
            onLongPress: _confirmDelete,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
              googleMapController = controller;
              _zoomToStartCity();
              _controlReads(true);
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
                    child: SizedBox(
                      height: 108,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 4,
                            ),
                            Text(routeMapping,
                              style: myTextStyleMediumLarge(context, 20),
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
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${widget.route.name}',
                                    style: myTextStyleMediumWithColor(
                                        context, Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              '${widget.route.associationName}',
                              style: myTextStyleTiny(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))),
          Positioned(
              left: 16,
              bottom: 80,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text('Points'),
                    const SizedBox(
                      width: 16,
                    ),
                    Text(
                      '$totalPoints',
                      style: myNumberStyleLargerWithColor(
                          Colors.black26, 44, context),
                    ),
                  ],
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
                          _controlReads(true);
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
                  child: Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        backgroundColor: Colors.purple,
                      ),
                    ),
                  ))
              : const SizedBox(),
        ]));
  }
}
