import 'package:flutter/material.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/route_assignment_list.dart';
import 'package:kasie_transie_library/maps/association_route_maps.dart';
import 'package:kasie_transie_library/providers/kasie_providers.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/route_widgets/multi_route_chooser.dart';
import 'package:kasie_transie_library/widgets/vehicle_widgets/multi_vehicle_chooser.dart';
import 'package:realm/realm.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:badges/badges.dart' as bd;
import '../../data/schemas.dart' as lib;
import '../../utils/prefs.dart';

///manage route assignments for multiple cars
class RouteAssigner extends StatefulWidget {
  const RouteAssigner({
    Key? key,
    this.associationId,
  }) : super(key: key);

  final String? associationId;

  @override
  State<RouteAssigner> createState() => _RouteAssignerState();
}

class _RouteAssignerState extends State<RouteAssigner> {
  static const mm = '🔷🔷🔷 RouteAssigner';

  List<lib.Route> routes = [];
  List<lib.Vehicle> cars = [];
  lib.Route? routePicked;
  List<lib.Vehicle> carsPicked = [];
  bool busy = false;

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
    }
    setState(() {
      busy = false;
    });
  }

  Future _getRoutes() async {
    pp('$mm ................................... _getRoutes ......');
    final user = await prefs.getUser();
    routes = await listApiDog
        .getRoutes(AssociationParameter(user!.associationId!, false));
    pp('$mm ... _getRoutes ...... ${routes.length} routes found');
  }

  Future _getCars() async {
    pp('$mm ..................................... _getCars ......');
    final user = await prefs.getUser();
    if (widget.associationId != null) {
      cars =
          await listApiDog.getAssociationVehicles(user!.associationId!, false);
    } else {
      cars = await listApiDog.getOwnerVehicles(user!.userId!, false);
    }
    pp('$mm ... _getCars ...... found:  ${cars.length} ... set state');
  }

  void submitAssignments() async {
    pp('$mm ... submitAssignments ...');
    if (routePicked == null) {
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
        list.add(lib.RouteAssignment(
          ObjectId(),
          routeId: routePicked!.routeId,
          created: DateTime.now().toUtc().toIso8601String(),
          active: 0,
          associationId: routePicked!.associationId,
          associationName: routePicked!.associationName,
          routeName: routePicked!.name,
          vehicleReg: car.vehicleReg,
          vehicleId: car.vehicleId,
        ));
      }
      final RouteAssignmentList ral = RouteAssignmentList(assignments: list);
      final results = await dataApiDog.addRouteAssignments(ral);
      pp('$mm ... route assignments added to database: ${results.length}');
      if (mounted) {
        showSnackBar(
            backgroundColor: Colors.teal,
            textStyle: const TextStyle(color: Colors.white),
            message: '${carsPicked.length} Route assignments saved for ${routePicked!.name}', context: context);
      }
      carsPicked.clear();
      routePicked = null;

    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(
            backgroundColor: Colors.pink,
            textStyle: const TextStyle(color: Colors.white),
            message: '${carsPicked.length} Route assignments failed: $e', context: context);
      }
    }
    setState(() {
      busy = false;

    });
  }
  void _displayCarsDialog() {
    pp('$mm ... _displayCarsDialog ...');
    showDialog(context: context, builder: (ctx){
      return AlertDialog(
        icon: const Icon(Icons.airport_shuttle),
        elevation: 16,
        title: const Text('Cars Selected'),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: const Text('Close')),
        ],
        content: SizedBox(height: 300,
          child: bd.Badge(
            badgeContent: Text('${carsPicked.length}', style: myTextStyleTiny(context),),
            badgeStyle: const bd.BadgeStyle(badgeColor: Colors.indigo, elevation: 16),
            child: ListView.builder(
                itemCount: carsPicked.length,
                itemBuilder: (_,index){
                  final car = carsPicked.elementAt(index);
              return Card(
                shape: getRoundedBorder(radius: 8),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('${car.vehicleReg}', style: myTextStyleMediumLargeWithColor(context, Theme.of(context).primaryColor,
                      16),),
                ),
              );
            }),
          ),
        ),
      );
    });
  }
  bool showCars = true, showRoutes = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final type = getThisDeviceType();
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Route Assignments'),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(240),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: getDefaultRoundedBorder(),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    _displayCarsDialog();
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'Number of Cars',
                                        style: myTextStyleSmall(context),
                                      ),
                                      gapW16,
                                      Text(
                                        '${carsPicked.length}',
                                        style: myTextStyleMediumLargeWithColor(
                                            context, Theme.of(context).primaryColor, 20),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(onPressed: (){
                                  setState(() {
                                    carsPicked.clear();
                                  });
                                }, icon: const Icon(Icons.remove_circle))
                              ],
                            ),
                            gapH16,
                            routePicked == null
                                ? gapH4
                                : Text(
                                    '${routePicked!.name}',
                                    style: myTextStyleMediumLargeWithColor(context,
                                        Theme.of(context).primaryColor, 16),
                                  ),
                            gapH16,
                            RouteDropDown(
                                routes: routes,
                                onRoutePicked: (route) {
                                  pp('$mm route picked: ${route.name}');
                                  setState(() {
                                    routePicked = route;
                                  });
                                }),
                            gapH16,
                            routePicked != null && carsPicked.isNotEmpty? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                    onPressed: () {
                                      submitAssignments();
                                    },
                                    icon: const Icon(Icons.add_box),
                                    label: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Save Assignments'),
                                    )),
                              ],
                            ): gapH4,
                            routePicked != null && carsPicked.isNotEmpty? gapH4: gapH32,
                          ],
                        ),
                      ),
                    ),
                  )),
            ),
            body: busy
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      backgroundColor: Colors.pink,
                    ),
                  )
                : ScreenTypeLayout.builder(
                    mobile: (_) {
                      return Card(
                        shape: getRoundedBorder(radius: 16),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Stack(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: MultiVehicleChooser(
                                  vehicles: cars,
                                  onVehiclePicked: (vehicle) {
                                    setState(() {
                                      carsPicked.add(vehicle);
                                    });
                                  }, vehiclesToHighlight: carsPicked,
                                ),
                              ),
                            ],
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
                                      onRoutesPicked: (rs) {
                                        setState(() {
                                          //routesPicked = rs;
                                        });
                                      },
                                      routes: routes),
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
                                          //routesPicked = rs;
                                        });
                                      },
                                      routes: routes),
                                )
                              ],
                            );
                          })
                        ],
                      );
                    },
                  )));
  }
}
