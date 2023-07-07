import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';

import '../data/big_bag.dart';
import 'number_widget.dart';

class CountsGridWidget extends StatelessWidget {
  const CountsGridWidget({
    Key? key,
    required this.arrivalsText,
    required this.departuresText,
    required this.dispatchesText,
    required this.heartbeatText,
    required this.arrivals,
    required this.departures,
    required this.heartbeats,
    required this.dispatches,
  }) : super(key: key);

  final String arrivalsText, departuresText, dispatchesText, heartbeatText;
  final int arrivals, departures, heartbeats, dispatches;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 2, mainAxisSpacing: 2),
        children: [
          NumberWidget(
            title: arrivalsText,
            number: arrivals,
          ),
          NumberWidget(
            title: departuresText,
            number: departures,
          ),
          NumberWidget(
            title: dispatchesText,
            number: dispatches,
          ),
          NumberWidget(
            title: heartbeatText,
            number: heartbeats,
          ),
        ],
      ),
    );
  }
}
