import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/widgets/vehicle_widgets/rank_fee_sender.dart';
import 'package:kasie_transie_library/widgets/vehicle_widgets/vehicle_search.dart';

import '../../data/data_schemas.dart';
import 'cars_for_dispatch.dart';

class CarForRankFee extends StatefulWidget {
  const CarForRankFee({
    super.key,
    required this.associationId,
  });

  final String associationId;

  @override
  State<CarForRankFee> createState() => CarForRankFeeState();
}

class CarForRankFeeState extends State<CarForRankFee> {
  static const mm = '🍄🍄🍄🍄CarForRankFee 🍄';

  _search() async {
    var vehicle = await NavigationUtils.navigateTo(
      context: context,
      widget: VehicleSearch(
        associationId: widget.associationId,
      ),
    );

    if (vehicle != null) {
      pp('$mm vehicle found: ${vehicle!.vehicleReg}');
      _navigateToRankFee(vehicle);
    }
  }

  void _navigateToRankFee(vehicle) {
    if (vehicle != null) {
      pp('$mm vehicle for Rank Fee: ${vehicle!.vehicleReg} ');

      if (mounted) {
        NavigationUtils.navigateTo(
          context: context,
          widget: RankFeeSender(vehicle: vehicle),
        );
      }
    }
  }

  _scan() async {
    var json = await NavigationUtils.navigateTo(
      context: context,
      widget: const ScanTaxi(),
    );
    if (json != null) {
      var car = Vehicle.fromJson(json);
      pp('$mm json scanned for dispatch: ${car.vehicleReg} ');
      _navigateToRankFee(car);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Taxi Rank Fees',
          style: myTextStyle(),
        ),
      ),
      body: SafeArea(
          child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                gapH8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Rank Fees',
                        style: myTextStyle(
                            fontSize: 36,
                            weight: FontWeight.w900,
                            color: Theme.of(context).primaryColor),
                      ),
                    )
                  ],
                ),
                gapH32,
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
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.green)),
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
          ),
          Positioned(
            right: 32,
            bottom: 16,
            child: ElevatedButton(
              style: const ButtonStyle(elevation: WidgetStatePropertyAll(4)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Done'),
              ),
            ),
          )
        ],
      )),
    );
  }
}
