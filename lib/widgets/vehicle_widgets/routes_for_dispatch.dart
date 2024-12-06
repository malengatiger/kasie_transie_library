import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:page_transition/page_transition.dart';

import '../../data/route_data.dart';
import '../../utils/functions.dart';
import '../../utils/navigator_utils.dart';
import '../../utils/prefs.dart';
import '../scanners/dispatch_via_scan.dart';
import 'package:badges/badges.dart' as bd;

class RoutesForDispatch extends StatefulWidget {
  const RoutesForDispatch({super.key});

  @override
  RoutesForDispatchState createState() => RoutesForDispatchState();
}

class RoutesForDispatchState extends State<RoutesForDispatch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  AssociationRouteData? routeData;
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

  List<lib.Route> routes = [];
  lib.Route? route;
  bool busy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getRouteData();
  }

  _getRouteData() async {
    setState(() {
      busy = true;
    });
    var user = prefs.getUser();
    try {
      if (user != null) {
        routeData = await listApiDog.getAssociationRouteData(
            user!.associationId!, false);
        for (var rd in routeData!.routeDataList) {
          if (rd.route != null && rd.routePoints.isNotEmpty) {
            routes.add(rd.route!);
          }
        }
        routes.sort((a,b) => a.name!.compareTo(b.name!));
      }
    } catch (e, s) {
      pp('$e $s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<lib.DispatchRecord> dispatches = [];

  _navigateToDispatchScan() async {
    NavigationUtils.navigateTo(
        context: context,
        widget: DispatchViaScan(
          route: route!,
          onDispatched: (dr) {
            dispatches.add(dr);
            setState(() {});
          },
        ),
        transitionType: PageTransitionType.leftToRight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:  Text('Routes For Dispatch', style: myTextStyleMedium(context)),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(route == null ? 'Select Route' : route!.name!,
                          style: myTextStyleMediumLarge(context, 24)),
                      gapH32,
                      routes.isEmpty
                          ? gapW32
                          : Expanded(
                              child: bd.Badge(
                                badgeContent: Text('${routes.length}'),
                                badgeStyle: const bd.BadgeStyle(
                                    padding: EdgeInsets.all(8),
                                    badgeColor: Colors.red),
                                child: ListView.builder(
                                    itemCount: routes.length,
                                    itemBuilder: (ctx, index) {
                                      var r = routes[index];
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            route = r;
                                          });
                                          _navigateToDispatchScan();
                                        },
                                        child: Card(
                                          elevation: 8,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              r.name!,
                                              style: myTextStyle(fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                    ],
                  )),
            ],
          ),
        ));
  }
}
