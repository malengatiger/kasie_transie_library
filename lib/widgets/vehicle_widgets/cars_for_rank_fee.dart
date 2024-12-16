import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/widgets/vehicle_widgets/rank_fee_widget.dart';
import 'package:kasie_transie_library/widgets/vehicle_widgets/vehicle_search.dart';


class CarForRankFee extends StatefulWidget {
  const CarForRankFee({super.key, required this.associationId,});

  final String associationId;

  @override
  State<CarForRankFee> createState() =>CarForRankFeeState();
}

class CarForRankFeeState extends State<CarForRankFee> {
  static const mm = '🍄🍄🍄🍄CarForRankFee 🍄';

  _search() async {
    var vehicle = await NavigationUtils.navigateTo(
        context: context,
        widget:  VehicleSearch(associationId: widget.associationId,),
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
            widget: RankFeeSender(
                vehicle: vehicle),
            );
      }
    }
  }

  _scan() async {

    showToast(
        padding: 20,
        duration: const Duration(seconds:   3),
        backgroundColor: Colors.amber.shade800,
        textStyle: myTextStyle(color: Colors.white),
        message: 'Scanning feature under construction!', context: context);
    return;

    // var vehicle = await NavigationUtils.navigateTo(
    //     context: context,
    //     widget: const ScanTaxi(),
    //     );
    // if (vehicle != null) {
    //   pp('$mm vehicle scanned for dispatch: ${vehicle!.vehicleReg} on ${widget.route.name}');
    //   _navigateToDispatch(vehicle);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car For Rank Fees'),
      ),
      body: SafeArea(
          child: Padding(
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
                  child: Text('Rank Fees',
                    style: myTextStyle(
                        fontSize: 36,
                        weight: FontWeight.w900,
                        color: Theme.of(context).primaryColor),
                  ),
                )
              ],
            ),
            gapH32, gapH32, gapH32,
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
                      style: myTextStyle(color: Colors.white, fontSize: 24, ),
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
                      style: myTextStyle(color: Colors.white, fontSize: 24, ),
                    ),
                  )),
            ),
          ],
        ),
      )),
    );
  }
}
