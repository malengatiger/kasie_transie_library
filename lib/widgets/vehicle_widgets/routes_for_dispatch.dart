import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:page_transition/page_transition.dart';

import '../../data/route_data.dart';
import '../../utils/functions.dart';
import '../../utils/navigator_utils.dart';
import '../../utils/prefs.dart';
import 'cars_for_dispatch.dart';

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
  DeviceLocationBloc devLoc = GetIt.instance<DeviceLocationBloc>();
  List<lib.Route> routes = [];
  lib.Route? route;
  bool busy = false;
  lib.User? user;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getRouteData();
  }

  List<DistanceBag> distanceBags = [];
  static const mm = '🧡🧡🧡🧡RoutesForDispatch 🧡';

  _getRouteData() async {
    setState(() {
      busy = true;
    });
    user = prefs.getUser();
    try {
      if (user != null) {
        var routeData = await listApiDog.getAssociationRouteData(
            user!.associationId!, false);
        routes = await devLoc.getRouteDistances(routeData: routeData!);
        routes.sort((a, b) => a.name!.compareTo(b.name!));

        pp('$mm nearest routes: ${routes.length}');
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

  _navigateToCarForDispatch() async {
    NavigationUtils.navigateTo(
        context: context,
        widget: CarForDispatch(
          route: route!,
        ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Routes For Dispatch', style: myTextStyleMedium(context)),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      gapH32,
                      gapH32,
                      InkWell(
                        onTap: () {
                          if (route != null) {
                            _navigateToCarForDispatch();
                          }
                        },
                        child: Text(
                            route == null ? 'Select Route' : route!.name!,
                            style: myTextStyleMediumLarge(context, 20)),
                      ),
                      gapH32,
                      gapH32,
                      routes.isEmpty
                          ? Center(
                              child: Text(
                              'No routes yet',
                              style: myTextStyleLarge(context),
                            ))
                          : Expanded(
                              child: bd.Badge(
                                badgeContent: Text(
                                  '${routes.length}',
                                  style: myTextStyle(color: Colors.white),
                                ),
                                badgeStyle: const bd.BadgeStyle(
                                    padding: EdgeInsets.all(16),
                                    badgeColor: Colors.red),
                                position:
                                    bd.BadgePosition.topEnd(top: -48, end: 6),
                                child: ListView.builder(
                                    itemCount: routes.length,
                                    itemBuilder: (ctx, index) {
                                      var r = routes[index];
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            route = r;
                                          });
                                          _navigateToCarForDispatch();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Card(
                                            elevation: 8,
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                r.name!,
                                                style:
                                                    myTextStyle(fontSize: 18),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                      gapH32,
                    ],
                  )),
              busy
                  ? const Positioned(
                      child: Center(
                          child: TimerWidget(
                              title: 'Loading Route data ...',
                              isSmallSize: true)),
                    )
                  : gapW32,
            ],
          ),
        ));
  }
}