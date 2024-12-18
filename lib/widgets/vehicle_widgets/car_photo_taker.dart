import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/widgets/vehicle_widgets/vehicle_search.dart';

import '../../data/data_schemas.dart';
import '../../utils/functions.dart';
import '../../utils/navigator_utils.dart';
import '../../utils/prefs.dart';
import '../photo_handler.dart';

class CarPhotoTaker extends StatefulWidget {
  const CarPhotoTaker({super.key});

  @override
  CarPhotoTakerState createState() => CarPhotoTakerState();
}

class CarPhotoTakerState extends State<CarPhotoTaker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🍎🍎🍎🍎🍎 CarPhotoTaker';
  Prefs prefs = GetIt.instance<Prefs>();
  User? user;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getUser();
  }

  _getUser() {
    user = prefs.getUser();
    Future.delayed(const Duration(seconds: 1), () {
      _navigateToVehicleSearch();
    });
  }

  _navigateToCamera(Vehicle vehicle) async {
    pp('$mm ... _navigateToCamera ...');

    NavigationUtils.navigateTo(
        context: context,
        widget: PhotoHandler(
            vehicle: vehicle,
            onPhotoTaken: (file, thumb) {
              pp('$mm onPhotoTaken .... file: ${file.path}');
            }));
  }

  Vehicle? vehicle;

  _navigateToVehicleSearch() async {
    pp('$mm ... _navigateToVehicleSearch ...');

    vehicle = await NavigationUtils.navigateTo(
        context: context,
        widget: VehicleSearch(
          associationId: user!.associationId!,
        ));
    if (vehicle != null) {
      _navigateToCamera(vehicle!);
    }
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
          title: const Text('Vehicle Photo Taker'),
        ),
        body: SafeArea(
            child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: const ButtonStyle(
                          elevation: WidgetStatePropertyAll(8),
                        ),
                        onPressed: () {
                          _navigateToVehicleSearch();
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Find Car',
                              style: myTextStyle(fontSize: 28, weight: FontWeight.w900),
                            )))
                  ],
                ),
              ],
            )
          ],
        )));
  }
}
