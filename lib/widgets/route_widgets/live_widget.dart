import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:badges/badges.dart' as bd;
import 'package:kasie_transie_library/data/schemas.dart' as lib;

import '../../messaging/fcm_bloc.dart';
import '../../utils/emojis.dart';

class LiveOperations extends StatefulWidget {
  const LiveOperations(
      {super.key});

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

  var passengerCounts = <lib.AmbassadorPassengerCount>[];
  late StreamSubscription<lib.AmbassadorPassengerCount> passengerSub;
  late StreamSubscription<lib.DispatchRecord> dispatchSub;
  late StreamSubscription<lib.CommuterRequest> requestSub;
  late StreamSubscription<lib.VehicleHeartbeat> heartbeatSub;
  late StreamSubscription<lib.VehicleArrival> arrivalsSub;


  @override
  void initState() {
    super.initState();
    _listen();

  }
  void _listen() async {
    pp('\n\n$mm ... listening to FCM topics .......................... ');

    arrivalsSub = fcmBloc.vehicleArrivalStream.listen((event) {
      pp('$mm ... vehicleArrivalStream delivered an arrival \t${E.appleRed} '
          '${event.vehicleReg} at ${event.landmarkName} ${E.blueDot} date: ${event.created}');
      // myPrettyJsonPrint(event.toJson());
      arrivals.add(event);
      if (mounted) {
        setState(() {});
      }
    });
    passengerSub = fcmBloc.passengerCountStream.listen((event) {
      pp('$mm ... passengerCountStream delivered a count \t ${E.pear} ${event.vehicleReg} '
          '${E.blueDot} date:  ${event.created}');
      // myPrettyJsonPrint(event.toJson());
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
      // myPrettyJsonPrint(event.toJson());
      dispatches.add(event);
      if (mounted) {
        setState(() {});
      }
    });
    requestSub = fcmBloc.commuterRequestStreamStream.listen((event) {
      pp('$mm ... commuterRequestStreamStream delivered a request \t ${E.appleRed} '
          '${event.routeLandmarkName} ${E.blueDot} date:  ${event.dateRequested}');
      // myPrettyJsonPrint(event.toJson());
      requests.add(event);
      if (mounted) {
        setState(() {});
      }
    });
    heartbeatSub = fcmBloc.heartbeatStreamStream.listen((event) {
      pp('$mm ... heartbeatStreamStream delivered a heartbeat \t '
          '${E.appleRed} ${event.vehicleReg} ${E.blueDot} date:  ${event.created}');
      // myPrettyJsonPrint(event.toJson());
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
    super.dispose();


  }
  @override
  Widget build(BuildContext context) {
    var width = 600.0, height = 800.0;
    final type = getThisDeviceType();
    if (type == 'phone') {
      width = 400;
      height = 600;
    }
    return SizedBox(
      height: height,
      width: width,
      child: Card(
        shape: getRoundedBorder(radius: 16),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Card(
                shape: getRoundedBorder(radius: 12),
                elevation: 12,
                child: SizedBox(
                  height: 60,
                  child: Column(
                    children: [
                      bd.Badge(
                        badgeContent: Text('${dispatches.length}'),
                        badgeStyle: const bd.BadgeStyle(
                          badgeColor: Colors.deepOrange,
                          elevation: 12,
                          padding: EdgeInsets.all(12.0),
                        ),
                      ),
                      const Text('Dispatch Records'),
                    ],
                  ),
                ),
              ),
              Card(
                shape: getRoundedBorder(radius: 12),
                elevation: 12,
                child: SizedBox(
                  height: 60,
                  child: Column(
                    children: [
                      bd.Badge(
                        badgeContent: Text('${heartbeats.length}'),
                        badgeStyle:  bd.BadgeStyle(
                          badgeColor: Colors.teal.shade700,
                          elevation: 12,
                          padding: const EdgeInsets.all(12.0),
                        ),
                      ),
                      const Text('Vehicle Heartbeat'),
                    ],
                  ),
                ),
              ),
              Card(
                shape: getRoundedBorder(radius: 12),
                elevation: 12,
                child: SizedBox(
                  height: 60,
                  child: Column(
                    children: [
                      bd.Badge(
                        badgeContent: Text('${passengerCounts.length}'),
                        badgeStyle:  bd.BadgeStyle(
                          badgeColor: Colors.pink.shade700,
                          elevation: 12,
                          padding: const EdgeInsets.all(12.0),
                        ),
                      ),
                      const Text('Passenger Count Events'),
                    ],
                  ),
                ),
              ),
              Card(
                shape: getRoundedBorder(radius: 12),
                elevation: 12,
                child: SizedBox(
                  height: 60,
                  child: Column(
                    children: [
                      bd.Badge(
                        badgeContent: Text('${requests.length}'),
                        badgeStyle:  bd.BadgeStyle(
                          badgeColor: Colors.blue.shade700,
                          elevation: 12,
                          padding: const EdgeInsets.all(12.0),
                        ),
                      ),
                      const Text('Commuter Requests'),
                    ],
                  ),
                ),
              ),
              Card(
                shape: getRoundedBorder(radius: 12),
                elevation: 12,
                child: SizedBox(
                  height: 60,
                  child: Column(
                    children: [
                      bd.Badge(
                        badgeContent: Text('${arrivals.length}'),
                        badgeStyle:  bd.BadgeStyle(
                          badgeColor: Colors.amber.shade900,
                          elevation: 12,
                          padding: const EdgeInsets.all(12.0),
                        ),
                      ),
                      const Text('Vehicle Arrivals'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
