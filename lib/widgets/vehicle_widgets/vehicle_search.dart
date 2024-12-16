import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';

import '../../bloc/list_api_dog.dart';
import '../../utils/emojis.dart';
import '../../utils/prefs.dart';

class VehicleSearch extends StatefulWidget {
  const VehicleSearch({
    super.key,
    required this.associationId,
  });

  final String associationId;
  @override
  State<VehicleSearch> createState() => _VehicleSearchState();
}

class _VehicleSearchState extends State<VehicleSearch> {
  static const mm = '🍎🍎🍎🍎🍎 VehicleSearch';
  final TextEditingController _textEditingController = TextEditingController();
  String search = 'Search';
  String searchVehicles = 'Search Vehicles';
  List<lib.Vehicle> carsPicked = [];
  List<lib.Vehicle> cars = [];
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

  bool busy = false;
  lib.User? user;

  @override
  void initState() {
    super.initState();
    _getCars(false);
  }

  final _carPlates = <String>[];
  var carsToDisplay = <lib.Vehicle>[];

  _getCars(bool refresh) async {
    setState(() {
      busy = true;
    });

    try {
      cars = await listApiDog.getAssociationCars(widget.associationId!, refresh);
      cars.sort((a, b) => a.vehicleReg!.compareTo(b.vehicleReg!));
      _setCarPlates();
    } catch (e,s) {
      pp('$mm Error: $e - $s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  void _setCarPlates() {
    _carPlates.clear();
    carsToDisplay.clear();
    for (var element in cars) {
      _carPlates.add(element.vehicleReg!);
      carsToDisplay.add(element);
    }

    pp('$mm ..... cars to process: ${cars.length}');
  }

  lib.Vehicle? _findVehicle(String carPlate) {
    for (var car in cars) {
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
      for (var project in cars) {
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
    setState(() {});
  }

  lib.Vehicle? vehicle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Find Taxi'),
          actions: [
            IconButton(onPressed: (){
              _getCars(true);
            }, icon: const FaIcon(FontAwesomeIcons.arrowsRotate))
          ],
        ),
        backgroundColor: Colors.brown[100],
        body: SafeArea(
            child: Stack(
          children: [
            Column(
              children: [
                vehicle == null
                    ? gapH32
                    : Text(
                        '${vehicle!.vehicleReg}',
                        style: myTextStyleMediumLarge(context, 28),
                      ),
                gapH8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                            label: Text(
                              search,
                              style: myTextStyle(),
                            ),
                            icon: Icon(
                              Icons.search,
                              color: Theme.of(context).primaryColor,
                            ),
                            border: const OutlineInputBorder(gapPadding: 2.0),
                            hintText: searchVehicles,
                            hintStyle: myTextStyleSmallWithColor(
                                context, Theme.of(context).primaryColor)),
                      ),
                    ),
                    gapW32
                  ],
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: bd.Badge(
                    badgeContent: Text(
                      '${carsToDisplay.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    badgeStyle: const bd.BadgeStyle(
                        elevation: 16.0, padding: EdgeInsets.all(16.0)),
                    position: bd.BadgePosition.topEnd(top: -64, end: 4),
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3),
                        itemCount: carsToDisplay.length,
                        itemBuilder: (_, index) {
                          var c = carsToDisplay[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                vehicle = c;
                              });
                              Navigator.pop(context, vehicle);
                            },
                            child: Card(
                              elevation: 8,
                              child: Center(
                                  child: Text(
                                '${c.vehicleReg}',
                                style: myTextStyle(fontSize: 16, weight: FontWeight.w900),
                              )),
                            ),
                          );
                        }),
                  ),
                )),
                // gapH32,

              ],
            ),
            busy? const Positioned(child: Center(
                child: TimerWidget(title: 'Loading vehicles ...', isSmallSize: true))): gapH4,
          ],
        )));
  }
}
