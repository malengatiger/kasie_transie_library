import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/functions.dart';
import 'package:badges/badges.dart' as bd;

class TotalWidget extends StatelessWidget {
  const TotalWidget(
      {super.key,
      required this.caption,
      required this.number,
      required this.onTapped,
      this.color,
      this.fontSize, this.padding});

  final String caption;
  final int number;
  final Function onTapped;
  final double? fontSize;
  final Color? color;
  final double? padding;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: 160,
      child: GestureDetector(
        onTap: () {
          onTapped();
        },
        child: Card(
          elevation: 8,
          child: Center(
            child: SizedBox(
              height: 120,
              child: NumberAndCaption(
                  caption: caption,
                  number: number,
                  color: color ?? Colors.blue,
                  padding: padding?? 8,
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
      this.color,
      this.fontSize, this.padding});

  final String caption;
  final int number;
  final double? fontSize;
  final Color? color;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern();
    final ThemeData mode = Theme.of(context);
    var num = '';
    if (number >= 1000) {
      num = '${ (number / 1000).toStringAsFixed(1)} K ';
    } else {
      num = fmt.format(number);
    }

    return SizedBox(
      height: 160,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          bd.Badge(
            badgeContent: Text(num,
              style: myTextStyle(
                  color: Colors.white,
                  weight: FontWeight.normal,
                  fontSize: fontSize ?? 12),
            ),
            badgeStyle: bd.BadgeStyle(
                badgeColor: color ?? Colors.red,
                padding: EdgeInsets.all(padding?? 16)),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            caption,
            style: myTextStyleSmall(context),
          )
        ],
      ),
    );
  }
}
