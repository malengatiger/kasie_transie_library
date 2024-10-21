import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/data/route_point_list.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';

import '../bloc/data_api_dog.dart';
import '../bloc/list_api_dog.dart';
import '../bloc/sem_cache.dart';
import '../l10n/translation_handler.dart';
import '../utils/prefs.dart';
import '../utils/route_update_listener.dart';
import 'mapping_toolbar.dart';

///Using a map, place each route point after another till the route is mapped
class RouteCreatorMap2 extends StatefulWidget {
  final lib.Route route;

  const RouteCreatorMap2({
    super.key,
    required this.route,
  });

  @override
  RouteCreatorMap2State createState() => RouteCreatorMap2State();
}

class RouteCreatorMap2State extends State<RouteCreatorMap2> {
  static const defaultZoom = 12.0;
  final Completer<GoogleMapController> _mapController = Completer();
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  SemCache semCache = GetIt.instance<SemCache>();
  RouteUpdateListener routeUpdateListener =
  GetIt.instance<RouteUpdateListener>();
  String deleteRoutePoints = 'Do you want to delete all '
      'the route points starting from here';
  String yes = 'yes', no = 'no';
  String routePointRemoval = 'Route Point Removal';

  final CameraPosition _myCurrentCameraPosition =
      const CameraPosition(target: LatLng(-26.5, 27.6), zoom: 14.6);
  static const mm = '💟💟💟 RouteCreatorMap2: 💪💪';
  final _key = GlobalKey<ScaffoldState>();
  late GoogleMapController googleMapController;
  bool busy = false;
  bool isHybrid = false;
  final Set<Marker> _markers = HashSet();
  final Set<Circle> _circles = HashSet();
  final Set<Polyline> _polyLines = {};

  // static const ZOOM = 10.0;
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
    color = getColor(widget.route.color!);
  }

  Future _setTexts() async {
    final c = prefs.getColorAndLocale();
    deleteRoutePoints =
        await translator.translate('deleteRoutePoints', c.locale);
    no = await translator.translate('no', c.locale);
    yes = await translator.translate('yes', c.locale);
    routeMapping = await translator.translate('routeMapping', c.locale);
    routePointRemoval =
        await translator.translate('routePointRemoval', c.locale);
    setState(() {});
  }

  void _getPointsAndLandmarks(bool refresh) async {
    setState(() {
      busy = true;
    });
    timer?.cancel();
    try {
      await _setTexts();
      await getRoutePoints(refresh);
      await getRouteLandmarks(refresh);
      startTimer();
      if (routeLandmarks.isNotEmpty) {
        var last = routeLandmarks.last;
        final latLng = LatLng(
            last.position!.coordinates.last, last.position!.coordinates.first);
        _animateCamera(latLng, zoom: 14);
      }
    } catch (e,s) {
      pp('$mm $e \n$s');
      if (mounted) {
        showErrorToast(message: '_getPointsAndLandmarks: $e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  Future getRouteLandmarks(bool refresh) async {
    try {
      routeLandmarks = await listApiDog.getRouteLandmarks(
          widget.route.routeId!, refresh, widget.route.associationId!);
      pp('\n\n$mm _getRouteLandmarks: ...  ${E.appleRed} route: ${widget.route.name}; found: ${routeLandmarks.length} ');
      if (routeLandmarks.isEmpty) {
        pp('$mm ... NO ROUTE LANDMARKS FOUND for ${widget.route.name}, quitting!');
        return;
      }
      try {
        routeLandmarks.sort((a, b) => a.index!.compareTo(b.index!));
      } catch (e, stack) {
        pp('$mm $e - $stack');
      }
      landmarkIndex = 0;
      Color borderColor = Colors.black;
      if (widget.route.color == 'black') {
        borderColor = Colors.white;
      }
      for (var landmark in routeLandmarks) {
        final latLng = LatLng(landmark.position!.coordinates.last,
            landmark.position!.coordinates.first);
        final icon = await getMarkerBitmap(72,
            text: '${landmarkIndex + 1}',
            color: getStringColor(color),
            borderColor: borderColor,
            fontSize: 16,
            fontWeight: FontWeight.w900);
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
        // myPrettyJsonPrint(landmark.toJson());
      }
    } catch (e, stack) {
      pp('$mm getRouteLandmarks $e $stack');
      if (mounted) {
        showSnackBar(message: 'getRouteLandmarks: $e', context: context);
      }
    }
    setState(() {});

  }
  Future<void> _animateCamera(LatLng latLng, {double? zoom}) async {
    var cameraPos = CameraPosition(target: latLng, zoom: zoom ?? defaultZoom);
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
  }
  Future getRoutePoints(bool refresh) async {
    pp('$mm .... getRoutePoints ... refresh $refresh');
    try {
      pp('$mm getting existing RoutePoints ....... refresh: $refresh');
      setState(() {
        busy = true;
      });
      existingRoutePoints = await listApiDog.getRoutePoints(
          widget.route.routeId!, refresh, widget.route.associationId!);
      pp('$mm .......... existingRoutePoints ....  🍎 '
          '${existingRoutePoints.length} points');
      routePointIndex = existingRoutePoints.length;
      if (existingRoutePoints.isNotEmpty) {
        _addPolyLine();
      }
    } catch (e, stack) {
      pp('$mm ERROR: $e - $stack');
    }
    setState(() {
      busy = false;
    });
  }

  void _addPolyLine() {
    if (existingRoutePoints.isEmpty) {
      _polyLines.clear();
      setState(() {

      });
      return;
    }
    try {
      _polyLines.clear();
      var mPoints = <LatLng>[];
      existingRoutePoints.sort((a, b) => a.index!.compareTo(b.index!));
      for (var rp in existingRoutePoints) {
        mPoints.add(LatLng(
            rp.position!.coordinates.last, rp.position!.coordinates.first));
      }
      final id = DateTime.now().toIso8601String();
      var polyLine = Polyline(
          color: color, width: 8, points: mPoints, polylineId: PolylineId(id));

      _polyLines.add(polyLine);
      //
      var last = existingRoutePoints.last;
      final latLng = LatLng(
          last.position!.coordinates.last, last.position!.coordinates.first);
      totalPoints = existingRoutePoints.length;
      routePointIndex = existingRoutePoints.length;

      _animateCamera(latLng, zoom: 14.0);
      setState(() {});
    } catch (e, stack) {
      pp('$mm _addPolyLine: $e - $stack');
      showErrorToast(
           message: 'PolyLine: $e', context: context);
    }
  }
  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
      timer == null;
    }
    if (rpList.isNotEmpty && rpList.length > 2) {
      _sendRoutePointsToBackend();
    }
    routeUpdateListener.update(widget.route);
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

  DeviceLocationBloc locationBloc = GetIt.instance<DeviceLocationBloc>();
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

      if (dist > 100) {
        pp('\n\n\n$mm ... this is probably a rogue routePoint: ${E.redDot} '
            '${E.redDot}${E.redDot} distance from previous point:  ${E.redDot} $dist metres');
        return false;
      }
    } catch (e) {
      pp('$mm checkDistance failed: ${E.redDot} ');
    }
    return true;
  }

  void _addNewRoutePoint(LatLng latLng) async {
    if (!checkDistance(latLng)) {
      return;
    }
    var id = '${DateTime.now().millisecondsSinceEpoch}';
    if (timer == null) {
      startTimer();
    }
    totalPoints++;
    routePointIndex++;

    var routePoint = lib.RoutePoint(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        routeId: widget.route.routeId,
        routeName: widget.route.name,
        index: routePointIndex,
        position: lib.Position(
          type: 'Point',
          coordinates: [latLng.longitude, latLng.latitude],
          latitude: latLng.latitude,
          longitude: latLng.longitude,
        ),
        routePointId: id,
        created: DateTime.now().toUtc().toIso8601String());

    existingRoutePoints.add(routePoint);
    rpList.add(routePoint);

    _addPolyLine();
    _animateCamera(latLng, zoom: defaultZoom + 6);
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
    if (rpList.isEmpty || rpList.length == 1) {
      pp('$mm no routePoints to send .... 🔵🔵 will ignore for now ...');
      return;
    }
    if (sending) {
      pp('$mm busy sending .... 🔵🔵 will ignore for now ...');
      return;
    }
    final sList = <lib.RoutePoint>[];
    for (var m in rpList) {
      sList.add(m);
    }
    rpList.clear();
    sending = true;
    var ml = RoutePointList(sList);
    final count =
        await dataApiDog.addRoutePoints(ml, widget.route.associationId!);

    sending = false;
    pp('$mm ... _sendRoutePointsToBackend: ❤️❤️route points saved to Kasie backend: ❤️ $count ❤️ DONE!\n\n');
  }

  Color color = Colors.black;
  var topHeight = 108.0;
  _setColor(c) async {
    pp('$mm change color to $c');
    color = getColor(c);
    routeUpdateListener.update(widget.route);
    _polyLines.clear();
    _markers.clear();
    _getPointsAndLandmarks(true);
  }

  _onRefresh() async {
    pp('$mm Refresh the map ....');
    _polyLines.clear();
    _markers.clear();
    routeUpdateListener.update(widget.route);
    setState(() {

    });
    _getPointsAndLandmarks(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(
            'Route Point Mapping & Colour Edits',
            style: myTextStyle(weight: FontWeight.w900, fontSize: 20),
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(topHeight),
              child: Column(
                children: [
                  MappingToolbar(
                    routeId: widget.route.routeId!,
                    routePoints: existingRoutePoints,
                    onRefresh: () {
                      _onRefresh();
                    },
                    onColorUpdated: (c) {
                      _setColor(c);
                    },
                  ),
                  gapH8,
                ],
              )),
        ),
        body: Stack(children: [
          GoogleMap(
            mapType: isHybrid ? MapType.hybrid : MapType.normal,
            myLocationEnabled: true,
            markers: _markers,
            polylines: _polyLines,
            initialCameraPosition: _myCurrentCameraPosition,
            onTap: _addNewRoutePoint,
            onMapCreated: (GoogleMapController controller) {
              pp('\n$mm ..... Google Map has been created and is ready to have shit placed on iit!\n');
              _mapController.complete(controller);
              googleMapController = controller;
              _zoomToStartCity();
              _getPointsAndLandmarks(true);
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
                        getRoutePoints(true);
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
                            Text(
                              routeMapping,
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
                      '${existingRoutePoints.length}',
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
                          _getPointsAndLandmarks(true);
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: Theme.of(context).primaryColor,
                        )),
                    gapW32,
                    gapW32,
                    // IconButton(
                    //     onPressed: () {
                    //       _deleteLastRoutePoint();
                    //     },
                    //     icon: Icon(
                    //       Icons.delete,
                    //       color: Theme.of(context).primaryColor,
                    //     )),
                  ],
                ),
              )),
          busy
              ? const Positioned(
                  child: Center(
                  child: TimerWidget(title: 'Loading ...', isSmallSize: true),
                ))
              : const SizedBox(),
        ]));
  }
}
