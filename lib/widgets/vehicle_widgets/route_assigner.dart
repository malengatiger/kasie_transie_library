import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/route_assignment_list.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/widgets/route_widgets/multi_route_chooser.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:kasie_transie_library/widgets/vehicle_widgets/multi_vehicle_chooser.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:badges/badges.dart' as bd;
import '../../bloc/sem_cache.dart';
import '../../data/data_schemas.dart' as lib;
import '../../utils/prefs.dart';

///manage route assignments for multiple cars
class RouteAssigner extends StatefulWidget {
  const RouteAssigner({
    super.key,
    this.associationId,
  });

  final String? associationId;

  @override
  State<RouteAssigner> createState() => _RouteAssignerState();
}

class _RouteAssignerState extends State<RouteAssigner>
    with AutomaticKeepAliveClientMixin {
  static const mm = '🔷🔷🔷 RouteAssigner';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();

  List<lib.Route> routes = [];
  List<lib.Vehicle> cars = [];
  lib.Route? routePicked;
  List<lib.Vehicle> carsPicked = [];
  var routesPicked = <lib.Route>[];
  bool busy = false;
  SemCache semCache = GetIt.instance<SemCache>();

  @override
  void initState() {
    super.initState();
    _control();
  }

  void _control() async {
    setState(() {
      busy = true;
    });
    try {
      await _getRoutes();
      await _getCars();
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(message: 'Error: $e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  Future _getRoutes() async {
    pp('$mm ................................... _getRoutes ......');
    final user = prefs.getUser();
    routes = await semCache.getRoutes(associationId:user!.associationId!);
    pp('$mm ... _getRoutes ...... ${routes.length} routes found');
  }

  Future _getCars() async {
    pp('$mm ..................................... _getCars ......');
    final user = prefs.getUser();
    if (widget.associationId != null) {
      cars =
          await semCache.getVehicles(widget.associationId!);
    } else {
      cars = await listApiDog.getOwnerVehicles(user!.userId!, false);
    }
    pp('$mm ... _getCars ...... found:  ${cars.length} ... set state');
  }

  void submitAssignments() async {
    pp('$mm ... submitAssignments ...');
    if (routesPicked.isEmpty) {
      showToast(
          backgroundColor: Colors.black,
          textStyle: const TextStyle(
            color: Colors.white,
          ),
          padding: 24,
          message: 'Please select routes',
          context: context);
      return;
    }
    if (carsPicked.isEmpty) {
      showToast(
          backgroundColor: Colors.black,
          textStyle: const TextStyle(
            color: Colors.white,
          ),
          padding: 24,
          message: 'Please select vehicles',
          context: context);
      return;
    }
    setState(() {
      busy = true;
    });
    try {
      final List<lib.RouteAssignment> list = [];
      for (var car in carsPicked) {
        for (var route in routesPicked) {
          list.add(lib.RouteAssignment(
            routeId: route.routeId,
            created: DateTime.now().toUtc().toIso8601String(),
            active: 0,
            associationId: route.associationId,
            associationName: route.associationName,
            routeName: route.name,
            vehicleReg: car.vehicleReg,
            vehicleId: car.vehicleId,
          ));
        }
      }
      final RouteAssignmentList ral = RouteAssignmentList(assignments: list);
      final results = await dataApiDog.addRouteAssignments(ral);
      pp('$mm ... route assignments added to database: ${results.length}');
      if (mounted) {
        showSnackBar(
            backgroundColor: Colors.teal,
            textStyle: const TextStyle(color: Colors.white),
            message:
                '${carsPicked.length} cars have been assigned to ${routesPicked.length} routes',
            context: context);
      }
      //
      carsPicked.clear();
      routesPicked.clear();
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(
            backgroundColor: Colors.pink,
            textStyle: const TextStyle(color: Colors.white),
            message: 'Route assignments failed: $e',
            context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  void _displayCarsDialog() {
    pp('$mm ... _displayCarsDialog ...');
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            icon: const Icon(Icons.airport_shuttle),
            elevation: 16,
            title: const Text('Cars Selected'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close')),
            ],
            content: SizedBox(
              height: 300,
              child: bd.Badge(
                badgeContent: Text(
                  '${carsPicked.length}',
                  style: myTextStyleTiny(context),
                ),
                badgeStyle: const bd.BadgeStyle(
                    badgeColor: Colors.indigo, elevation: 16),
                child: ListView.builder(
                    itemCount: carsPicked.length,
                    itemBuilder: (_, index) {
                      final car = carsPicked.elementAt(index);
                      return Card(
                        shape: getRoundedBorder(radius: 8),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            '${car.vehicleReg}',
                            style: myTextStyleMediumLargeWithColor(
                                context, Theme.of(context).primaryColor, 16),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          );
        });
  }

  bool showCars = true, showRoutes = false;

  void _navigateToMultiRouteChooser() async {
    routesPicked = await NavigationUtils.navigateTo(
        context: context,
        widget: MultiRouteChooser(
            hideAppBar: false,
            quitOnDone: true,
            onRoutesPicked: (r) {},
            routes: routes),
        transitionType: PageTransitionType.leftToRight);

    pp('$mm back from MultiRouteChooser: routes picked: ${routesPicked.length}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Route Assignments'),
              bottom: PreferredSize(
                  preferredSize: Size.fromHeight(
                      carsPicked.isEmpty && routesPicked.isEmpty ? 160 : 360),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: getDefaultRoundedBorder(),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            gapH16,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Search for Routes',
                                  style: myTextStyleSmall(context),
                                ),
                                gapW16,
                                IconButton(
                                    onPressed: () {
                                      pp('$mm search for routes');
                                      _navigateToMultiRouteChooser();
                                    },
                                    icon: Icon(
                                      Icons.search,
                                      size: 32,
                                      color: Theme.of(context).primaryColor,
                                    )),
                              ],
                            ),
                            carsPicked.isEmpty && routesPicked.isEmpty
                                ? gapH4
                                : gapH32,
                            carsPicked.isEmpty
                                ? gapW16
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _displayCarsDialog();
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              'Number of Cars',
                                              style: myTextStyleSmall(context),
                                            ),
                                            gapW32,
                                            Text(
                                              '${carsPicked.length}',
                                              style:
                                                  myTextStyleMediumLargeWithColor(
                                                      context,
                                                      Theme.of(context)
                                                          .primaryColor,
                                                      20),
                                            ),
                                          ],
                                        ),
                                      ),
                                      gapW16,
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              carsPicked.clear();
                                            });
                                          },
                                          icon: Icon(
                                            Icons.remove_circle,
                                            size: 32,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ))
                                    ],
                                  ),
                            gapH16,
                            routesPicked.isNotEmpty
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Routes Selected',
                                        style: myTextStyleSmall(context),
                                      ),
                                      gapW16,
                                      Text(
                                        '${routesPicked.length}',
                                        style: myTextStyleMediumLargeWithColor(
                                            context,
                                            Theme.of(context).primaryColor,
                                            20),
                                      ),
                                      gapW16,
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              routesPicked.clear();
                                            });
                                          },
                                          icon: Icon(
                                            Icons.remove_circle,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 32,
                                          ))
                                    ],
                                  )
                                : gapW16,
                            gapH16,
                            routesPicked.isNotEmpty && carsPicked.isNotEmpty
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                          onPressed: () {
                                            submitAssignments();
                                          },
                                          style: const ButtonStyle(
                                            elevation:
                                                WidgetStatePropertyAll(12),
                                          ),
                                          icon: const Icon(Icons.add_box),
                                          label: const Padding(
                                            padding: EdgeInsets.all(20.0),
                                            child: Text('Save Assignments'),
                                          )),
                                    ],
                                  )
                                : gapH4,
                            carsPicked.isEmpty && routesPicked.isEmpty
                                ? gapH4
                                : gapH16,
                          ],
                        ),
                      ),
                    ),
                  )),
            ),
            body: busy
                ? const Center(
                    child: TimerWidget(
                      title: 'Sending assignments',
                      isSmallSize: true,
                    ),
                  )
                : ScreenTypeLayout.builder(
                    mobile: (_) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          shape: getRoundedBorder(radius: 16),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: MultiVehicleChooser(
                                    vehicles: cars,
                                    onVehiclePicked: (vehicle) {
                                      setState(() {
                                        carsPicked.add(vehicle);
                                      });
                                    },
                                    vehiclesToHighlight: carsPicked,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    tablet: (_) {
                      return Stack(
                        children: [
                          OrientationLayoutBuilder(landscape: (_) {
                            return Row(
                              children: [
                                SizedBox(
                                  width: (width / 2) - 100,
                                  child: MultiVehicleChooser(
                                      vehiclesToHighlight: carsPicked,
                                      onVehiclePicked: (vehicle) {
                                        setState(() {
                                          carsPicked.add(vehicle);
                                        });
                                      },
                                      vehicles: cars),
                                ),
                                SizedBox(
                                  width: (width / 2) + 100,
                                  child: MultiRouteChooser(
                                    hideAppBar: true,
                                    onRoutesPicked: (rs) {
                                      setState(() {
                                        routesPicked = rs;
                                      });
                                    },
                                    routes: routes,
                                    quitOnDone: true,
                                  ),
                                )
                              ],
                            );
                          }, portrait: (_) {
                            return Row(
                              children: [
                                SizedBox(
                                  width: (width / 2) - 100,
                                  child: MultiVehicleChooser(
                                      vehiclesToHighlight: carsPicked,
                                      onVehiclePicked: (vehicle) {
                                        setState(() {
                                          carsPicked.add(vehicle);
                                        });
                                      },
                                      vehicles: cars),
                                ),
                                SizedBox(
                                  width: (width / 2) + 100,
                                  child: MultiRouteChooser(
                                    onRoutesPicked: (rs) {
                                      setState(() {
                                        routesPicked = rs;
                                      });
                                    },
                                    routes: routes,
                                    quitOnDone: true,
                                    hideAppBar: true,
                                  ),
                                )
                              ],
                            );
                          })
                        ],
                      );
                    },
                  )));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
