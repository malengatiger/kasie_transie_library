import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/schemas.dart' as mn;
import 'package:kasie_transie_library/utils/functions.dart';

class VehicleDetail extends StatelessWidget {
  const VehicleDetail({Key? key, required this.vehicle}) : super(key: key);
  final mn.Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: getRoundedBorder(radius: 16),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 48,),
            Text('${vehicle!.vehicleReg}', style: myTextStyleMediumLargeWithSize(context, 24),),
            const SizedBox(height: 16,),
            Text('${vehicle!.make} ${vehicle!.model} - ${vehicle!.year}', style: myTextStyleSmall(context),),
            const SizedBox(height: 48,),
            const Text('Owner'),
            const SizedBox(height: 8,),
            Text(vehicle!.ownerName == null? 'Owner Unknown':'${vehicle!.ownerName}',
              style: myTextStyleMediumLargeWithSize(context, 20),),
            const SizedBox(height: 48,),

          ],
        ),
      ),
    );
  }
}
