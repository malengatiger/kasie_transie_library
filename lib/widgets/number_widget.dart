import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/functions.dart';

class NumberWidget extends StatelessWidget {
  const NumberWidget({super.key, required this.title, required this.number, required this.height, required this.width, required this.elevation, required this.fontSize});

  final String title;
  final int number;
  final double height, width, elevation, fontSize;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern();
    final count = fmt.format(number);
    return Card(
      shape: getDefaultRoundedBorder(),
      elevation: elevation,
      child: SizedBox(
        height: height,
        width: width,
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              count,
              style: myNumberStyleLargerWithColor(
                  Theme.of(context).primaryColor, fontSize, context),
            ),
            Text(
              title,
              style: myTextStyleSmall(context),
            ),
          ],
        ),
      ),
    );
  }
}