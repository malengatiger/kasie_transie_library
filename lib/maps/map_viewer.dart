import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/data/route_data.dart';
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/maps/route_creator_map2.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:uuid/uuid.dart';

class MapViewer extends StatefulWidget {
  final lib.Route route;
  final bool? refresh;
  const MapViewer({
    super.key,
    required this.route, this.refresh,
  });

  @override
  MapViewerState createState() => MapViewerState();
}

class MapViewerState extends State<MapViewer> {
  static const defaultZoom = 13.0;
  final Completer<GoogleMapController> _mapController = Completer();
  late GoogleMapController googleMapController;
  CameraPosition? _myCurrentCameraPosition;
  static const mm = '😡😡😡😡😡😡😡 MapViewer: 💪 ';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  final _key = GlobalKey<ScaffoldState>();
  bool busy = false;
  bool isHybrid = true;
  lib.User? _user;
  lib.Position? _currentPosition;
  final Set<Marker> _markers = HashSet();
  final Set<Circle> _circles = HashSet();
  final Set<Polyline> _polyLines = {};
  List<lib.RoutePoint> rpList = [];
  List<lib.RoutePoint> routePoints = [];
  List<lib.RouteLandmark> routeLandmarks = [];

  List<LatLng>? polylinePoints;
  Color color = Colors.black;
  int landmarkIndex = 0;
  String? stringColor;
  String routeMapViewer = 'Viewer', changeColor = '';

  AssociationRouteData? associationRouteData;

  @override
  void initState() {
    super.initState();
    _setTexts();
    _setRouteColor();
    _setCameraPosition();
    _getUser();
  }

  _getRouteData() async {
    setState(() {
      busy = true;
    });
    pp('\n\n$mm getting route data for ${widget.route.name}');
    associationRouteData = await listApiDog.getSingleRouteData(
        widget.route.routeId!, widget.refresh == null? false: true);

    if (associationRouteData != null) {
      pp('$mm route data found: ${associationRouteData?.routeDataList.length} routes');

      for (var routeData in associationRouteData!.routeDataList) {
        if (routeData.routeId == widget.route.routeId!) {
          routePoints = routeData.routePoints;
          routeLandmarks = routeData.landmarks;
        }
      }
    }
    if (routePoints.isEmpty) {
      //_showNoPointsDialog();
      if (mounted) {
        showErrorToast(message: 'Route has not been mapped yet', context: context);
      }
      return;
    }
    pp('$mm .......... _getRouteData completed : ${routePoints.length} routePoints found.');

    await _setMapPolyLine();
    await _setRouteLandmarks();

    setState(() {
      busy = false;
    });
  }

  Future _setTexts() async {
    final c = prefs.getColorAndLocale();
    routeMapViewer = await translator.translate('routeMapViewer', c.locale);
    changeColor = await translator.translate('changeColor', c.locale);

    setState(() {});
  }

  Future _setRouteColor() async {
    color = getColor(widget.route.color!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _setRouteLandmarks() async {
    pp('$mm _setRouteLandmarks ...  route: ${widget.route.name!}; routeLandmarks: ${routeLandmarks.length} ');

    _markers.clear();
    landmarkIndex = 0;
    routeLandmarks.sort((a,b) => a.index!.compareTo(b.index!));
    for (var landmark in routeLandmarks) {
      final latLng = LatLng(landmark.position!.coordinates.last,
          landmark.position!.coordinates.first);

      final icon = await getMarkerBitmap(72,
          text: '${landmarkIndex + 1}',
          color: widget.route.color ?? 'black',
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
                  '\nThis landmark is part of the route:\n ${widget.route!.name}\n\n',
              title: '🍎 ${landmark.landmarkName}',
              onTap: () {
                pp('$mm ............. infoWindow tapped, point index: $index');
                //_deleteLandmark(landmark);
              }),
          position: latLng));
      landmarkIndex++;
    }
    _addCurrentCarLocation();
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
                child: Text('This route has no points defined yet'),
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
                      widget: RouteCreatorMap2(route: widget.route),
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

  Future _setMapPolyLine() async {
    pp('$mm ... _setMapPolyLine ... points: ${routePoints.length}');
    try {
      _addPolyLine();
      setState(() {});
      var point = routePoints.first;
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
  }

  Future _getUser() async {
    _user = prefs.getUser();
  }

  RouteData? routeData;

  Future _setCameraPosition() async {
    _myCurrentCameraPosition = CameraPosition(
      target: LatLng(
          widget.route.routeStartEnd!.startCityPosition!.coordinates[1],
          widget.route.routeStartEnd!.startCityPosition!.coordinates[0]),
      zoom: defaultZoom,
    );

    setState(() {});
  }

  int index = 0;

  Future<BitmapDescriptor> getBitmapDescriptorFromAssetBytes(
      String path) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(bytes);
  }

  DeviceLocationBloc locationBloc = GetIt.instance<DeviceLocationBloc>();

  void _addCurrentCarLocation() async {
    pp('$mm .......... _addCurrentCarLocation ....... .');
    final icon = await getBitmapDescriptorFromAssetBytes('assets/car1.png');
    var loc = await locationBloc.getLocation();
    _markers.add(Marker(
        markerId: MarkerId(Uuid().v4().toString()),
        icon: icon,
        onTap: () {
          pp('$mm .............. marker tapped - this is where the car is');
        },
        infoWindow: InfoWindow(
            snippet: 'This is where the car is',
            title: 'Car Location',
            onTap: () {
              pp('$mm ............. infoWindow tapped, point index: $index');
              //_deleteLandmark(landmark);
            }),
        position: LatLng(loc.latitude, loc.longitude)));
  }

  void _addPolyLine() {
    pp('$mm .......... _addPolyLine ....... .');
    _polyLines.clear();
    var mPoints = <LatLng>[];
    routePoints.sort((a, b) => a.index!.compareTo(b.index!));
    for (var rp in routePoints) {
      mPoints.add(LatLng(
          rp.position!.coordinates.last, rp.position!.coordinates.first));
    }
    var polyLine = Polyline(
        color: color,
        width: 8,
        points: mPoints,
        polylineId: PolylineId(DateTime.now().toIso8601String()));

    _polyLines.add(polyLine);
  }

  String waitingForGPS = 'waiting for mapping ...';
  bool showColors = false;
  var topHeight = 100.0;

  @override
  Widget build(BuildContext context) {
    // pp('$mm .......... build ... markers: ${_markers.length} polyline: ${_polyLines.length}');

    return Scaffold(
        key: _key,
        body: _myCurrentCameraPosition == null
            ? Center(
                child: TimerWidget(title: waitingForGPS, isSmallSize: true),
              )
            : Stack(children: [
                OrientationBuilder(builder: (ctx, orientation) {
                  return GoogleMap(
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
                      pp('$mm .......... GoogleMap: onMapCreated : ${controller.toString()} ....... on to Cleveland!');
                      _mapController.complete(controller);
                      await _getRouteData();
                    },
                  );
                }),
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
                          color: Colors.black26,
                          elevation: 24,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: SizedBox(
                              height: 36,
                              child: Column(
                                children: [
                                  gapH4,

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.arrow_back_ios,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      gapW8,
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          '${widget.route.name}',
                                          style: myTextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Text(
                                  //   '${widget.route.associationName}',
                                  //   style: myTextStyleTiny(context),
                                  // )
                                ],
                              ),
                            ),
                          ),
                        ))),
                busy
                    ? const Positioned(
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
