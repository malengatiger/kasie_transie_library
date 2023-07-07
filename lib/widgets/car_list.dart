import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lm;
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:badges/badges.dart' as bd;
import 'package:kasie_transie_library/widgets/car_details.dart';

import '../l10n/translation_handler.dart';
import '../utils/prefs.dart';

class CarList extends StatefulWidget {
  const CarList({Key? key, this.associationId, this.ownerId}) : super(key: key);

  final String? associationId, ownerId;

  @override
  CarListState createState() => CarListState();
}

class CarListState extends State<CarList> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final mm = '🌎🌎🌎🌎🌎🌎CarList 🍐🍐';

  bool busy = false;
  var cars = <lm.Vehicle>[];
  var carsToDisplay = <lm.Vehicle>[];
  bool showCarDetails = false;
  // late StreamSubscription<bool> compSubscription;
  lm.Vehicle? car;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _setTexts();
    _getVehicles();
  }

  void _listen() async {}

  void _getVehicles() async {
    pp('$mm ........... _getVehicles  ');

    setState(() {
      busy = true;
    });
    try {
      if (widget.associationId != null) {
        cars = await listApiDog.getAssociationVehicles(
            widget.associationId!, false);
      }
      if (widget.ownerId != null) {
        cars = await listApiDog.getOwnerVehicles(widget.ownerId!, false);
      }
      //
      cars.sort((a, b) => a.vehicleReg!.compareTo(b.vehicleReg!));

      for (var element in cars) {
        _carPlates.add(element.vehicleReg!);
        carsToDisplay.add(element);
      }

      pp('$mm ..... cars found: ${cars.length}');
    } catch (e) {
      pp(e);
    }

    setState(() {
      busy = false;
    });
  }

  Future _onCarSelected(lm.Vehicle car) async {
    pp('$mm .... car selected ... will show details ...');
    myPrettyJsonPrint(car.toJson());
    this.car = car;
    myPrettyJsonPrint(car.toJson());
    setState(() {
      showCarDetails = true;
    });
  }

  bool doneInitializing = false;

  final _carPlates = <String>[];

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
    pp('$mm .... set state with projectsToDisplay: ${carsToDisplay.length} ......');
    setState(() {});
  }

  lm.Vehicle? _findVehicle(String carPlate) {
    for (var car in cars) {
      if (car.vehicleReg!.toLowerCase() == carPlate.toLowerCase()) {
        return car;
      }
    }
    pp('$mm ..................................${E.redDot} ${E.redDot} DID NOT FIND $carPlate');

    return null;
  }

  void _close() {
    pp('$mm Vehicle selected: ${car!.vehicleReg}, popping out');
    Navigator.of(context).pop(car);
  }

  String? search, searchVehicles, vehicles;
  Future _setTexts() async {
    final col = await prefs.getColorAndLocale();
    search = await translator.translate("search", col.locale);
    searchVehicles = await translator.translate("search", col.locale);
    vehicles = await translator.translate("vehicles", col.locale);

  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var height = 100.0;
    if (cars.length < 11) {
      height = 24;
    }
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(vehicles == null?
                'Vehicles': vehicles!,
                style: myTextStyleLarge(context),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      _getVehicles();
                    },
                    icon: const Icon(Icons.refresh))
              ],
              bottom: PreferredSize(
                  preferredSize:  Size.fromHeight(height),
                  child: showCarDetails? const SizedBox(): Column(
                    children: [
                       SizedBox(height: height == 100? 12:24,),
                      height == 24? const SizedBox(): Row(
                        children: [
                          SizedBox(
                            width: 300,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 12.0),
                                child: TextField(
                                  controller: _textEditingController,
                                  onChanged: (text) {
                                    pp(' ........... changing to: $text');
                                    _runFilter(text);
                                  },
                                  decoration: InputDecoration(
                                      label: Text(
                                        search == null ? 'Search' : search!,
                                        style: myTextStyleSmall(
                                          context,
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.search,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      border: const OutlineInputBorder(),
                                      hintText: searchVehicles == null
                                          ? 'Search Vehicles'
                                          : searchVehicles!,
                                      hintStyle: myTextStyleSmallWithColor(
                                          context,
                                          Theme.of(context).primaryColor)),
                                )),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          bd.Badge(
                            position: bd.BadgePosition.topEnd(),
                            badgeContent: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${carsToDisplay.length}',
                                  style: myTextStyleSmallWithColor(
                                      context, Colors.white)),
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
            body: Stack(
              children: [
                busy
                    ? const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                            backgroundColor: Colors.amber,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 8,
                              ),
                              Expanded(
                                child: bd.Badge(
                                  badgeContent: Text('${cars.length}'),
                                  badgeStyle: bd.BadgeStyle(
                                      badgeColor: Colors.green[900]!,
                                      padding: const EdgeInsets.all(12)),
                                  child: ListView.builder(
                                      itemCount: carsToDisplay.length,
                                      itemBuilder: (ctx, index) {
                                        final ass =
                                            carsToDisplay.elementAt(index);
                                        return GestureDetector(
                                          onTap: () {
                                            _onCarSelected(ass);
                                          },
                                          child: Card(
                                            shape: getRoundedBorder(radius: 16),
                                            elevation: 4,
                                            child: ListTile(
                                              title: Text(
                                                '${ass.vehicleReg}',
                                                style: myTextStyleMediumBold(
                                                    context),
                                              ),
                                              subtitle: Text(
                                                '${ass.make} ${ass.model} - ${ass.year}',
                                                style: myTextStyleSmall(context),
                                              ),
                                              leading: Icon(
                                                Icons.airport_shuttle,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                showCarDetails
                    ? Positioned(child: CarDetails(vehicle: car!, onClose: (){
                      setState(() {
                        showCarDetails = false;
                      });
                },))
                    : const SizedBox(),
              ],
            )));
  }
}
