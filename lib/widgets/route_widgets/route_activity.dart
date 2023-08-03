import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:responsive_builder/responsive_builder.dart';
import 'package:badges/badges.dart' as bd;
import '../../messaging/fcm_bloc.dart';
import '../../utils/functions.dart';

class RouteActivity extends StatefulWidget {
  const RouteActivity({Key? key, required this.route}) : super(key: key);

  final lib.Route route;

  @override
  RouteActivityState createState() => RouteActivityState();
}

class RouteActivityState extends State<RouteActivity>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🔵🐦🔵🐦🔵🐦 RouteActivity 🔵🔵';

  List<lib.DispatchRecord> liveDispatchRecords = [];
  List<lib.AmbassadorPassengerCount> liveCommuterRequests = [];

  late StreamSubscription<lib.DispatchRecord> dispatchSub;
  late StreamSubscription<lib.AmbassadorPassengerCount> passengerSub;

  ScrollController listScrollController1 = ScrollController();
  ScrollController listScrollController2 = ScrollController();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
  }

  void _listen() async {
    dispatchSub = fcmBloc.dispatchStream.listen((event) {
      pp('$mm ... dispatchStream delivered: ${event.vehicleReg}');
      if (event.routeId == widget.route.routeId) {
        liveDispatchRecords.add(event);
        if (mounted) {
          setState(() {});
        }
        if (listScrollController1.hasClients) {
          final position = listScrollController1.position.maxScrollExtent;
          listScrollController1.jumpTo(position);
        }
      }
    });
    passengerSub = fcmBloc.passengerCountStream.listen((event) {
      pp('$mm ... passengerCountStream delivered: ${event.vehicleReg}');
      if (event.routeId == widget.route.routeId) {
        liveCommuterRequests.add(event);
        if (mounted) {
          setState(() {});
        }
        if (listScrollController2.hasClients) {
          final position = listScrollController2.position.maxScrollExtent;
          listScrollController2.jumpTo(position);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (ctx) {
        return SafeArea(
            child: Scaffold(
          appBar: AppBar(
            title: const Text('Route Activity'),
          ),
          body: BodyList(
              listScrollController1: listScrollController1,
              listScrollController2: listScrollController2,
              dispatches: liveDispatchRecords, counts: liveCommuterRequests),
        ));
      },
      tablet: (ctx) {
        return Card(
          shape: getRoundedBorder(radius: 16),
          elevation: 8,
          child: BodyList(
              dispatches: liveDispatchRecords, counts: liveCommuterRequests,
            listScrollController1: listScrollController1,
          listScrollController2: listScrollController2,),
        );
      },
    );
  }
}

class BodyList extends StatelessWidget {
  const BodyList({
    super.key,
    required this.dispatches,
    required this.counts, required this.listScrollController1, required this.listScrollController2,
  });
  final ScrollController listScrollController1;
  final ScrollController listScrollController2;

  final List<lib.DispatchRecord> dispatches;
  final List<lib.AmbassadorPassengerCount> counts;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm');
    final height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(
              height: 64,
              child: Center(
                child: Text(
                  'Taxi Dispatches',
                  style: myTextStyleMediumLargeWithColor(
                      context, Theme.of(context).primaryColorLight, 20),
                ),
              ),
            ),
            SizedBox(
              height: (height / 3),
              child: bd.Badge(
                badgeContent: Text(
                  '${dispatches.length}',
                  style: myTextStyleTiny(context),
                ),
                badgeStyle: const bd.BadgeStyle(
                    elevation: 8.0,
                    badgeColor: Colors.deepOrange,
                    padding: EdgeInsets.all(8.0)),
                child: ListView.builder(
                    itemCount: dispatches.length,
                    controller: listScrollController1,
                    itemBuilder: (ctx, index) {
                      final dispatch = dispatches.elementAt(index);
                      return Card(
                        shape: getRoundedBorder(radius: 8),
                        elevation: 8,
                        child: SizedBox(
                          height: 40.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      fmt.format(
                                          DateTime.parse(dispatch.created!)),
                                      style: myTextStyleMediumLargeWithColor(
                                          context,
                                          Theme.of(context).primaryColor,
                                          14),
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Text(
                                      '${dispatch.vehicleReg}',
                                      style: myTextStyleMediumLargeWithColor(
                                          context,
                                          Theme.of(context).primaryColorLight,
                                          14),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      '${dispatch.landmarkName}',
                                      style: myTextStyleTiny(context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
            SizedBox(
              height: 64,
              child: Center(
                child: Text(
                  'Passenger Counts',
                  style: myTextStyleMediumLargeWithColor(
                      context, Theme.of(context).primaryColorLight, 20),
                ),
              ),
            ),
            SizedBox(
              height: (height / 2),
              child: bd.Badge(
                badgeContent: Text(
                  '${counts.length}',
                  style: myTextStyleTiny(context),
                ),
                badgeStyle: const bd.BadgeStyle(
                  elevation: 8.0,
                  badgeColor: Colors.pink,
                  padding: EdgeInsets.all(8.0),
                ),
                child: ListView.builder(
                    itemCount: counts.length,
                    controller: listScrollController2,

                    itemBuilder: (ctx, index) {
                      final bag = counts.elementAt(index);
                      return Card(
                        shape: getRoundedBorder(radius: 8),
                        elevation: 8,
                        child: SizedBox(
                          height: 40.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      fmt.format(DateTime.parse(bag.created!)),
                                      style: myTextStyleMediumLargeWithColor(
                                          context,
                                          Theme.of(context).primaryColor,
                                          14),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    PassengerDisplay(passengerCount: bag),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Text(
                                      '${bag.vehicleReg}',
                                      style: myTextStyleTiny(context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PassengerDisplay extends StatelessWidget {
  const PassengerDisplay({super.key, required this.passengerCount});
  final lib.AmbassadorPassengerCount passengerCount;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 60,
          child: Row(
            children: [
              Text(
                'In',
                style: myTextStyleTiny(context),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                '${passengerCount.passengersIn}',
                style: myTextStyleMediumLargeWithColor(
                    context, Theme.of(context).primaryColorLight, 14),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 60,
          child: Row(
            children: [
              Text(
                'Out',
                style: myTextStyleTiny(context),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                '${passengerCount.passengersOut}',
                style: myTextStyleMediumLargeWithColor(
                    context, Theme.of(context).primaryColorLight, 14),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 80,
          child: Row(
            children: [
              Text(
                'Current',
                style: myTextStyleTiny(context),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                '${passengerCount.currentPassengers}',
                style:
                    myTextStyleMediumLargeWithColor(context, Colors.teal, 14),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class BodyBag {
  lib.AmbassadorPassengerCount? passengerCount;
  lib.DispatchRecord? dispatchRecord;

  BodyBag(this.passengerCount, this.dispatchRecord);
}
