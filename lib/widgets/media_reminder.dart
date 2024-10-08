import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';

class MediaReminder extends StatelessWidget {
  const MediaReminder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 320,
      child: Center(
        child: Card(
          color: Colors.red.shade700,
          shape: getDefaultRoundedBorder(),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Please take photographs or videos of this vehicle when you are done with the dispatch. Thank You! ',
              style: myTextStyleSmall(context),
            ),
          ),
        ),
      ),
    );
  }
}
