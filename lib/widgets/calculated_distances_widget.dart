import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as bd;
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:kasie_transie_library/widgets/tiny_bloc.dart';

import '../bloc/sem_cache.dart';
import '../l10n/translation_handler.dart';
import '../utils/prefs.dart';
import '../utils/route_distance_calculator.dart';

class CalculatedDistancesWidget extends StatefulWidget {
  const CalculatedDistancesWidget(
      {super.key, required this.routeId, required this.associationId});

  final String routeId, associationId;

  @override
  CalculatedDistancesWidgetState createState() =>
      CalculatedDistancesWidgetState();
}

class CalculatedDistancesWidgetState extends State<CalculatedDistancesWidget>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  late StreamSubscription<String> sub;
  final mm = '😎😎😎😎😎😎😎😎 CalculatedDistancesWidget: 🍎🍎🍎';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

  var calculatedDistances = <lib.CalculatedDistance>[];
  bool busy = false;
  lib.Route? route;
  String distanceFromStart = '', routeLength = '';

  RouteDistanceCalculator routeDistanceCalculator =
      GetIt.instance<RouteDistanceCalculator>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    listen();
    _getData(false);
  }

  void _setTexts() async {
    final c = prefs.getColorAndLocale();
    final loc = c.locale;
    distanceFromStart = await translator.translate('distanceFromStart', loc);
    routeLength = await translator.translate('routeLength', loc);
  }

  void listen() {
    pp('$mm listen to routeStream .............');
    sub = tinyBloc.routeIdStream.listen((routeId) async {
      pp('$mm tinyBloc.routeIdStream delivered routeId: $routeId ');
      _getData(false);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double total = 0.0;
  SemCache semCache = GetIt.instance<SemCache>();

  void _getData(bool refresh) async {
    pp('$mm ... getting data ...');
    if (mounted) {
      setState(() {
        busy = true;
        calculatedDistances.clear();
      });
    }
    try {
      route = await semCache.getRoute(widget.routeId, widget.associationId);
      if (refresh) {
        calculatedDistances = await routeDistanceCalculator
            .calculateRouteDistances(widget.routeId, route!.associationId!);
      } else {
        calculatedDistances = await listApiDog.getCalculatedDistances(
            widget.routeId, route!.associationId!, false);
      }
      total = await routeDistanceCalculator.calculateRouteLengthInKM(
          widget.routeId, widget.associationId);
      if (mounted) {
        showOKToast(message: 'Route distances calculated', context: context);
      }
    } catch (e, stack) {
      pp('$mm $e - $stack');
    }
    if (mounted) {
      setState(() {
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final fmt = NumberFormat.decimalPattern();
    final type = getThisDeviceType();
    return busy
        ? const Center(
            child: TimerWidget(title: 'Calculating ...', isSmallSize: true))
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: type == 'phone' ? 0 : 8,
                ),
                GestureDetector(
                  onTap: () {
                    _getData(true);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        routeLength,
                        style: myTextStyleMediumLarge(context, 20),
                      ),
                     gapW32,
                      Text(
                        fmt.format(total),
                        style: myTextStyleMediumLargeWithColor(
                            context,
                            Theme.of(context).primaryColor,
                            type == 'phone' ? 16 : 36),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Text('km'),
                    ],
                  ),
                ),
                gapH32,
                gapH32,
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _getData(true);
                    },
                    child: bd.Badge(
                      badgeContent: Text('${calculatedDistances.length}',
                          style: const TextStyle(color: Colors.white)),
                      position: bd.BadgePosition.topEnd(top: 8, end: -8),
                      badgeStyle: const bd.BadgeStyle(
                          padding: EdgeInsets.all(8.0),
                          badgeColor: Colors.indigo),
                      child: ListView.builder(
                          itemCount: calculatedDistances.length,
                          itemBuilder: (ctx, index) {
                            final d = calculatedDistances.elementAt(index);
                            final dist1 =
                                (d.distanceInMetres! / 1000).toStringAsFixed(2);
                            final dist2 = (d.distanceFromStart!.round() / 1000)
                                .toStringAsFixed(2);
                            fmt.format;

                            return Card(
                              shape: getRoundedBorder(radius: 12),
                              elevation: 8,
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Text(
                                      '$dist1 km',
                                      style: myTextStyleSmallBold(context),
                                    ),
                                    gapW16,
                                    Flexible(
                                        child: Text(
                                      '${d.fromLandmark} - ${d.toLandmark}',
                                      style: myTextStyle(
                                          fontSize: 20,
                                          color: Theme.of(context).primaryColor,
                                          weight: FontWeight.w900),
                                    )),
                                  ],
                                ),
                                subtitle: Text(
                                  '$dist2 km $distanceFromStart',
                                  style: myTextStyleTiny(context),
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                ),
              ],
            ));
  }

  @override
  bool get wantKeepAlive => true;
}
