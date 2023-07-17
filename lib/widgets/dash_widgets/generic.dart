
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/functions.dart';

class TotalWidget extends StatelessWidget {
  const TotalWidget(
      {Key? key,
        required this.caption,
        required this.number,
        required this.onTapped,
        required this.color,
        required this.fontSize})
      : super(key: key);
  final String caption;
  final int number;
  final Function onTapped;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 120,
      child: GestureDetector(
        onTap: () {
          onTapped();
        },
        child: Card(
          shape: getRoundedBorder(radius: 16),
          elevation: 8,
          child: Center(
            child: SizedBox(
              height: 80,
              child: NumberAndCaption(
                  caption: caption,
                  number: number,
                  color: color,
                  fontSize: fontSize),
            ),
          ),
        ),
      ),
    );
  }
}

class NumberAndCaption extends StatelessWidget {
  const NumberAndCaption(
      {Key? key,
        required this.caption,
        required this.number,
        required this.color,
        required this.fontSize})
      : super(key: key);
  final String caption;
  final int number;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern();
    return SizedBox(
      height: 64,
      child: Column(
        children: [
          Text(
            fmt.format(number),
            style: myNumberStyleLargerWithColor(color, fontSize, context),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            caption,
            style: myTextStyleSmall(context),
          ),
        ],
      ),
    );
  }
}
