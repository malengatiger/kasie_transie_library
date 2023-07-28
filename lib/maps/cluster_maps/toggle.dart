import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';

class HybridToggle extends StatelessWidget {
  const HybridToggle(
      {super.key,
        required this.onHybrid,
        required this.onNormal,
        required this.hybrid});
  final Function onHybrid;
  final Function onNormal;
  final bool hybrid;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (hybrid) {
          onNormal();
        } else {
          onHybrid();
        }
      },
      child: Card(
        shape: getRoundedBorder(radius: 32),
        elevation: 12,
        child: Icon(
          Icons.settings,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
