import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/widgets/vehicle_widgets/vehicle_search.dart';

import '../vehicle_widgets/cars_for_dispatch.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class CarForAmbassador extends StatefulWidget {
  const CarForAmbassador({super.key, required this.associationId});

  final String associationId;

  @override
  State<CarForAmbassador> createState() => _CarForAmbassadorState();
}

class _CarForAmbassadorState extends State<CarForAmbassador> {
  static const mm = '🍄🍄🍄🍄CarForAmbassador 🍄';
  Prefs prefs = GetIt.instance<Prefs>();
  lib.User? user;
  @override
  void initState() {
    super.initState();
    _signIn();
  }
  _signIn() async {
    user = prefs.getUser();
    if (user != null) {
      var u = await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: user!.email!, password: user!.password!);
      if (u.user != null) {
        pp('$mm user has signed in');
      }
    }
  }
  _search() async {
    var vehicle = await NavigationUtils.navigateTo(
      context: context,
      widget: VehicleSearch(
        associationId: widget.associationId,
      ),
    );

    if (vehicle != null) {
      pp('$mm vehicle found: ${vehicle!.vehicleReg}');
      Navigator.of(context).pop(vehicle);
    }
  }


  _scan() async {
    // showToast(
    //     padding: 20,
    //     duration: const Duration(seconds: 3),
    //     backgroundColor: Colors.amber.shade800,
    //     textStyle: myTextStyle(color: Colors.white),
    //     message: 'Scanning feature under construction!',
    //     context: context);
    // return;

    var vehicle = await NavigationUtils.navigateTo(
      context: context,
      widget: const ScanTaxi(),
    );
    if (vehicle != null && vehicle is lib.Vehicle) {
      pp('$mm  _scan(): ....... vehicle scanned for dispatch: ${vehicle!.vehicleReg}');
      if (mounted) {
        Navigator.of(context).pop(vehicle);
      }
    } else {
      pp('$mm  _scan(): ... something wrong here : $vehicle');
      var car = lib.Vehicle.fromJson(vehicle);
      if (mounted) {
        Navigator.of(context).pop(car);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Ambassador', style: myTextStyle()),
          actions: [
        IconButton(
            onPressed: () {
              // NavigationUtils.navigateTo(
              //     context: context,
              //     widget: MapViewer(
              //       route: widget.route,
              //     ));
            },
            icon: const FaIcon(FontAwesomeIcons.camera))
      ]),
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                gapH32,
                gapH32,
                gapH32,
                const Text('Select a taxi using one or the other method'),
                gapH32,
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                      style: const ButtonStyle(
                          elevation: WidgetStatePropertyAll(8),
                          backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                      onPressed: _search,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Search Taxi',
                          style: myTextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      )),
                ),
                gapH32,
                gapH32,
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                      onPressed: _scan,
                      style: const ButtonStyle(
                          elevation: WidgetStatePropertyAll(8),
                          backgroundColor: WidgetStatePropertyAll(
                              Colors.green)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Scan Taxi',
                          style: myTextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      )),
                ),
              ],
            ),
          )),
    );
  }
}
