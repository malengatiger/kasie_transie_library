import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:responsive_builder/responsive_builder.dart';

class RoutePointDeletion extends StatefulWidget {
  const RoutePointDeletion(
      {super.key, required this.routeId, required this.onDeletionComplete, required this.associationId});

  final String routeId;
  final String associationId;
  final Function() onDeletionComplete;

  @override
  RoutePointDeletionState createState() => RoutePointDeletionState();
}

class RoutePointDeletionState extends State<RoutePointDeletion> {
  List<RoutePoint> points = [];
  List<RoutePoint> bottomPoints = [];

  SemCache semCache = GetIt.instance<SemCache>();

  @override
  void initState() {
    super.initState();
    _getPoints();
  }

  _getPoints() async {
    points = await semCache.getRoutePoints(widget.routeId, widget.associationId);
    points.sort((a, b) => a.index!.compareTo(b.index!));
    const max = 12;

    if (points.length <  20) {
      bottomPoints = points;
      setState(() {});
      return;
    }

    int end = points.length - 1;
    int start = end - 12;
    bottomPoints = points.sublist(start, end);
    setState(() {});
  }

  DataApiDog api = GetIt.instance<DataApiDog>();

  _confirmDeletion(RoutePoint point) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Deletion Confirmation'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                    'Do you want delete route points starting with this index?'),
                gapW8,
                Text(
                  '${point.index}',
                  style: myTextStyleMediumLargeWithColor(context, Colors.red, 20),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _delete(point);
                  },
                  child: const Text('Delete')),
            ],
          );
        });
  }

  bool busy = false;
  static const mm = '🔶🔶🔶🔶 RoutePointDeletion 🔶';

  _delete(RoutePoint point) async {
    setState(() {
      busy = true;
    });
    pp('$mm ........... delete starting ...');
    try {
      var routePoints =
          await api.deleteRoutePointsFromIndex(point.routeId!, point.index!, widget.associationId);
      pp('$mm .... delete done, 🍎 points remaining: ${routePoints.length}');
    } catch (e) {
      pp(e);
      if (mounted) {
        showErrorSnackBar(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Point Deletion'),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(64), child: Column()),
      ),
      body: SafeArea(
        child: ScreenTypeLayout.builder(
          mobile: (_) {
            return DeletionList(
                bottomPoints: bottomPoints,
                onRoutePointPicked: (rp) {
                  _confirmDeletion(rp);
                });
          },
          tablet: (_) {
            return Row(
              children: [
                SizedBox(
                  width: (width / 2) - 16,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                    child: DeletionList(
                        bottomPoints: bottomPoints,
                        onRoutePointPicked: (rp) {
                          _confirmDeletion(rp);
                        }),
                  ),
                ),
                SizedBox(
                  width: (width / 2) - 16,
                  child: Container(color: Colors.red),
                ),
              ],
            );
          },
          desktop: (_) {
            return Row(
              children: [
                SizedBox(
                  width: (width / 2) - 16,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                    child: DeletionList(
                        bottomPoints: bottomPoints,
                        onRoutePointPicked: (rp) {
                          _confirmDeletion(rp);
                        }),
                  ),
                ),
                SizedBox(
                  width: (width / 2) - 16,
                  child: Container(color: Colors.red),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

final List<String> assetPaths = [
  'assets/images/1.jpg',
  'assets/images/2.jpg',
  'assets/images/3.jpg',
  'assets/images/4.jpg',
  'assets/images/5.jpg',
  'assets/images/6.jpg',
  'assets/images/7.jpg',
  'assets/images/8.jpg',
  'assets/images/9.jpg',
  'assets/images/10.jpg',
];

class DeletionList extends StatelessWidget {
  const DeletionList(
      {super.key,
      required this.bottomPoints,
      required this.onRoutePointPicked});

  final List<RoutePoint> bottomPoints;
  final Function(RoutePoint) onRoutePointPicked;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bottomPoints.length,
      itemBuilder: (_, index) {
        var point = bottomPoints[index];
        return GestureDetector(
            onTap: () {
              onRoutePointPicked(point);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Card(
                elevation: 8,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Index'),
                      gapW4,
                      Text(
                        '${point.index}',
                        style: myTextStyleMediumBoldWithColor(
                            context: context,
                            color: Colors.yellow,
                            fontSize: 20),
                      ),
                      gapW32,
                      Text(point.position!.coordinates[1].toStringAsFixed(5)),
                      gapW8,
                      Text(point.position!.coordinates[0].toStringAsFixed(5)),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }
}
