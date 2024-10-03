import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
      required this.routeId,
      required this.onClose,
      required this.onNavigateToMapViewer,
      required this.onColorChanged});
  final String? routeId;
  final Function onClose;
  final Function onNavigateToMapViewer;
  final Function(Color, String) onColorChanged;

  @override
  State<RouteInfoWidget> createState() => _RouteInfoWidgetState();
}

class _RouteInfoWidgetState extends State<RouteInfoWidget> {
  lib.Route? route;
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
    _getData(widget.routeId);
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

  Future _getData(String? routeId) async {
    pp('$mm _getData ..... numberOfLandmarks, '
        'numberOfPoints; routeId: $routeId ');

    if (mounted) {
      setState(() {
        busy = true;
      });
    }
    if (routeId != null) {
      numberOfLandmarks = await tinyBloc.getNumberOfLandmarks(routeId);
      numberOfPoints = await tinyBloc.getNumberOfPoints(routeId);
      route = await tinyBloc.getRoute(routeId);
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
    return route == null
        ? Center(
            child: Text(
              'Waiting for Godot',
              style: myTextStyleMediumBoldGrey(context),
            ),
          )
        : Card(
            shape: getDefaultRoundedBorder(),
            elevation: 8,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ScreenTypeLayout.builder(
                  mobile: (ctx) {
                    return Column(
                      children: [
                        route == null
                            ? const SizedBox()
                            : DetailsWidget(
                                route: route!,
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
                        Expanded(
                          child: Card(
                            shape: getDefaultRoundedBorder(),
                            elevation: 12,
                            child: CalculatedDistancesWidget(
                                routeId: widget.routeId!),
                          ),
                        ),
                      ],
                    );
                  },
                  tablet: (ctx) {
                    return OrientationLayoutBuilder(
                      portrait: (ctx) {
                        return Column(
                          children: [
                            route == null
                                ? const SizedBox()
                                : DetailsWidget(
                                    route: route!,
                                    fontSize: 16,
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
                                  ),
                            widget.routeId == null
                                ? const SizedBox()
                                : Expanded(
                                    child: Card(
                                      shape: getDefaultRoundedBorder(),
                                      elevation: 12,
                                      child: CalculatedDistancesWidget(
                                          routeId: widget.routeId!),
                                    ),
                                  ),
                          ],
                        );
                      },
                      landscape: (ctx) {
                        return SizedBox(
                          height: height,
                          child: Column(
                            children: [
                              route == null
                                  ? const SizedBox()
                                  : DetailsWidget(
                                      route: route!,
                                      fontSize: 16,
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
                                    ),
                              widget.routeId == null
                                  ? const SizedBox()
                                  : Expanded(
                                      child: Card(
                                        shape: getDefaultRoundedBorder(),
                                        elevation: 12,
                                        child: CalculatedDistancesWidget(
                                            routeId: widget.routeId!),
                                      ),
                                    ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                )),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      onNavigateToMapViewer();
                    },
                    icon: const Icon(Icons.map)),
                type == 'phone'
                    ? IconButton(
                        onPressed: () {
                          onClose();
                        },
                        icon: const Icon(Icons.close))
                    : gapH16,
              ],
            )
          ],
        ),
        const SizedBox(
          height: 12,
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
          return ColorPad(onColorPicked: (color, stringColor) {
            onColorChanged(color, stringColor);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final type = getThisDeviceType();
    return Column(
      children: [
        Header(
          onClose: onClose,
          routeName: route.name!,
          fontSize: fontSize,
          routeDetails: routeDetails,
          onNavigateToMapViewer: () {
            onNavigateToMapViewer();
          },
        ),
        Text(getFormattedDateLong(route.created!)),
        const SizedBox(
          height: 8,
        ),
        Text(
          '${route.userName}',
          style: myTextStyleMediumBoldGrey(context),
        ),
        SizedBox(
          height: type == 'phone' ? 24 : 48,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              routeColor,
              style: myTextStyleSmall(context),
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
                        width: 32,
                        height: 32,
                        color: getColor(route.color!),
                      ),
                      Icon(
                        Icons.route,
                        size: 32,
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
          height: 28,
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
                      style: myNumberStyleLarge(context),
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
                      numberOfPoints.toString(),
                      style: myNumberStyleLarge(context),
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
