import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/isolates/routes_isolate.dart';
import 'package:kasie_transie_library/maps/route_map.dart';
import 'package:kasie_transie_library/providers/kasie_providers.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/widgets/drop_down_widgets.dart';
import 'package:kasie_transie_library/widgets/route_widgets/live_widget.dart';
import 'package:kasie_transie_library/maps/cluster_maps/live_cluster_map.dart';
import 'package:kasie_transie_library/widgets/route_widgets/route_activity.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../data/generation_request.dart';

class RouteManager extends StatefulWidget {
  const RouteManager({
    super.key,
    required this.association,
  });
  final lib.Association association;

  @override
  State<RouteManager> createState() => _RouteManagerState();
}

class _RouteManagerState extends State<RouteManager> {
  static const mm = '🔵🔵🔵🔵 RouteManager 🔵🔵';

  bool busy = false;
  var routes = <lib.Route>[];
  lib.Route? route;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() async {
    setState(() {
      busy = true;
    });
    try {
      final loc = await locationBloc.getLocation();
      pp('$mm ... location found: ${E.redDot} $loc');
      var mRoutes = await listApiDog.getRoutes(
          AssociationParameter(widget.association.associationId!, false));
      await _filter(mRoutes);
    } catch (e) {
      pp(e);
      _showError(e);
    }
    setState(() {
      busy = false;
    });
  }

  late Timer timer;
  bool restart = false;

  void _handleRoute() async {
    pp('$mm ... start generation for route: ${route!.name}');
    restart = true;
    _startGeneration();
  }

  void _startGeneration() {
    _generateDispatchRecords();
    _generateCommuterRequests();

    pp('$mm ... _startGeneration completed for route : ${route!.name} ');
  }

  Future<void> _filter(List<lib.Route> mRoutes) async {
    for (var route in mRoutes) {
      final marks = await routesIsolate.countRouteLandmarks(route.routeId!);
      if (marks > 1) {
        routes.add(route);
      }
    }
    pp('$mm ........................ ${E.heartOrange} routes found: ${routes.length}');
  }

  void _generateDispatchRecords() async {
    pp('$mm ... _generateDispatchRecords');
    setState(() {
      busy = true;
    });
    try {
      final vehicleIds = <String>[];
      final cars = await listApiDog.getAssociationVehicles(route!.associationId!, false);
      for (var i = 0; i < numberOfCars; i++) {
        vehicleIds.add(cars.elementAt(i).vehicleId!);
      }

      final startDate = DateTime.now().toUtc().subtract(const Duration(minutes: 60)).toIso8601String();
      final gen = GenerationRequest(route!.routeId!, startDate, vehicleIds, 10);
      await dataApiDog.generateRouteDispatchRecords(gen);
      _showSuccess('Dispatch record generation requests sent. Watch for action ...');
    } catch (e) {
      pp(e);
      _showError(e);
    }
    setState(() {
      busy = false;
    });
  }

  void _generateCommuterRequests() async {
    pp('$mm ... _generateCommuterRequests ');
    setState(() {
      busy = true;
    });
    try {
      await dataApiDog.generateRouteCommuterRequests(route!.routeId!, 400, 10);
      _showSuccess('Commuter request generation has been sent!');
    } catch (e) {
      pp(e);
      _showError(e);
    }
    setState(() {
      busy = false;
    });
  }

  int numberOfCars = 3;

  void _navigateToMap() {
    navigateWithScale(const LiveClusterMap(), context);
  }

  @override
  Widget build(BuildContext context) {
    var height = 800.0, width = 400.0;
    final type = getThisDeviceType();
    if (type == 'phone') {
      height = 600;
    }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Route Manager'),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(128),
            child: Column(
              children: [
                RouteDropDown(
                    routes: routes,
                    onRoutePicked: (route) {
                      setState(() {
                        this.route = route;
                      });
                      _handleRoute();
                    }),
                gapH8,
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Number of Vehicles'),
                    gapW16,
                    Text('$numberOfCars', style: myTextStyleMediumBold(context),),
                    gapW32,
                    NumberDropDown(onNumberPicked: (number){
                      setState(() {
                        numberOfCars = number;
                      });
                      _startGeneration();
                    }, color: Theme.of(context).primaryColor, count: 11, fontSize: 16),
                  ],
                ),
              ],
            )),
        actions: [
          IconButton(
              onPressed: () {
                _navigateToMap();
              },
              icon: Icon(Icons.map, color: Theme.of(context).primaryColor)),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                route == null
                    ? const SizedBox()
                    : GestureDetector(
                        onTap: () {
                          _handleRoute();
                        },
                        child: Text(
                          '${route!.name}',
                          style: myTextStyleMediumLargeWithColor(
                              context, Theme.of(context).primaryColor, 20),
                        ),
                      ),
                const SizedBox(
                  height: 24,
                ),
                Expanded(
                    child: ScreenTypeLayout.builder(
                  mobile: (ctx) {
                    return SingleChildScrollView(
                      child: LiveOperations(
                        height: height,
                        width: width,
                        restart: restart,
                        elevation: 8.0,
                      ),
                    );
                  },
                  tablet: (ctx) {
                    final width = MediaQuery.of(context).size.width;
                    return OrientationLayoutBuilder(
                      portrait: (ctx) {
                        return Row(
                          children: [
                            SizedBox(
                              width: (width / 2) - 64,
                              child: LiveOperations(
                                height: height,
                                width: width,
                                restart: restart,
                                elevation: 8.0,
                              ),
                            ),
                            SizedBox(
                              width: (width / 2) + 24,
                              child: route == null? const Center(
                                child: Text('Waiting for Route'),
                              ):RouteActivity(route: route!,),
                            )
                          ],
                        );
                      },
                      landscape: (ctx) {
                        return Row(
                          children: [
                            SizedBox(
                              width: (width / 2) - 64,
                              child: LiveOperations(
                                height: height,
                                width: width,
                                restart: restart,
                                elevation: 8.0,
                              ),
                            ),
                            SizedBox(
                              width: (width / 2) + 24,
                              child: route == null? const Center(
                                child: Text('Waiting for Route'),
                              ):RouteActivity(route: route!,),
                            ),
                          ],
                        );
                      },
                    );
                  },
                )),
              ],
            ),
          ),
          busy
              ? const Positioned(
                  child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      backgroundColor: Colors.red,
                    ),
                  ),
                ))
              : const SizedBox(),
        ],
      ),
    ));
  }

  void _showError(e) {
    pp('$mm ... error happened, mounted? $mounted ');
    if (mounted) {
      showSnackBar(
          backgroundColor: Colors.red.shade800,
          textStyle: const TextStyle(color: Colors.white),
          message: '$e',
          duration: const Duration(milliseconds: 10000),
          context: context);
    }
  }

  void _showSuccess(String e) {
    if (mounted) {
      showSnackBar(
          backgroundColor: Colors.teal.shade800,
          textStyle: const TextStyle(color: Colors.white),
          message: e,
          duration: const Duration(milliseconds: 2000),
          context: context);
    }
  }
}
