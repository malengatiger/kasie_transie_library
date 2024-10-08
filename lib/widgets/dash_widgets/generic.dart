import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/functions.dart';

class TotalWidget extends StatelessWidget {
  const TotalWidget(
      {super.key,
      required this.caption,
      required this.number,
      required this.onTapped,
      this.fontSize});

  final String caption;
  final int number;
  final Function onTapped;
  final double? fontSize;

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
          shape: getDefaultRoundedBorder(),
          elevation: 8,
          child: Center(
            child: SizedBox(
              height: 80,
              child: NumberAndCaption(
                  caption: caption,
                  number: number,
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
      {super.key,
      required this.caption,
      required this.number,
      this.fontSize});

  final String caption;
  final int number;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern();
    final ThemeData mode = Theme.of(context);


    return SizedBox(
      height: 64,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            fmt.format(number),
            style: myTextStyleMediumLarge(context, fontSize),
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
