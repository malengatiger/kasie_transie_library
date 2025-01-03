import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart' as cl;
import 'package:kasie_transie_library/maps/cluster_maps/toggle.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;

import '../../bloc/list_api_dog.dart';
import '../../utils/prefs.dart';
import 'cluster_covers.dart';

class CommuterClusterMap extends StatefulWidget {
  const CommuterClusterMap(
      {super.key, required this.commuterRequestCovers, required this.date});
  final String date;
  final List<CommuterRequestCover> commuterRequestCovers;
  @override
  CommuterClusterMapState createState() => CommuterClusterMapState();
}

class CommuterClusterMapState extends State<CommuterClusterMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Completer<GoogleMapController> _googleMapController = Completer();
  final mm = '🍐🍐🍐🍐CommuterClusterMap 🍐🍐';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

  var routes = <lib.Route>[];
  Set<Marker> markers = {};
  late cl.ClusterManager clusterManager;
  final CameraPosition _parisCameraPosition =
      const CameraPosition(target: LatLng(-27.856613, 25.352222), zoom: 14.0);

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    clusterManager = _initClusterManager();
    super.initState();
    _getRoutes();
  }

  Future _getRoutes() async {
    final m = HashMap<String, String>();
    for (var value in widget.commuterRequestCovers) {
      m[value.request.routeId!] = value.request.routeName!;
    }
    for (var value1 in m.keys.toList()) {
      final route = await listApiDog.getRoute(routeId: value1, refresh: false);
      routes.add(route!);
    }
    pp('${routes.length} routes filtered');
    setState(() {});
  }

  cl.ClusterManager<cl.ClusterItem> _initClusterManager() {
    pp('$mm ......... _initClusterManager, ${E.appleRed} items: ${widget.commuterRequestCovers.length}');
    clusterManager = cl.ClusterManager<CommuterRequestCover>(
        widget.commuterRequestCovers, _updateMarkers,
        markerBuilder: _markerBuilder);

    return clusterManager;
  }

  void _updateMarkers(Set<Marker> p1) {
    // pp('$mm ... updateMarkers ... ${p1.length} markers');
    setState(() {
      markers = p1;
    });
  }

  Future<Marker> Function(dynamic) get _markerBuilder =>
          (cluster) async {
        var size = cluster.isMultiple ? 125.0 : 75.0;
        var text = cluster.isMultiple ? cluster.count.toString() : "1";
        final ic = await getMarkerBitmap(
          size.toInt(),
          text: text,
          color: 'indigo',
          borderColor: Colors.white,
          fontWeight: FontWeight.normal,
          fontSize: size / 3,
        );
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location, // Use cluster.location instead of cluster.items[0].latLng
          onTap: () {
            pp('$mm ---- cluster? ${E.redDot} $cluster');
            for (var p in cluster.items) {
              pp('$mm ... VehicleArrivalCover - cluster item: ${E.appleRed} '
                  '${p.arrival.vehicleReg} - ${p.arrival.landmarkName} - ${p.arrival.created}');
            }
          },
          icon: ic,
        );
      };

  bool hybrid = true;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoomToStart() async {
    final pc = widget.commuterRequestCovers.first;
    final latLng = pc.latLng;
    var cameraPos = CameraPosition(target: latLng, zoom: 14.0);
    final GoogleMapController controller = await _googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.people_rounded,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              'Commuter Requests Map',
              style: myTextStyleMediumLargeWithColor(
                  context, Theme.of(context).primaryColor, 20),
            ),
          ],
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Start Time: ',
                      style: myTextStyleTiny(context),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.date,
                      style: myTextStyleSmall(context),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                )
              ],
            )),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _parisCameraPosition,
            buildingsEnabled: true,
            mapType: hybrid ? MapType.hybrid : MapType.normal,
            markers: markers,
            onCameraMove: clusterManager.onCameraMove,
            onCameraIdle: clusterManager.updateMap,
            onMapCreated: (GoogleMapController cont) {
              pp('$mm .......... onMapCreated ...........');
              _googleMapController.complete(cont);
              clusterManager.setMapId(cont.mapId);
              clusterManager.setItems(widget.commuterRequestCovers);
              //_updateMarkers(widget.passengerCountCovers);
              _zoomToStart();
            },
          ),
          Positioned(
            right: 12,
            top: 0,
            child: SizedBox(
              width: 48,
              height: 48,
              child: HybridToggle(
                  onHybrid: () {
                    setState(() {
                      hybrid = true;
                    });
                  },
                  onNormal: () {
                    setState(() {
                      hybrid = false;
                    });
                  },
                  hybrid: hybrid),
            ),
          ),
        ],
      ),
    ));
  }
}
