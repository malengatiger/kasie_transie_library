import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;

import '../../utils/functions.dart';

class VehicleDispatches extends StatelessWidget {
  const VehicleDispatches({Key? key, required this.dispatchRecords, required this.onClose})
      : super(key: key);

  final List<lib.DispatchRecord> dispatchRecords;
 final Function onClose;
  @override
  Widget build(BuildContext context) {
    var total = 0;
    for (var value in dispatchRecords) {
      total += value.passengers!;
    }
    final tot = NumberFormat.decimalPattern().format(total);
    return GestureDetector(
      onTap: (){
        onClose();
      },
      child: Card(
        shape: getDefaultRoundedBorder(),
        elevation: 4,
        child: Column(
          children: [
            gapH16,
            Text('Dispatches', style: myTextStyleMediumLargeWithColor(context,
                Theme.of(context).primaryColor,
                28),),
            gapH8,
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total Passengers: ', style: myTextStyleSmall(context),),
                gapW8,
                Text(tot, style: myTextStyleMediumLargeWithColor(context,
                    Theme.of(context).primaryColor,
                    20),),
              ],
            ),
            gapH16,
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, crossAxisSpacing: 2),
                      itemCount: dispatchRecords.length,
                      itemBuilder: (ctx, index) {
                        final dr = dispatchRecords.elementAt(index);
                        return DispatchWidget(dispatchRecord: dr);
                      })),
            ),
          ],
        ),
      ),
    );
  }
}

class DispatchWidget extends StatelessWidget {
  const DispatchWidget({super.key, required this.dispatchRecord});

  final lib.DispatchRecord dispatchRecord;

  @override
  Widget build(BuildContext context) {
    final date = getFormattedDateHour(dispatchRecord.created!);
    return Card(
      elevation: 16,
      shape: getRoundedBorder(radius: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            gapH16,
            Text(
              date,
              style: myTextStyleMediumLargeWithColor(
                  context, Theme.of(context).primaryColorLight, 24),
            ),
            gapH16,
            Text(
              '${dispatchRecord.landmarkName}',
              style: myTextStyleTiny(context),
            ),
            gapH8,
            Text(
              '${dispatchRecord.routeName}',
              style: myTextStyleTiny(context),
            )
          ],
        ),
      ),
    );
  }
}
