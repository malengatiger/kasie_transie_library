import 'dart:async';

import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';

import '../bloc/sem_cache.dart';
import '../l10n/translation_handler.dart';

class RouteListMinimum extends StatefulWidget {
  final Function(lib.Route) onRoutePicked;
  final lib.Association association;
  final bool isMappable;

  const RouteListMinimum({
    super.key,
    required this.onRoutePicked,
    required this.association,
    required this.isMappable,
  });

  @override
  RouteListMinimumState createState() => RouteListMinimumState();
}

class RouteListMinimumState extends State<RouteListMinimum>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  static const mm = '🔷🔷🔷🔷😡😡😡 RouteListMinimum: 🔷🔷';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  var routes = <lib.Route>[];
  bool busy = false;
  lib.User? user;
  String routesList = '';
  SemCache semCache = GetIt.instance<SemCache>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _setTexts();
    _getRoutes();
  }

  void _setTexts() async {
    final c = prefs.getColorAndLocale();
    final loc = c.locale;
    routesList = await translator.translate('routesList', loc);
  }

  void _listen() async {}

  Future _getRoutes() async {
    pp('$mm _getRoutes from cache ....');
    setState(() {
      busy = true;
    });
    try {
      routes = await semCache.getRoutes(associationId: widget.association.associationId!);
      routes.sort((a, b) => a.name!.compareTo(b.name!));
      pp('$mm ... found ${routes.length}');
    } catch (e) {
      pp(e);
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
    super.build(context);
    return SafeArea(
        child: Scaffold(
            // appBar: AppBar(
            //   title: const Text('Route Picker'),
            // ),
            body: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(
                height: 24,
              ),
              Text(
                '${widget.association.associationName}',
                style: myTextStyleMediumLargeWithColor(
                    context, Theme.of(context).primaryColor, 24),
              ),
              const SizedBox(
                height: 24,
              ),
              Text(
                'Taxi Routes',
                style: myTextStyleMediumLarge(context, 18),
              ),
              gapH32,
              Expanded(
                  child: bd.Badge(
                position: bd.BadgePosition.topEnd(end: 12),
                badgeStyle: const bd.BadgeStyle(
                  padding: EdgeInsets.all(12),
                  badgeColor: Colors.indigo,
                ),
                badgeContent: Text('${routes.length}',
                    style: const TextStyle(color: Colors.white)),
                child: StreamBuilder<List<lib.Route>>(
                    stream: listApiDog.routeStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        pp('$mm snapshot has routes: ${snapshot.data!.length}');
                        routes = snapshot.data!;
                        routes.sort((a, b) => a.name!.compareTo(b.name!));
                        pp('$mm routes has: ${routes.length} - should show up!!!!');

                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 24, horizontal: 64.0),
                        child: ListView.builder(
                            itemCount: routes.length,
                            itemBuilder: (ctx, index) {
                              final route = routes.elementAt(index);
                              return GestureDetector(
                                onTap: () {
                                  widget.onRoutePicked(route);
                                },
                                child: Card(
                                  shape: getDefaultRoundedBorder(),
                                  elevation: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ListTile(
                                      leading: Container(
                                        color: getColor(route.color!),
                                        width: 24,
                                        height: 24, child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: myTextStyleMediumLargeWithColor(
                                              context,
                                              route.color == 'white'? Colors.black:Colors.white,
                                              14),
                                        ),
                                      ),
                                      ),
                                      title: Text(
                                        '${route.name}',
                                        style:
                                            myTextStyleMediumLarge(context, 15),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      );
                    }),
              )),
            ],
          ),
        ),
        busy
            ? const Positioned(
                child: Center(
                child: TimerWidget(
                  title: 'Loading Routes',
                  isSmallSize: false,
                ),
              ))
            : gapH16,
      ],
    )));
  }

  @override
  bool get wantKeepAlive => true;
}
