import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';

class RouteMapEditor extends StatefulWidget {
  const RouteMapEditor(
      {Key? key, required this.route, required this.listApiDog})
      : super(key: key);

  final lib.Route route;
  final ListApiDog listApiDog;
  @override
  RouteMapEditorState createState() => RouteMapEditorState();
}

class RouteMapEditorState extends State<RouteMapEditor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final mm = '🔷🔷🔷GeofenceMapTablet: ';
  late AnimationController _animationController;
  final Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController? googleMapController;

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  var random = Random(DateTime.now().millisecondsSinceEpoch);
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-25.85656, 27.7857),
    zoom: 14.4746,
  );

  var routePoints = <lib.RoutePoint>[];
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  Future<void> _addMarkers() async {
    pp('$mm _addMarker for geofence: ....... 🍎 ');
    markers.clear();
    var latLongs = <LatLng>[];
    for (var value in routePoints) {
      var latLng = LatLng(
          value.position!.coordinates[1], value.position!.coordinates[0]);
      latLongs.add(latLng);

      final MarkerId markerId = MarkerId('${random.nextInt(9999988)}');
      final Marker marker = Marker(
        markerId: markerId,
        // icon: markerIcon,
        position: latLng,
        infoWindow:
            InfoWindow(title: value.routeName, snippet: 'Route point'),
        onTap: () {
          _onMarkerTapped();
        },
      );
      markers[markerId] = marker;
    }

    googleMapController = await _mapController.future;
    if (latLongs.isNotEmpty) {
      var latLng = latLongs.first;
      _animateCamera(
          latitude: latLng.latitude, longitude: latLng.longitude, zoom: 14.0);
    }
  }

  void _onMarkerTapped() {
    pp('$mm  GeofenceMapTablet: _onMarkerTapped ....... ');
  }

  void _animateCamera(
      {required double latitude,
      required double longitude,
      required double zoom}) {
    final CameraPosition cameraPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: zoom,
    );
    googleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<List<lib.RoutePoint>>(
          stream: widget.listApiDog.routePointStream,
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              routePoints = snapshot.data!;
              _addMarkers();
              setState(() {});
            }
            return Stack(
              children: [
                GoogleMap(
                  mapType: MapType.hybrid,
                  mapToolbarEnabled: true,
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) async {
                    pp('\n\\$mm 🍎🍎🍎........... GoogleMap onMapCreated ... ready to rumble!\n\n');
                    _mapController.complete(controller);
                    googleMapController = controller;
                    _addMarkers();
                    setState(() {});
                    _animationController.forward();
                  },
                  // myLocationEnabled: true,
                  markers: Set<Marker>.of(markers.values),
                  compassEnabled: true,
                  buildingsEnabled: true,
                  zoomControlsEnabled: true,
                ),
              ],
            );
          }),
    ));
  }
}
