import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:kasie_transie_library/maps/cluster_maps/toggle.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';

import 'cluster_covers.dart';

class PassengerCountClusterMap extends StatefulWidget {
  const PassengerCountClusterMap({Key? key, required this.passengerCountCovers}) : super(key: key);

  final List<PassengerCountCover> passengerCountCovers;
  @override
  PassengerCountClusterMapState createState() => PassengerCountClusterMapState();
}

class PassengerCountClusterMapState extends State<PassengerCountClusterMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Completer<GoogleMapController> _googleMapController = Completer();
  final mm = '🍐🍐🍐🍐PassengerCountClusterMap 🍐🍐';

  Set<Marker> markers = {};
  late ClusterManager clusterManager;
  final CameraPosition _parisCameraPosition =
  const CameraPosition(target: LatLng(48.856613, 2.352222), zoom: 12.0);


  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    clusterManager = _initClusterManager();
    super.initState();
  }

  ClusterManager<ClusterItem> _initClusterManager() {
    pp('$mm ......... _initClusterManager, ${E.appleRed} items: ${widget.passengerCountCovers.length}');
    clusterManager = ClusterManager<PassengerCountCover>(widget.passengerCountCovers, _updateMarkers,
        markerBuilder: _markerBuilder);

    return clusterManager;
  }

  void _updateMarkers(Set<Marker> p1) {
    // pp('$mm ... updateMarkers ... ${p1.length} markers');
    setState(() {
      markers = p1;
    });
  }

  Future<Marker> Function(Cluster<PassengerCountCover>) get _markerBuilder =>
          (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            pp('$mm ---- cluster? ${E.redDot} $cluster');
            for (var p in cluster.items) {
              pp('$mm ... PassengerCountCover - cluster item: ${E.appleRed} ${p.passengerCount.vehicleReg}'
                  '\n${E.leaf} passengersIn: ${p.passengerCount.passengersIn} '
                  '\n${E.leaf} passengersOut: ${p.passengerCount.passengersOut} '
                  '\n${E.leaf} currentPassengers: ${p.passengerCount.currentPassengers}');
            }
          },
          icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
              text: cluster.isMultiple ? cluster.count.toString() : null),
        );
      };

  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
    if (kIsWeb) size = (size / 2).floor();

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.indigo;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }
  bool hybrid = true;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoomToStart() async {
    if (widget.passengerCountCovers.isEmpty) {
      return;
    }
    final pc = widget.passengerCountCovers.first;
    final latLng = pc.latLng;
    var cameraPos = CameraPosition(target: latLng, zoom: 14.0);
    final GoogleMapController controller = await _googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title:  Text('Passenger Counts',style: myTextStyleMediumLargeWithColor(
            context, Theme.of(context).primaryColor, 20),),
      ),
      body: Stack(
        children: [
          GoogleMap(initialCameraPosition: _parisCameraPosition,
          buildingsEnabled: true,
          mapType: hybrid? MapType.hybrid: MapType.normal,
          markers: markers,
          onCameraMove: clusterManager.onCameraMove,
          onCameraIdle: clusterManager.updateMap,
          onMapCreated: (GoogleMapController cont){
            pp('$mm .......... onMapCreated ...........');
            _googleMapController.complete(cont);
            clusterManager.setMapId(cont.mapId);
            clusterManager.setItems(widget.passengerCountCovers);
            //_updateMarkers(widget.passengerCountCovers);
            _zoomToStart();

          },),
          Positioned(
            right: 12,
            top: 0,
            child: SizedBox(width: 48, height: 48,
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

