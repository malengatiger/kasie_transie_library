
import 'package:flutter/material.dart';
import 'package:pretty_print_json/pretty_print_json.dart';

class BarcodeDisplay extends StatelessWidget {
  const BarcodeDisplay({super.key, required this.json});

  final dynamic json;
  @override
  Widget build(BuildContext context) {

    var m = prettyJson(json);
    return Padding(
      padding: const EdgeInsets.all(16),
      child:  Text(m),
    );

  }
}
