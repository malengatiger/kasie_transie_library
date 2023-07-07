import 'package:flutter/material.dart';

class DaysDropDown extends StatelessWidget {
  const DaysDropDown({Key? key, required this.onDaysPicked, required this.hint}) : super(key: key);

  final Function(int) onDaysPicked;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      hint: Text(hint),
        items: const [
          DropdownMenuItem<int>(value: 1, child: Text("1")),
          DropdownMenuItem<int>(value: 2, child: Text("2")),
          DropdownMenuItem<int>(value: 3, child: Text("3")),
          DropdownMenuItem<int>(value: 4, child: Text("4")),
          DropdownMenuItem<int>(value: 5, child: Text("5")),
          DropdownMenuItem<int>(value: 6, child: Text("6")),
          DropdownMenuItem<int>(value: 7, child: Text("7")),
          DropdownMenuItem<int>(value: 14, child: Text("14")),
          DropdownMenuItem<int>(value: 30, child: Text("30")),
          DropdownMenuItem<int>(value: 60, child: Text("60")),
          DropdownMenuItem<int>(value: 90, child: Text("90")),
          DropdownMenuItem<int>(
              value: 120, child: Text("120")),
        ],
        onChanged: (c) {
          if (c != null) {
            onDaysPicked(c);
          }
        });
  }
}
