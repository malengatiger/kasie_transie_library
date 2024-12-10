import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';

class CityWidget extends StatelessWidget {
  const CityWidget(
      {super.key, this.city, required this.title, required this.onTapped});
  final lib.City? city;
  final String title;
  final Function onTapped;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 240,
          child: Row(mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  onTapped();
                },
                child: Text(
                  title,
                  style: myTextStyleMediumLarge(context, 24),
                ),
              ),
            ]
          )
        ),
        const SizedBox(
          width: 12,
        ),
        city == null
            ? const SizedBox()
            : Text(
                '${city!.name}',
                style: myTextStyleMediumLarge(context, 24),
              )
      ],
    );
  }
}
