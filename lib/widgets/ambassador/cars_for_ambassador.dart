import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/widgets/vehicle_widgets/vehicle_search.dart';
import 'package:page_transition/page_transition.dart';

import '../../maps/map_viewer.dart';

class CarForAmbassador extends StatefulWidget {
  const CarForAmbassador({super.key, required this.associationId});

  final String associationId;

  @override
  State<CarForAmbassador> createState() => _CarForAmbassadorState();
}

class _CarForAmbassadorState extends State<CarForAmbassador> {
  static const mm = '🍄🍄🍄🍄CarForAmbassador 🍄';

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
    showToast(
        padding: 20,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.amber.shade800,
        textStyle: myTextStyle(color: Colors.white),
        message: 'Scanning feature under construction!',
        context: context);
    return;

    // var vehicle = await NavigationUtils.navigateTo(
    //   context: context,
    //   widget: const ScanTaxi(),
    // );
    // if (vehicle != null) {
    //   pp('$mm vehicle scanned for dispatch: ${vehicle!.vehicleReg} on ${widget
    //       .route.name}');
    //   _navigateToDispatch(vehicle);
    // }
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
                            fontSize: 24,
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
                            fontSize: 24,
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

class ScanTaxi extends StatefulWidget {
  const ScanTaxi({super.key});

  @override
  State<ScanTaxi> createState() => _ScanTaxiState();
}

class _ScanTaxiState extends State<ScanTaxi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Scan Taxi'), actions: [
          IconButton(
              onPressed: () {},
              icon: const FaIcon(FontAwesomeIcons.mapLocation))
        ]),
        body: const SafeArea(child: Center(child: Text('Scanner to come'))));
  }
}