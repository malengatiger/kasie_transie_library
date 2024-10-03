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
import '../../messaging/fcm_bloc.dart';
import 'cluster_covers.dart';

class LiveClusterMap extends StatefulWidget {
  const LiveClusterMap({
    super.key,
  });

  @override
  LiveClusterMapState createState() => LiveClusterMapState();
}

class LiveClusterMapState extends State<LiveClusterMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Completer<GoogleMapController> _googleMapController = Completer();
  final mm = '🍐🍐🍐🍐LiveClusterMap 🍐🍐';

  var routes = <lib.Route>[];
  late cl.ClusterManager dispatchClusterManager;
  late cl.ClusterManager requestsClusterManager;

  List<DispatchRecordCover> dispatchRecordCovers = [];
  List<CommuterRequestCover> commuterRequestCovers = [];

  Set<Marker> dispatchMarkers = {};
  Set<Marker> requestMarkers = {};

  List<lib.DispatchRecord> liveDispatchRecords = [];
  List<lib.CommuterRequest> liveCommuterRequests = [];

  late StreamSubscription<lib.DispatchRecord> dispatchSub;
  late StreamSubscription<lib.CommuterRequest> commuterSub;

  final CameraPosition _parisCameraPosition =
      const CameraPosition(target: LatLng(-27.856613, 25.352222), zoom: 14.0);
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    dispatchClusterManager = _initDispatchClusterManager();
    requestsClusterManager = _initRequestClusterManager();
    super.initState();
    _listen();
  }

  void _listen() async {
    dispatchSub = fcmBloc.dispatchStream.listen((event) {
      pp('$mm ... dispatchStream delivered: ${event.vehicleReg}');
      liveDispatchRecords.add(event);
      dispatchRecordCovers.add(DispatchRecordCover(
        latLng: LatLng(
            event.position!.coordinates[1], event.position!.coordinates[0]),
        dispatchRecord: event,
      ));
      _getRoutes();
      dispatchClusterManager.setItems(dispatchRecordCovers);

      if (mounted) {
        setState(() {});
        _animate(LatLng(
            event.position!.coordinates[1], event.position!.coordinates[0]));
      }
    });
    commuterSub = fcmBloc.commuterRequestStreamStream.listen((event) {
      pp('$mm ... commuterRequestStreamStream delivered: ${event.dateRequested}');
      liveCommuterRequests.add(event);
      commuterRequestCovers.add(CommuterRequestCover(
        request: event,
        latLng: LatLng(event.currentPosition!.coordinates[1],
            event.currentPosition!.coordinates[0]),
      ));

      if (mounted) {
        setState(() {});
        // _animate(LatLng(event.currentPosition!.coordinates[1],
        //     event.currentPosition!.coordinates[0]));
      }
    });
  }

  Future _getRoutes() async {
    final m = HashMap<String, String>();
    for (var value in liveDispatchRecords) {
      m[value.routeId!] = value.routeName!;
    }
    for (var value in liveCommuterRequests) {
      m[value.routeId!] = value.routeName!;
    }
    for (var value1 in m.keys.toList()) {
      final route = await listApiDog.getRoute(value1);
      routes.add(route!);
    }
    pp('$mm ${routes.length} distinct routes from dispatches and requests ');

    if (mounted) {
      setState(() {});
    }
  }

  cl.ClusterManager<cl.ClusterItem> _initDispatchClusterManager() {
    pp('$mm ......... _initDispatchClusterManager, ${E.appleRed} items: ${liveDispatchRecords.length}');
    for (var element in liveDispatchRecords) {
      dispatchRecordCovers.add(DispatchRecordCover(
        dispatchRecord: element,
        latLng: LatLng(
            element.position!.coordinates[1], element.position!.coordinates[0]),
      ));
    }
    //
    dispatchClusterManager = cl.ClusterManager<DispatchRecordCover>(
        dispatchRecordCovers, _updateDispatchMarkers,
        markerBuilder: _dispatchMarkerBuilder);

    return dispatchClusterManager;
  }

  cl.ClusterManager<cl.ClusterItem> _initRequestClusterManager() {
    pp('$mm ......... _initRequestClusterManager, ${E.appleRed} items: ${liveCommuterRequests.length}');
    for (var element in liveCommuterRequests) {
      commuterRequestCovers.add(CommuterRequestCover(
        request: element,
        latLng: LatLng(element.currentPosition!.coordinates[1],
            element.currentPosition!.coordinates[0]),
      ));
    }
    requestsClusterManager = cl.ClusterManager<CommuterRequestCover>(
        commuterRequestCovers, _updateRequestMarkers,
        markerBuilder: _requestMarkerBuilder);

    return requestsClusterManager;
  }

  void _updateDispatchMarkers(Set<Marker> p1) {
    setState(() {
      dispatchMarkers = p1;
    });
  }

  void _updateRequestMarkers(Set<Marker> p1) {
    setState(() {
      requestMarkers = p1;
    });
  }

  Future<Marker> Function(dynamic) get _dispatchMarkerBuilder =>
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


  Future<Marker> Function(dynamic) get _requestMarkerBuilder =>
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

  Future<void> _animate(LatLng latLng) async {
    var cameraPos = CameraPosition(target: latLng, zoom: 12.0);
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
              Icons.airport_shuttle,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              width: 16,
            ),
            Text(
              'Dispatches & Commuters',
              style: myTextStyleMediumLargeWithColor(
                  context, Theme.of(context).primaryColor, 14),
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
                      getFormattedDateLong(DateTime.now().toIso8601String()),
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
            markers: dispatchMarkers..addAll(requestMarkers),
            onCameraMove: (position) {
              dispatchClusterManager.onCameraMove(position);
              requestsClusterManager.onCameraMove(position);
            },
            onCameraIdle: () {
              dispatchClusterManager.updateMap();
              requestsClusterManager.updateMap();
            },
            onMapCreated: (GoogleMapController cont) {
              pp('$mm .......... onMapCreated set up cluster managers ...........');
              _googleMapController.complete(cont);

              dispatchClusterManager.setMapId(cont.mapId);
              requestsClusterManager.setMapId(cont.mapId);
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
