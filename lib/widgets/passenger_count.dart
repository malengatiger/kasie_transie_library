import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/schemas.dart' as lib;
import '../utils/functions.dart';
import 'package:badges/badges.dart' as bd;

class DispatchCarPlate extends StatelessWidget {
  const DispatchCarPlate({Key? key, required this.dispatchRecord})
      : super(key: key);
  final lib.DispatchRecord dispatchRecord;

  @override
  Widget build(BuildContext context) {
    var color = Colors.red.shade700;
    if (dispatchRecord.passengers! < 6) {
      color = Colors.amber.shade900;
    }
    if (dispatchRecord.passengers! >= 6) {
      color = Colors.teal.shade700;
    }
    if (dispatchRecord.passengers! > 16) {
      color = Colors.pink.shade700;
    }
    if (dispatchRecord.passengers! == 0) {
      color = Colors.grey;
    }
    final fmt = DateFormat('HH:mm:ss');
    final date = fmt.format(DateTime.parse(dispatchRecord.created!));
    return SizedBox(
      height: 80,
      width: 80,
      child: bd.Badge(
        badgeContent: Text(
          '${dispatchRecord.passengers}',
          style: myTextStyleSmall(context),
        ),
        position: bd.BadgePosition.topEnd(top: 2, end: -2),
        badgeStyle: bd.BadgeStyle(
          badgeColor: color,
          elevation: 8,
          padding: const EdgeInsets.all(6),
        ),
        child: Card(
          shape: getRoundedBorder(radius: 8),
          elevation: 8,
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 48,
                ),
                Text(
                  '${dispatchRecord.vehicleReg}',
                  style: myTextStyleMediumLarge(context, 16),
                ),
                Text(date, style: myTextStyleSmall(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PassengerCount extends StatelessWidget {
  const PassengerCount({Key? key, required this.onCountPicked})
      : super(key: key);
  final Function(int) onCountPicked;

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<int>>[];
    for (int index = 0; index < 31; index++) {
      items.add(DropdownMenuItem<int>(value: index, child: Text('$index', style:
      myTextStyleMediumLargeWithColor(context, Theme.of(context).primaryColor, 16),)));
    }
    return DropdownButton(
        hint: const Text('Passengers'), items: items, onChanged: onChanged);
  }

  void onChanged(int? value) {
    value ??= 0;
    onCountPicked(value);
  }
}
