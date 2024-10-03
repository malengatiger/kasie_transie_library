import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  const ColorPicker({super.key, required this.onColorPicked});

  final Function(String, Color) onColorPicked;

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<int>>[];
    items.add(DropdownMenuItem<int>(
      value: 0,
      child: Container(
        color: Colors.red,
        width: 48,
        height: 48,
      ),
    ));
    items.add(DropdownMenuItem<int>(
      value: 1,
      child: Container(
        color: Colors.black,
        width: 48,
        height: 48,
      ),
    ));
    items.add(DropdownMenuItem<int>(
      value: 2,
      child: Container(
        color: Colors.white,
        width: 48,
        height: 48,
      ),
    ));
    items.add(DropdownMenuItem<int>(
      value: 3,
      child: Container(
        color: Colors.orange,
        width: 48,
        height: 48,
      ),
    ));
    items.add(DropdownMenuItem<int>(
      value: 4,
      child: Container(
        color: Colors.green,
        width: 48,
        height: 48,
      ),
    ));
    items.add(DropdownMenuItem<int>(
      value: 5,
      child: Container(
        color: Colors.indigo,
        width: 48,
        height: 48,
      ),
    ));
    items.add(DropdownMenuItem<int>(
      value: 6,
      child: Container(
        color: Colors.pink,
        width: 48,
        height: 48,
      ),
    ));
    items.add(DropdownMenuItem<int>(
      value: 7,
      child: Container(
        color: Colors.amber,
        width: 48,
        height: 48,
      ),
    ));
    items.add(DropdownMenuItem<int>(
      value: 8,
      child: Container(
        color: Colors.yellow,
        width: 48,
        height: 48,
      ),
    ));
    items.add(DropdownMenuItem<int>(
      value: 9,
      child: Container(
        color: Colors.teal,
        width: 48,
        height: 48,
      ),
    ));
    items.add(
      DropdownMenuItem<int>(
        value: 10,
        child: Container(
          color: Colors.purple,
          width: 48,
          height: 48,
        ),
      ),
    );
    items.add(
      DropdownMenuItem<int>(
        value: 11,
        child: Container(
          color: Colors.blue,
          width: 48,
          height: 48,
        ),
      ),
    );

    return DropdownButton<int>(items: items, onChanged: onChanged);
  }

  void onChanged(int? index) {
    switch (index) {
      case 0:
        onColorPicked('red', Colors.red);
        break;
      case 1:
        onColorPicked('black', Colors.black);
        break;
      case 2:
        onColorPicked('white', Colors.white);
        break;
      case 3:
        onColorPicked('orange', Colors.orange);
        break;
      case 4:
        onColorPicked('green', Colors.green);
        break;
      case 5:
        onColorPicked('indigo', Colors.indigo);
        break;
      case 6:
        onColorPicked('pink', Colors.pink);
        break;
      case 7:
        onColorPicked('amber', Colors.amber);
        break;
      case 8:
        onColorPicked('yellow', Colors.yellow);
        break;
      case 9:
        onColorPicked('teal', Colors.teal);
        break;
      case 10:
        onColorPicked('purple', Colors.purple);
        break;
      case 11:
        onColorPicked('blue', Colors.blue);
        break;
    }
  }
}
