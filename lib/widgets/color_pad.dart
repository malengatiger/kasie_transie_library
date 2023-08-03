import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';

class ColorPad extends StatelessWidget {
  const ColorPad({Key? key, required this.onColorPicked}) : super(key: key);
  final Function(Color, String) onColorPicked;

  @override
  Widget build(BuildContext context) {
    final type = getThisDeviceType();

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
          shape: getDefaultRoundedBorder(),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              height: 360,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
                child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 1, crossAxisCount: type == 'phone'? 4: 6, mainAxisSpacing: 1),
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

