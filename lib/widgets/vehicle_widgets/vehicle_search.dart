
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:badges/badges.dart' as bd;
import '../../bloc/list_api_dog.dart';
import '../../l10n/translation_handler.dart';
import '../../utils/emojis.dart';

class VehicleSearch extends StatefulWidget {
  const VehicleSearch({super.key, required this.cars, required this.carsFound,});
  final List<lib.Vehicle> cars;
  final Function(List<lib.Vehicle>) carsFound;

  @override
  State<VehicleSearch> createState() => _VehicleSearchState();
}

class _VehicleSearchState extends State<VehicleSearch> {
  static const mm = '🍎🍎🍎🍎🍎 VehicleSearch';
  final TextEditingController _textEditingController = TextEditingController();
  String search = 'Search';
  String searchVehicles = 'Search Vehicles';
  List<lib.Vehicle> carsPicked = [];
  bool busy = false;

  @override
  void initState() {
    super.initState();
    pp('$mm .....initState; cars to process: ${widget.cars.length}');

    _setCarPlates();
  }
  final _carPlates = <String>[];
  var carsToDisplay = <lib.Vehicle>[];

  void _setCarPlates() {
    _carPlates.clear();
    for (var element in widget.cars) {
      _carPlates.add(element.vehicleReg!);
      carsToDisplay.add(element);
    }

    pp('$mm ..... cars to process: ${widget.cars.length}');
  }
  lib.Vehicle? _findVehicle(String carPlate) {
    for (var car in widget.cars) {
      if (car.vehicleReg!.toLowerCase() == carPlate.toLowerCase()) {
        return car;
      }
    }
    pp('$mm ..................................${E.redDot} ${E.redDot} DID NOT FIND $carPlate');

    return null;
  }


  void _runFilter(String text) {
    pp('$mm .... _runFilter: text: $text ......');
    if (text.isEmpty) {
      pp('$mm .... text is empty ......');
      carsToDisplay.clear();
      for (var project in widget.cars) {
        carsToDisplay.add(project);
      }
      setState(() {});
      return;
    }
    carsToDisplay.clear();

    pp('$mm ...  filtering cars that contain: $text from ${_carPlates.length} car plates');
    for (var carPlate in _carPlates) {
      if (carPlate.toLowerCase().contains(text.toLowerCase())) {
        var car = _findVehicle(carPlate);
        if (car != null) {
          carsToDisplay.add(car);
        }
      }
    }
    pp('$mm .... send  carsToDisplay: ${carsToDisplay.length} ......');
    widget.carsFound(carsToDisplay);
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            controller: _textEditingController,
            onChanged: (text) {
              pp(' ........... changing to: $text');
              _runFilter(text);
            },
            decoration: InputDecoration(
                label: Text(search,
                  style: myTextStyleSmall(
                    context,
                  ),
                ),
                icon: Icon(
                  Icons.search,
                  color:
                  Theme.of(context).primaryColor,
                ),
                border: const OutlineInputBorder(
                  gapPadding: 2.0
                ),
                hintText: searchVehicles,
                hintStyle: myTextStyleSmallWithColor(
                    context,
                    Theme.of(context).primaryColor)),
          ),
        ),
      ],
    );
  }
}
