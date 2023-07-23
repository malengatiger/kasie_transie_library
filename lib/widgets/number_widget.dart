import 'package:flutter/material.dart';

import '../utils/functions.dart';

class NumberWidget extends StatelessWidget {
  const NumberWidget({Key? key, required this.title, required this.number})
      : super(key: key);

  final String title;
  final int number;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: getDefaultRoundedBorder(),
      elevation: 8,
      child: SizedBox(
        height: 120,
        width: 120,
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Text(
              '$number',
              style: myNumberStyleLargerWithColor(
                  Theme.of(context).primaryColor, 32, context),
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