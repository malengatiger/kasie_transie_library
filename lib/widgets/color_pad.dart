import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';

class ColorPad extends StatelessWidget {
  const ColorPad({super.key, required this.onColorPicked, required this.onClose});

  final Function(Color, String) onColorPicked;
  final Function() onClose;

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
    List<Container> widgets = [];
    for (var c in colors) {
      widgets.add(Container(color: c, width: 24, height: 24));
    }

    return SizedBox(
        height: 80,
        width: 640,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tap to change Route colour', style: myTextStyleMediumLarge(context, 16),),
                IconButton(onPressed: (){}, icon: const Icon(Icons.close))
              ],
            ),
            gapH8,
            Expanded(
              child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 1,
                      crossAxisCount: type == 'phone' ? 4 : 12,
                      mainAxisSpacing: 1),
                  itemCount: widgets.length,
                  itemBuilder: (context, index) {
                    var color = colors.elementAt(index);
                    var stringColor = getStringColor(color);
                    var colorContainer = widgets[index];
                    return GestureDetector(
                      onTap: () {
                        pp('...... 🍎🍎🍎🍎🍎🍎 color picked ... $stringColor');
                        onColorPicked(color, stringColor);
                      },
                      child: Card(
                        elevation: 4,
                        child: colorContainer,
                      ),
                    );
                  }),
            )
          ],
        ));
  }
}
