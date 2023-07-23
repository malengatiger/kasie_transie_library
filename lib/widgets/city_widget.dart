import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';

class CityWidget extends StatelessWidget {
  const CityWidget({Key? key, this.city, required this.title})
      : super(key: key);
  final lib.City? city;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(title, style:
        myTextStyleMediumLargeWithSize(context, 16),)),
        const SizedBox(
          width: 12,
        ),
        city == null
            ? const SizedBox()
            : Text(
          '${city!.name}',
          style: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColor, 15.0),
        )
      ],
    );
  }
}