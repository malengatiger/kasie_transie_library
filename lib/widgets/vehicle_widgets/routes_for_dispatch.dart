import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';

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
  int limit = 1;

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
    route = prefs.getRoute();
    try {
      if (user != null) {
        var routeData = await listApiDog.getAssociationRouteData(
            user!.associationId!, false);

        routes = await devLoc.getRouteDistances(
            routeData: routeData!, limitMetres: limit * 1000);
        // routes.sort((a, b) => a.name!.compareTo(b.name!));

        pp('$mm nearest routes: ${routes.length}');
      }
      if (route != null) {
        _showConfirmDialog();
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

  _showConfirmDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: SizedBox(
                height: 120,
                child: Column(children: [
                  const Text(
                      'Do you want to keep using the route that you used previously?'),
                  gapH8,
                  Text('${route!.name}'),
                ])),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      route = null;
                    });
                  },
                  child: const Text('No')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(route!);
                    _navigateToCarForDispatch();
                  },
                  child: const Text('Yes')),
            ],
          );
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<lib.DispatchRecord> dispatches = [];

  _navigateToCarForDispatch() async {
    prefs.saveRoute(route!);
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
                      InkWell(
                        onTap: () {
                          if (route != null) {
                            _navigateToCarForDispatch();
                          }
                        },
                        child: Text(
                            route == null ? 'Select Route for Dispatch' : route!.name!,
                            style: myTextStyleMediumLarge(context, 20)),
                      ),
                      gapH32,
                      Row(
                        children: [
                          const Text('Search Radius in KM'),
                          gapW32,
                          DropdownButton<int>(
                              dropdownColor: Colors.white,
                              items: const [
                                DropdownMenuItem<int>(
                                    value: 1, child: Text('1')),
                                DropdownMenuItem<int>(
                                    value: 2, child: Text('2')),
                                DropdownMenuItem<int>(
                                    value: 3, child: Text('3')),
                                DropdownMenuItem<int>(
                                    value: 4, child: Text('4')),
                                DropdownMenuItem<int>(
                                    value: 5, child: Text('5')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    limit = value ;
                                  });
                                  _getRouteData();
                                }
                              }),
                          gapW32,
                          Text(
                            '$limit km',
                            style: myTextStyle(
                                weight: FontWeight.w900, color: Colors.red),
                          )
                        ],
                      ),
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
                                              vertical: 2),
                                          child: Card(
                                            elevation: 8,
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                        width: 24,
                                                        child: Text(
                                                          '${index + 1}',
                                                          style: myTextStyle(
                                                              weight: FontWeight
                                                                  .w900,
                                                              color:
                                                                  Colors.pink),
                                                        )),
                                                    Flexible(
                                                      child: Text(
                                                        r.name!,
                                                        style: myTextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    )
                                                  ],
                                                )),
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
