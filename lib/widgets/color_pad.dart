import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';

class ColorPad extends StatelessWidget {
  const ColorPad({Key? key, required this.onColorPicked}) : super(key: key);
  final Function(Color, String) onColorPicked;

  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      Colors.red,
      Colors.black,
      Colors.white,
      Colors.orange,
      Colors.green,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.yellow,
      Colors.teal,
      Colors.purple,
      Colors.blue,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
          shape: getRoundedBorder(radius: 16),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 320,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 48.0),
                child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 1.8, crossAxisCount: 6, mainAxisSpacing: 1.8),
                    itemCount: colors.length,
                    itemBuilder: (context, index) {
                      var color = colors.elementAt(index);
                      var stringColor = getStringColor(color);

                      return GestureDetector(
                        onTap: () {
                          pp('....... 🍎🍎🍎🍎🍎🍎 color picked ... $stringColor');
                          onColorPicked(color, stringColor);
                        },
                        child: Card(
                          elevation: 4,
                          child: Container(
                            width: 32,
                            height: 32,
                            color: color,
                          ),
                        ),
                      );
                    }),
              ),
            ),
          )),
    );
  }
}

