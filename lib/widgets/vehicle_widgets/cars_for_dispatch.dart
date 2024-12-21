import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/widgets/vehicle_widgets/vehicle_search.dart';
import 'package:page_transition/page_transition.dart';

import '../../maps/map_viewer.dart';
import 'dispatch_taxi.dart';

class CarForDispatch extends StatefulWidget {
  const CarForDispatch({super.key, required this.route});

  final lib.Route route;

  @override
  State<CarForDispatch> createState() => _CarForDispatchState();
}

class _CarForDispatchState extends State<CarForDispatch> {
  static const mm = '🍄🍄🍄🍄CarForDispatch 🍄';

  _search() async {
    var vehicle = await NavigationUtils.navigateTo(
      context: context,
      widget: VehicleSearch(
        associationId: widget.route.associationId!,
      ),
    );

    if (vehicle != null) {
      pp('$mm vehicle found: ${vehicle!.vehicleReg}');
      _navigateToDispatch(vehicle);
    }
  }

  void _navigateToDispatch(vehicle) {
    if (vehicle != null) {
      pp('$mm vehicle to dispatch: ${vehicle!.vehicleReg} on ${widget.route.name}');

      if (mounted) {
        NavigationUtils.navigateTo(
          context: context,
          widget: DispatchTaxi(
              route: widget.route,
              onDispatched: (dr) {
                pp('Car dispatched: ${dr.toJson()}');
              },
              vehicle: vehicle),
        );
      }
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

    var vehicle = await NavigationUtils.navigateTo(
      context: context,
      widget: const ScanTaxi(),
    );
    if (vehicle != null) {
      pp('$mm vehicle scanned for dispatch: ${vehicle!.vehicleReg} on ${widget.route.name}');
      _navigateToDispatch(vehicle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Taxi Dispatch', style: myTextStyle()), actions: [
        IconButton(
            onPressed: () {
              NavigationUtils.navigateTo(
                  context: context,
                  widget: MapViewer(
                    route: widget.route,
                  ));
            },
            icon: const FaIcon(FontAwesomeIcons.mapLocation))
      ]),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Route'),
            gapH8,
            Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        widget.route.name!,
                        style: myTextStyle(
                            fontSize: 28,
                            weight: FontWeight.w900,
                            color: Theme.of(context).primaryColor),
                      ),
                    )
                  ],
                ),
              ),
            ),
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
                        fontSize: 20,
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
                      backgroundColor: WidgetStatePropertyAll(Colors.green)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Scan Taxi',
                      style: myTextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
