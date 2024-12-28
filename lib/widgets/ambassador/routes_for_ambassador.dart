import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../../data/route_data.dart';
import '../../utils/functions.dart';
import '../../utils/navigator_utils.dart';
import '../../utils/prefs.dart';

class NearestRoutesList extends StatefulWidget {
  const NearestRoutesList(
      {super.key, required this.associationId, required this.title});
  final String associationId, title;

  @override
  NearestRoutesListState createState() => NearestRoutesListState();
}

class NearestRoutesListState extends State<NearestRoutesList>
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
  int limit = 3;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _signIn();
  }

  List<DistanceBag> distanceBags = [];
  static const mm = '🧡🧡🧡🧡 NearestRoutesList 🧡';
  _signIn() async {
    user = prefs.getUser();
    if (user != null) {
      var u = await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: user!.email!, password: user!.password!);
      if (u.user != null) {
        pp('$mm user has signed in');
        _getRouteData(false);
      }
    }
  }

  _getRouteData(bool refresh) async {
    setState(() {
      busy = true;
    });
    try {
      var routeData = await listApiDog.getAssociationRouteData(
          widget.associationId, refresh);

      routes = await devLoc.getRouteDistances(
          routeData: routeData!, limitMetres: limit * 1000);

      pp('$mm nearest routes: ${routes.length}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.title, style: myTextStyleMedium(context)),
            actions: [
              IconButton(
                  onPressed: () {
                    limit = 5;
                    _getRouteData(true);
                  },
                  icon: const FaIcon(FontAwesomeIcons.arrowsRotate))
            ]),
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
                          // if (route != null) {
                          //   _navigateToCarForDispatch();
                          // }
                        },
                        child: Text(
                            route == null ? 'Select Route' : route!.name!,
                            style: myTextStyleMediumLarge(context, 20)),
                      ),
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
                                    limit = value;
                                  });
                                  _getRouteData(true);
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
                      gapH32,
                      routes.isEmpty
                          ? Center(
                              child: Text(
                              'Finding routes in your current vicinity',
                              style: myTextStyle(
                                  fontSize: 16, weight: FontWeight.w400),
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
                                          Navigator.of(context).pop(route);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Card(
                                            elevation: 8,
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(children: [
                                                SizedBox(
                                                    width: 24,
                                                    child: Text(
                                                      '${index + 1}',
                                                      style: myTextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 12,
                                                          weight:
                                                              FontWeight.w900),
                                                    )),
                                                Flexible(
                                                  child: Text(
                                                    r.name!,
                                                    style: myTextStyle(
                                                        fontSize: 15),
                                                  ),
                                                ),
                                              ]),
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
