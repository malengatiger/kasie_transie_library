import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/tiny_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'calculated_distances_widget.dart';
import 'color_pad.dart';

class RouteInfoWidget extends StatefulWidget {
  const RouteInfoWidget(
      {super.key,
      required this.onClose,
      required this.onNavigateToMapViewer,
      required this.onColorChanged,
      required this.route});

  final lib.Route route;
  final Function onClose;
  final Function onNavigateToMapViewer;
  final Function(Color, String) onColorChanged;

  @override
  State<RouteInfoWidget> createState() => _RouteInfoWidgetState();
}

class _RouteInfoWidgetState extends State<RouteInfoWidget> {
  final mm = '😎😎😎😎😎😎😎😎 RouteInfoWidget: 🍎🍎🍎';
  var numberOfPoints = 0;
  var numberOfLandmarks = 0;
  late StreamSubscription<String> sub;
  Prefs prefs = GetIt.instance<Prefs>();

  bool busy = true;
  String routePointsMapped = '',
      routeLandmarks = '',
      distanceFromStart = '',
      routeDetails = '',
      routeColor = '',
      routeLength = '';

  @override
  void initState() {
    super.initState();
    pp('$mm initState ................... ');
    listen();
    _setTexts();
    _getData(widget.route.routeId!);
  }

  void _setTexts() async {
    final c = prefs.getColorAndLocale();
    final loc = c.locale;
    routePointsMapped = await translator.translate('routePointsMapped', loc);
    routeLandmarks = await translator.translate('routeLandmarks', loc);
    distanceFromStart = await translator.translate('distanceFromStart', loc);
    routeDetails = await translator.translate('routeDetails', loc);
    routeColor = await translator.translate('routeColor', loc);
    routeLength = await translator.translate('routeLength', loc);
  }

  void listen() {
    pp('$mm listen to routeStream .............');
    sub = tinyBloc.routeIdStream.listen((routeId) async {
      pp('$mm tinyBloc.routeIdStream delivered routeId: $routeId ');
      await _getData(routeId);

      if (mounted) {
        setState(() {});
      }
    });
  }

  SemCache semCache = GetIt.instance<SemCache>();

  Future _getData(String? routeId) async {
    pp('$mm _getData ..... numberOfLandmarks, '
        'numberOfPoints; routeId: $routeId ');

    if (mounted) {
      setState(() {
        busy = true;
      });
    }
    if (routeId != null) {
      var marks = await semCache.getRouteLandmarks(
          routeId, widget.route.associationId!);
      numberOfLandmarks = marks.length;
      var points =
          await semCache.getRoutePoints(routeId, widget.route.associationId!);
      numberOfPoints = points.length;
    }
    if (mounted) {
      setState(() {
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final type = getThisDeviceType();
    return Scaffold(
      appBar: AppBar(title: const Text('Route Information')),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: ScreenTypeLayout.builder(
              mobile: (ctx) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 64, horizontal: 100),
                      child: DetailsWidget(
                        route: widget.route,
                        numberOfLandmarks: numberOfLandmarks,
                        fontSize: 18,
                        numberOfPoints: numberOfPoints,
                        routeColor: routeColor,
                        routePointsMapped: routePointsMapped,
                        routeLandmarks: routeLandmarks,
                        routeDetails: routeDetails,
                        onClose: () {
                          widget.onClose();
                        },
                        onNavigateToMapViewer: () {
                          widget.onNavigateToMapViewer();
                        },
                        onColorChanged: (color, string) {
                          widget.onColorChanged(color, string);
                        },
                      ),
                    ),
                    Expanded(
                      child: Card(
                          shape: getDefaultRoundedBorder(),
                          elevation: 12,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 64, horizontal: 100),
                            child: CalculatedDistancesWidget(
                              routeId: widget.route.routeId!,
                              associationId: widget.route.associationId!,
                            ),
                          )),
                    ),
                  ],
                );
              },
              tablet: (_) {
                return Row(
                  children: [
                    SizedBox(
                        width: (width / 2) - 64,
                        child: Card(
                          elevation: 8,
                          shape: getDefaultRoundedBorder(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.all(64),
                                  child: DetailsWidget(
                                    route: widget.route,
                                    fontSize: 24,
                                    numberOfLandmarks: numberOfLandmarks,
                                    numberOfPoints: numberOfPoints,
                                    onClose: () {
                                      widget.onClose();
                                    },
                                    onNavigateToMapViewer: () {
                                      widget.onNavigateToMapViewer();
                                    },
                                    routeColor: routeColor,
                                    routeLandmarks: routeLandmarks,
                                    routePointsMapped: routePointsMapped,
                                    routeDetails: routeDetails,
                                    onColorChanged: (color, string) {
                                      widget.onColorChanged(color, string);
                                    },
                                  )),
                            ],
                          ),
                        )),
                    gapW32,
                    SizedBox(
                        width: (width / 2) - 64,
                        child: Card(
                            elevation: 8,
                            shape: getDefaultRoundedBorder(),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 64, horizontal: 100),
                                child: CalculatedDistancesWidget(
                                    associationId: widget.route.associationId!,
                                    routeId: widget.route.routeId!))))
                  ],
                );
              },
              desktop: (_) {
                return Row(
                  children: [
                    SizedBox(
                        width: (width / 2) - 64,
                        child: Card(
                          elevation: 8,
                          shape: getDefaultRoundedBorder(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.all(64),
                                  child: DetailsWidget(
                                    route: widget.route,
                                    fontSize: 24,
                                    numberOfLandmarks: numberOfLandmarks,
                                    numberOfPoints: numberOfPoints,
                                    onClose: () {
                                      widget.onClose();
                                    },
                                    onNavigateToMapViewer: () {
                                      widget.onNavigateToMapViewer();
                                    },
                                    routeColor: routeColor,
                                    routeLandmarks: routeLandmarks,
                                    routePointsMapped: routePointsMapped,
                                    routeDetails: routeDetails,
                                    onColorChanged: (color, string) {
                                      widget.onColorChanged(color, string);
                                    },
                                  )),
                            ],
                          ),
                        )),
                    gapW32,
                    SizedBox(
                        width: (width / 2) - 64,
                        child: Card(
                            elevation: 8,
                            shape: getDefaultRoundedBorder(),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 64, horizontal: 100),
                                child: CalculatedDistancesWidget(
                                    associationId: widget.route.associationId!,
                                    routeId: widget.route.routeId!))))
                  ],
                );
              },
            )),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header(
      {super.key,
      required this.onClose,
      required this.routeName,
      required this.fontSize,
      required this.routeDetails,
      required this.onNavigateToMapViewer});

  final Function onClose;
  final Function onNavigateToMapViewer;
  final String routeName;
  final double fontSize;

  final String routeDetails;

  @override
  Widget build(BuildContext context) {
    final type = getThisDeviceType();
    return Column(
      children: [
        SizedBox(
          height: type == 'phone' ? 4 : 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              routeDetails,
              style: myTextStyleMediumLargeWithColor(
                  context, Theme.of(context).primaryColorLight, fontSize),
            ),
            SizedBox(
              width: type == 'phone' ? 48 : 64,
            ),
          ],
        ),
        const SizedBox(
          height: 64,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            routeName,
            style: myTextStyleMediumLargeWithColor(
                context, Theme.of(context).primaryColor, fontSize),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}

class DetailsWidget extends StatelessWidget {
  const DetailsWidget(
      {super.key,
      required this.route,
      required this.numberOfLandmarks,
      required this.numberOfPoints,
      required this.onClose,
      required this.fontSize,
      required this.routeColor,
      required this.routeLandmarks,
      required this.routePointsMapped,
      required this.routeDetails,
      required this.onNavigateToMapViewer,
      required this.onColorChanged});

  final lib.Route route;
  final int numberOfLandmarks, numberOfPoints;
  final Function onClose;
  final double fontSize;
  final String routeColor, routeLandmarks, routePointsMapped, routeDetails;
  final Function onNavigateToMapViewer;
  final Function(Color, String) onColorChanged;
  final mm = '🍎🍎🍎🍎 DetailsWidget (RouteInfoWidget): 🔵🔵 ';

  void _showColorDialog(
    BuildContext context,
  ) {
    pp('show dialog ...');
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return ColorPad(
            onColorPicked: (color, stringColor) {
              onColorChanged(color, stringColor);
            },
            onClose: () {
              Navigator.of(context).pop();
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final type = getThisDeviceType();
    var fmt = NumberFormat('###,###,###,###');
    return Column(
      children: [
        gapH32,
        Icon(
          Icons.roundabout_right,
          size: 100,
          color: getColor(route.color!),
        ),
        gapH32,gapH32,
        Header(
          onClose: onClose,
          routeName: route.name!,
          fontSize: fontSize,
          routeDetails: routeDetails,
          onNavigateToMapViewer: () {
            onNavigateToMapViewer();
          },
        ),
        gapH32,
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Date Created:', style: myTextStyle(fontSize: 10),),
            gapW16,
            Text(getFormattedDateLong(route.created!)),
          ],
        ),
       gapH32,
        Text(
          '${route.userName}',
          style: myTextStyleMediumBoldGrey(context),
        ),
        SizedBox(
          height: type == 'phone' ? 24 : 80,
        ),
        gapH32,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              routeColor,
              style: myTextStyleMediumLarge(context, 24),
            ),
            const SizedBox(
              width: 8,
            ),
            GestureDetector(
              onTap: () {
                pp('..................... ... show color pad');
                _showColorDialog(context);
              },
              child: Card(
                shape: getRoundedBorder(radius: 8),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        color: getColor(route.color!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 64,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 80,
                width: type == 'phone' ? 140 : 160,
                child: Column(
                  children: [
                    Text(
                      numberOfLandmarks.toString(),
                      style: myTextStyleMediumLarge(context, 48),
                    ),
                    Text(
                      routeLandmarks,
                      style: myTextStyleMediumBoldGrey(context),
                    ),
                  ],
                )),
            SizedBox(
              width: type == 'phone' ? 12 : 24,
            ),
            SizedBox(
                height: 80,
                width: type == 'phone' ? 140 : 160,
                child: Column(
                  children: [
                    Text(
                      fmt.format(numberOfPoints),
                      style: myTextStyleMediumLarge(context, 48),
                    ),
                    Text(
                      routePointsMapped,
                      style: myTextStyleMediumBoldGrey(context),
                    ),
                  ],
                )),
          ],
        )
      ],
    );
  }
}
