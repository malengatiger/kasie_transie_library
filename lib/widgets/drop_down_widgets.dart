import 'package:flutter/material.dart';

import '../utils/functions.dart';

class DistanceDropDown extends StatelessWidget {
  const DistanceDropDown(
      {super.key,
      required this.onDistancePicked,
      required this.color,
      required this.count,
      required this.fontSize, required this.multiplier});

  final Function(int) onDistancePicked;
  final Color color;
  final double fontSize;
  final int count, multiplier;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> items = [];
    for (var i = 0; i < count; i++) {
      var m = i * multiplier;
      if (m ==  0) {
        m = 10;
      }
      items.add(DropdownMenuItem(
          value: i * multiplier,
          child: Text(
            '$m km',
            style: myTextStyleMediumLargeWithColor(context, color, fontSize),
          )));
    }
    return DropdownButton<int>(
        items: items,
        onChanged: (number) {
          if (number != null) {
            onDistancePicked(number);
          }
        });
  }
}

class NumberDropDown extends StatelessWidget {
  const NumberDropDown(
      {super.key,
      required this.onNumberPicked,
      required this.color,
      required this.count,
      required this.fontSize});

  final Function(int) onNumberPicked;
  final Color color;
  final double fontSize;
  final int count;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> items = [];
    for (var i = 0; i < count; i++) {
      items.add(DropdownMenuItem(
          value: i,
          child: Text(
            '$i',
            style: myTextStyleMediumLargeWithColor(context, color, fontSize),
          )));
    }
    return DropdownButton<int>(
        items: items,
        onChanged: (number) {
          if (number != null) {
            onNumberPicked(number);
          }
        });
  }
}
