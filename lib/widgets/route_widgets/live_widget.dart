import 'dart:async';

import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';

import '../../messaging/fcm_bloc.dart';
import '../../utils/emojis.dart';

class LiveOperations extends StatefulWidget {
  const LiveOperations(
      {super.key,
      required this.width,
      required this.height,
      required this.elevation,
      required this.restart});

  final double width, height, elevation;
  final bool restart;

  @override
  State<LiveOperations> createState() => _LiveOperationsState();
}

class _LiveOperationsState extends State<LiveOperations> {
  //int dispatches = 0, heartbeats = 0, commuters = 0, passengerCounts = 0, arrivals = 0;
  final mm = '🍎🍎🍎🍎🍎 LiveOperations 🍐🍐';
  var dispatches = <lib.DispatchRecord>[];
  var requests = <lib.CommuterRequest>[];
  var heartbeats = <lib.VehicleHeartbeat>[];
  var arrivals = <lib.VehicleArrival>[];
  var departures = <lib.VehicleDeparture>[];
  var passengerCounts = <lib.AmbassadorPassengerCount>[];
  late StreamSubscription<lib.AmbassadorPassengerCount> passengerSub;
  late StreamSubscription<lib.DispatchRecord> dispatchSub;
  late StreamSubscription<lib.CommuterRequest> requestSub;
  late StreamSubscription<lib.VehicleHeartbeat> heartbeatSub;
  late StreamSubscription<lib.VehicleArrival> arrivalsSub;
  late StreamSubscription<lib.VehicleDeparture> departureSub;


  @override
  void initState() {
    super.initState();
    _listen();
    _restart();
  }

  void _restart() {
    if (widget.restart) {
      dispatches.clear();
      requests.clear();
      heartbeats.clear();
      arrivals.clear();
      passengerCounts.clear();
      departures.clear();
    }
  }

  void _listen() async {
    pp('\n\n$mm ... listening to FCM topics .......................... ');

    arrivalsSub = fcmBloc.vehicleArrivalStream.listen((event) {
      pp('$mm ... vehicleArrivalStream delivered an arrival \t${E.appleRed} '
          '${event.vehicleReg} at ${event.landmarkName} ${E.blueDot} date: ${event.created}');
      
      arrivals.add(event);
      if (mounted) {
        setState(() {});
      }
    });
    departureSub = fcmBloc.vehicleDepartureStream.listen((event) {
      pp('$mm ... vehicleDepartureStream delivered an arrival \t${E.appleRed} '
          '${event.vehicleReg} at ${event.landmarkName} ${E.blueDot} date: ${event.created}');

      departures.add(event);
      if (mounted) {
        setState(() {});
      }
    });

    passengerSub = fcmBloc.passengerCountStream.listen((event) {
      pp('$mm ... passengerCountStream delivered a count \t ${E.pear} ${event.vehicleReg} '
          '${E.blueDot} date:  ${event.created}');
      
      pp('$mm ... PassengerCountCover - cluster item: ${E.appleRed} ${event.vehicleReg}'
          '\n${E.leaf} passengersIn: ${event.passengersIn} '
          '\n${E.leaf} passengersOut: ${event.passengersOut} '
          '\n${E.leaf} currentPassengers: ${event.currentPassengers}');
      passengerCounts.add(event);
      if (mounted) {
        setState(() {});
      }
    });
    dispatchSub = fcmBloc.dispatchStream.listen((event) {
      pp('$mm ... dispatchStream delivered a dispatch record \t '
          '${E.appleGreen} ${event.vehicleReg} ${event.landmarkName} ${E.blueDot} date:  ${event.created}');
      
      dispatches.add(event);
      if (mounted) {
        setState(() {});
      }
    });
    requestSub = fcmBloc.commuterRequestStreamStream.listen((event) {
      pp('$mm ... commuterRequestStreamStream delivered a request \t ${E.appleRed} '
          '${event.routeName} ${E.blueDot} date:  ${event.dateRequested}');
      
      requests.add(event);
      if (mounted) {
        setState(() {});
      }
    });
    heartbeatSub = fcmBloc.heartbeatStreamStream.listen((event) {
      pp('$mm ... heartbeatStreamStream delivered a heartbeat \t '
          '${E.appleRed} ${event.vehicleReg} ${E.blueDot} date:  ${event.created}');
      
      heartbeats.add(event);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    passengerSub.cancel();
    dispatchSub.cancel();
    requestSub.cancel();
    heartbeatSub.cancel();
    arrivalsSub.cancel();
    departureSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Card(
              shape: getRoundedBorder(radius: 12),
              elevation: 12,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    bd.Badge(
                      badgeContent: Text('${dispatches.length}', style: myTextStyleSmall(context),),
                      badgeStyle: const bd.BadgeStyle(
                        badgeColor: Colors.deepOrange,
                        elevation: 12,
                        padding: EdgeInsets.all(12.0),
                      ),
                    ),
                    const SizedBox(
                      width: 28,
                    ),
                    Text(
                      'Dispatch Records',
                      style: myTextStyleSmall(context),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              shape: getRoundedBorder(radius: 12),
              elevation: 12,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    bd.Badge(
                      badgeContent: Text('${heartbeats.length}', style: myTextStyleSmall(context),),
                      badgeStyle: bd.BadgeStyle(
                        badgeColor: Colors.teal.shade700,
                        elevation: 12,
                        padding: const EdgeInsets.all(12.0),
                      ),
                    ),
                    const SizedBox(
                      width: 28,
                    ),
                    Text(
                      'Vehicle Heartbeat',
                      style: myTextStyleSmall(context),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              shape: getRoundedBorder(radius: 12),
              elevation: 12,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    bd.Badge(
                      badgeContent: Text('${passengerCounts.length}', style: myTextStyleSmall(context),),
                      badgeStyle: bd.BadgeStyle(
                        badgeColor: Colors.pink.shade700,
                        elevation: 12,
                        padding: const EdgeInsets.all(12.0),
                      ),
                    ),
                    const SizedBox(
                      width: 28,
                    ),
                    Text(
                      'Passenger Count Events',
                      style: myTextStyleSmall(context),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              shape: getRoundedBorder(radius: 12),
              elevation: 12,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    bd.Badge(
                      badgeContent: Text('${requests.length}', style: myTextStyleSmall(context),),
                      badgeStyle: bd.BadgeStyle(
                        badgeColor: Colors.blue.shade700,
                        elevation: 12,
                        padding: const EdgeInsets.all(12.0),
                      ),
                    ),
                    const SizedBox(
                      width: 28,
                    ),
                    Text(
                      'Commuter Requests',
                      style: myTextStyleSmall(context),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              shape: getRoundedBorder(radius: 12),
              elevation: 12,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    bd.Badge(
                      badgeContent: Text('${arrivals.length}', style: myTextStyleSmall(context),),
                      badgeStyle: bd.BadgeStyle(
                        badgeColor: Colors.amber.shade900,
                        elevation: 12,
                        padding: const EdgeInsets.all(12.0),
                      ),
                    ),
                    const SizedBox(
                      width: 28,
                    ),
                    Text(
                      'Vehicle Arrivals',
                      style: myTextStyleSmall(context),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              shape: getRoundedBorder(radius: 12),
              elevation: 12,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    bd.Badge(
                      badgeContent: Text('${departures.length}', style: myTextStyleSmall(context),),
                      badgeStyle: bd.BadgeStyle(
                        badgeColor: Colors.indigo.shade900,
                        elevation: 12,
                        padding: const EdgeInsets.all(12.0),
                      ),
                    ),
                    const SizedBox(
                      width: 28,
                    ),
                    Text(
                      'Vehicle Departures',
                      style: myTextStyleSmall(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
