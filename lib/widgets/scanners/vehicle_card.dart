
import 'package:flutter/material.dart';
import 'package:kasie_transie_library/widgets/scanners/scanner_constants.dart';

import '../../data/data_schemas.dart';
import '../../utils/functions.dart';



class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(ScannerConstants.vehicle, style: myTextStyle(color: Theme
                  .of(context)
                  .primaryColor, weight: FontWeight.bold, fontSize: 28),),
              gapH32,
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Registration'),
                  Text('${vehicle.vehicleReg}',
                    style: myTextStyle(weight: FontWeight.bold, fontSize: 36, color: Theme.of(context).primaryColor),),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Make'),
                  Text('${vehicle.make}',
                    style: myTextStyle(weight: FontWeight.bold, fontSize: 18),),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Model'),
                  Text('${vehicle.model}',
                    style: myTextStyle(weight: FontWeight.bold, fontSize: 18),),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Year'),
                  Text('${vehicle.year}',
                    style: myTextStyle(weight: FontWeight.bold, fontSize: 20),),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${vehicle.associationName}',
                    style: myTextStyle(weight: FontWeight.bold, fontSize: 16),),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
