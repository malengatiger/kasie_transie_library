import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/data/vehicle_bag.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/vehicle_passenger_count.dart';

import '../widgets/drop_down_widgets.dart';

class VehicleMonitorMap extends StatefulWidget {
  const VehicleMonitorMap({Key? key, required this.vehicle}) : super(key: key);

  final lib.Vehicle vehicle;
  @override
  VehicleMonitorMapState createState() => VehicleMonitorMapState();
}

class VehicleMonitorMapState extends State<VehicleMonitorMap>
    with SingleTickerProviderStateMixin {
  final mm = '🍐🍐🍐🍐VehicleMonitorMap 🍐🍐';

  late AnimationController _controller;
  final Completer<GoogleMapController> _googleMapController = Completer();

  CameraPosition initialCameraPosition =
      const CameraPosition(target: LatLng(-25.6, 27.4), zoom: 14);

  var dispatches = <lib.DispatchRecord>[];
  var heartbeats = <lib.VehicleHeartbeat>[];

  VehicleBag? bag;
  int hours = 1;
  bool busy = false;
  String title = "Maps";
  Set<Marker> markers = {};
  Set<Polyline> polyLines = {};

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getData();
  }

  Future _getData() async {
    setState(() {
      busy = true;
    });
    final date = DateTime.now()
        .toUtc()
        .subtract(Duration(hours: hours))
        .toIso8601String();
    try {
      bag = await listApiDog.getVehicleBag(widget.vehicle.vehicleId!, date);
      _getRoutes();
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(message: 'Could not get data', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  void _getRoutes() {
    var hash = HashMap<String,String>();
    for (var value in dispatches) {
      hash[value.routeId!] = value.routeId!;
    }
    for (var value in dispatches) {
      hash[value.routeId!] = value.routeId!;
    }
  }
  void _putRoutesOnMap() async {

  }
  void _putHeartbeatsOnMap() async {}
  void _putArrivalsOnMap() async {}
  void _putCountsOnMap() async {}
  void _putDeparturesOnMap() async {}
  bool hybrid = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Text(
              title,
              style: myTextStyleMediumLargeWithColor(
                  context, Theme.of(context).primaryColor, 24),
            ),
            Row(
              children: [
                Row(
                  children: [
                    Text(
                      'Hours',
                      style: myTextStyleMediumLargeWithColor(
                          context, Theme.of(context).primaryColorLight, 20),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      '$hours',
                      style: myTextStyleMediumLargeWithColor(
                          context, Theme.of(context).primaryColor, 24),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    NumberDropDown(
                        onNumberPicked: (number) {
                          setState(() {
                            hours = number;
                          });
                          _getData();
                        },
                        color: Theme.of(context).primaryColor,
                        count: 24,
                        fontSize: 20)
                  ],
                )
              ],
            ),
            Expanded(
                child: GoogleMap(
              initialCameraPosition: initialCameraPosition,
              mapType: hybrid ? MapType.hybrid : MapType.normal,
              markers: markers,
              polylines: polyLines,
              onMapCreated: (cont) {
                pp('$mm .......... onMapCreated set up cluster managers ...........');
                _googleMapController.complete(cont);
              },
            )),
          ],
        )
      ],
    );
  }
}
