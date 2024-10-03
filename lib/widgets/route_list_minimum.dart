import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:badges/badges.dart' as bd;
import 'package:kasie_transie_library/widgets/timer_widget.dart';

import '../isolates/routes_isolate.dart';
import '../l10n/translation_handler.dart';

class RouteListMinimum extends StatefulWidget {
  final Function(lib.Route) onRoutePicked;
  final lib.Association association;
  final bool isMappable;
  const RouteListMinimum({
    super.key,
    required this.onRoutePicked, required this.association, required this.isMappable,
  });

  @override
  RouteListMinimumState createState() => RouteListMinimumState();
}

class RouteListMinimumState extends State<RouteListMinimum>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  late AnimationController _controller;
  static const mm = '🔷🔷🔷🔷😡😡😡 RouteListMinimum: 🔷🔷';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  var routes = <lib.Route>[];
  bool busy = false;
  late StreamSubscription<List<lib.Route>> _sub;
  lib.User? user;
  String routesList = '';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _setTexts();
    _getRoutes(false);
  }

  void _setTexts() async {
    final c = prefs.getColorAndLocale();
    final loc = c.locale;
    routesList = await translator.translate('routesList', loc);
  }

  void _listen() async {
    _sub = listApiDog.routeStream.listen((event) {
      routes = event;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future _getRoutes(bool refresh) async {
    pp('$mm _getRoutes ....');
    try {
      setState(() {
        busy = true;
      });
      user = prefs.getUser();
      var routesIsolate = GetIt.instance<RoutesIsolate>();

      if (refresh) {
        var list = await routesIsolate.getRoutes(widget.association.associationId!, true);
      } else {
        if (widget.isMappable) {
          routes = await routesIsolate.getRoutesMappable(
              widget.association.associationId!, refresh);
        } else {
        routes = await listApiDog
            .getRoutes(widget.association.associationId!, refresh);
        }
      }
      routes.sort((a,b) => a.name!.compareTo(b.name!));
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
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: const Text('Route Picker'),
      ),
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
                  style: myTextStyleMediumPrimaryColor(context),
                ),
                const SizedBox(
                  height: 24,
                ),
                Expanded(
                    child: bd.Badge(
                      position: bd.BadgePosition.topEnd(end: 12),
                      badgeStyle: const bd.BadgeStyle(
                        padding: EdgeInsets.all(12),
                        badgeColor: Colors.indigo,
                      ),
                      badgeContent: Text('${routes.length}'),
                      child: ListView.builder(
                          itemCount: routes.length,
                          itemBuilder: (ctx, index) {
                            final r = routes.elementAt(index);
                            return GestureDetector(
                              onTap: (){
                                widget.onRoutePicked(r);
                              },
                              child: Card(
                                shape: getDefaultRoundedBorder(),
                                elevation: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    '${r.name}',
                                    style: myTextStyleSmall(context),
                                  ),
                                ),
                              ),
                            );
                          }),
                    )),
              ],
            ),
          ),
          busy? const Positioned(child: Center(
            child: TimerWidget(title: 'Loading Routes', isSmallSize: false,),
          )): gapH16,
        ],
      )
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
