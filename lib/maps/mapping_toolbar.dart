import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/route_point_list.dart';
import 'package:kasie_transie_library/widgets/color_pad.dart';

import '../data/data_schemas.dart';
import '../utils/functions.dart';

class MappingToolbar extends StatefulWidget {
  const MappingToolbar(
      {super.key,
      required this.routeId,
      required this.routePoints,
      required this.onRefresh, required this.onColorUpdated});

  final String routeId;
  final List<RoutePoint> routePoints;
  final Function onRefresh;
  final Function(String) onColorUpdated;

  @override
  MappingToolbarState createState() => MappingToolbarState();
}

class MappingToolbarState extends State<MappingToolbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  bool busy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const mm = '🌺🌺🌺 MappingToolbar 🌺';

  _updateColor(Color color, String stringColor) async {
    setState(() {
      busy = true;
    });
    try {
      var res = await dataApiDog.updateRouteColor(
          routeId: widget.routeId, color: stringColor);
      widget.onColorUpdated(stringColor);
    } catch (e, s) {
      pp("$e \n$s");
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  _deleteLastPoints() async {
    setState(() {
      busy = true;
    });
    pp('\n\n$mm delete last 5 points from ${widget.routePoints.length} ...');
    try {
      List<RoutePoint> routePoints = getLastFiveRoutePoints(widget.routePoints);
      pp('$mm points to delete: ${routePoints.length} ...');
      if (routePoints.isEmpty) {
        showToast(message: 'No route points to delete', context: context);
      } else {
        var routePointList = RoutePointList(routePoints);
        var res = await dataApiDog.deleteRoutePointList(routePointList);
        widget.onRefresh();
      }
    } catch (e, s) {
      pp("$e \n$s");
      if (mounted) {
        showErrorToast(message: 'Delete points failed: \n$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  _deleteAllPoints() async {
    setState(() {
      busy = true;
    });
    pp('$mm delete all route points ...');

    try {
      var res = await dataApiDog.deleteAllRoutePoints(widget.routeId);
      widget.onRefresh();
    } catch (e, s) {
      pp("$e \n$s");
      if (mounted) {
        showErrorToast(message: 'Delete all points failed.\n$e', context: context);
      }
    }

    setState(() {
      busy = false;
    });
  }

  List<RoutePoint> getLastFiveRoutePoints(List<RoutePoint> routePoints) {
    if (routePoints.length >= 5) {
      return routePoints.sublist(routePoints.length - 5);
    } else {
      return routePoints;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Card(
        elevation: 8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                        ),
                      )
                    : gapW4,
                gapW32,
                IconButton(
                    tooltip: 'Delete last few route points',
                    onPressed: () {
                      _deleteLastPoints();
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.amber,
                    )),
                gapW32,
                IconButton(
                    tooltip: 'Delete ALL the route points',
                    onPressed: () {
                      _deleteAllPoints();
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    )),
                gapW32,
                IconButton(
                    tooltip: 'Refresh the route data',
                    onPressed: () {
                      widget.onRefresh();
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    )),
                gapW32,
                gapW32,
                ColorPad(
                    onColorPicked: (color, stringColor) {
                      pp('color picked: $stringColor');
                      _updateColor(color, stringColor);
                    },
                    onClose: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
