import 'package:flutter/material.dart';
import 'package:kasie_transie_library/widgets/drop_down_widgets.dart';

import '../../utils/functions.dart';

class PassengerCounter extends StatefulWidget {
  const PassengerCounter(
      {super.key,
      required this.onNumberSelected,
      required this.color,
      required this.title,
      required this.count, required this.fontSize});

  final Function(int) onNumberSelected;
  final Color color;
  final String title;
  final int count;
  final double fontSize;

  @override
  State<PassengerCounter> createState() => _PassengerCounterState();
}

class _PassengerCounterState extends State<PassengerCounter> {
  int passengers = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 8,
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(widget.title),
                gapW32,
                NumberDropDown(
                    onNumberPicked: (number) {
                      setState(() {
                        passengers = number;
                      });
                      widget.onNumberSelected(number);
                    },
                    color: Colors.black,
                    count: widget.count,
                    fontSize: 16),
                gapW32,
                Text('$passengers', style: myTextStyle(fontSize: widget.fontSize, color: widget.color),)
              ],
            )));
  }
}
