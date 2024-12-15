import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lm;
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:badges/badges.dart' as bd;
import 'package:kasie_transie_library/widgets/vehicle_widgets/car_details.dart';
import 'package:kasie_transie_library/widgets/scanners/scan_vehicle_for_owner.dart';
import 'package:page_transition/page_transition.dart';

import '../../bloc/sem_cache.dart';
import '../../l10n/translation_handler.dart';
import '../../utils/navigator_utils.dart';
import '../../utils/prefs.dart';

class CarList extends StatefulWidget {
  const CarList({super.key, this.associationId, this.ownerId});

  final String? associationId, ownerId;

  @override
  CarListState createState() => CarListState();
}

class CarListState extends State<CarList>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  final mm = '🌎🌎🌎🌎🌎🌎CarList 🍐🍐';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();

  bool busy = false;
  var cars = <lm.Vehicle>[];
  var carsToDisplay = <lm.Vehicle>[];
  bool showCarDetails = false;
  bool _showSearch = false;
  SemCache semCache = GetIt.instance<SemCache>();

  // late StreamSubscription<bool> compSubscription;
  lm.Vehicle? car;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _getVehicles(false);
  }

  void _getVehicles(bool refresh) async {
    pp('$mm ........... _getVehicles  ');

    setState(() {
      busy = true;
    });
    try {
      if (widget.associationId != null) {
        cars = await semCache.getVehicles(widget.associationId!);
      }
      if (widget.ownerId != null) {
        cars = await listApiDog.getOwnerVehicles(widget.ownerId!, refresh);
      }
      //
      cars.sort((a, b) => a.vehicleReg!.compareTo(b.vehicleReg!));

      _carPlates.clear();
      for (var element in cars) {
        _carPlates.add(element.vehicleReg!);
        carsToDisplay.add(element);
      }
      if (cars.length > 19) {
        _showSearch = true;
      }
      pp('$mm ..... cars found: ${cars.length}');
    } catch (e, stack) {
      pp('$mm $e - $stack');
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
    if (getThisDeviceType() == 'phone') {
      _navigateToCarDetails();
      return;
    }
    setState(() {
      showCarDetails = true;
      _showSearch = false;
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
  Prefs prefs = GetIt.instance<Prefs>();

  Future _setTexts() async {
    final col = prefs.getColorAndLocale();
    search = await translator.translate("search", col.locale);
    searchVehicles = await translator.translate("search", col.locale);
    vehicles = await translator.translate("vehicles", col.locale);
  }

  void _navigateToScanner() async {
    NavigationUtils.navigateTo(
        context: context,
        widget: const ScanVehicleForOwner(),
        );
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
    if (cars.length > 20) {
      _showSearch = true;
    }
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                vehicles == null ? 'Vehicles' : vehicles!,
                style: myTextStyleLarge(context),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      _getVehicles(true);
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).primaryColor,
                    )),
                IconButton(
                    onPressed: () {
                      _navigateToScanner();
                    },
                    icon: Icon(
                      Icons.airport_shuttle,
                      color: Theme.of(context).primaryColor,
                    ))
              ],
              bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(48), child: Column()),
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: _showSearch ? 100 : 8,
                            ),
                            cars.isEmpty
                                ? Center(
                                    child: SizedBox(
                                      height: 120,
                                      child: Column(
                                        children: [
                                          Text(
                                            'No cars found',
                                            style:
                                                myTextStyleMediumLargeWithColor(
                                                    context,
                                                    Theme.of(context)
                                                        .primaryColorLight,
                                                    24),
                                          ),
                                          const SizedBox(
                                            height: 32,
                                          ),
                                          SizedBox(
                                            width: 320,
                                            child: ElevatedButton.icon(
                                                onPressed: () {
                                                  _navigateToScanner();
                                                },
                                                icon: const Icon(
                                                    Icons.airport_shuttle),
                                                label: const Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Text('Scan Vehicle'),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    child: bd.Badge(
                                      badgeContent: Text('${cars.length}'),
                                      badgeStyle: bd.BadgeStyle(
                                          badgeColor: Colors.green[900]!,
                                          padding: const EdgeInsets.all(12)),
                                      child: ListView.builder(
                                          itemCount: carsToDisplay.length,
                                          itemBuilder: (ctx, index) {
                                            final car =
                                                carsToDisplay.elementAt(index);
                                            return GestureDetector(
                                              onTap: () {
                                                _onCarSelected(car);
                                              },
                                              child: Card(
                                                shape: getRoundedBorder(
                                                    radius: 16),
                                                elevation: 4,
                                                child: ListTile(
                                                  title: Text(
                                                    '${car.vehicleReg}',
                                                    style:
                                                        myTextStyleMediumBold(
                                                            context),
                                                  ),
                                                  subtitle: Text(
                                                    '${car.make} ${car.model} - ${car.year}',
                                                    style: myTextStyleSmall(
                                                        context),
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
                showCarDetails
                    ? Positioned(
                        top: -48,
                        bottom: 0,
                        child: CarDetails(
                          vehicle: car!,
                          onClose: () {
                            setState(() {
                              showCarDetails = false;
                              if (cars.length > 19) {
                                _showSearch = true;
                              }
                            });
                          },
                        ))
                    : const SizedBox(),
                _showSearch
                    ? Positioned(
                        top: 0,
                        child: SizedBox(
                          height: 100,
                          child: Row(
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
                                            color:
                                                Theme.of(context).primaryColor,
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
                          ),
                        ))
                    : const SizedBox()
              ],
            )));
  }

  void _navigateToCarDetails() {
    if (car == null) {
      return;
    }
    NavigationUtils.navigateTo(
        context: context,
        widget: CarDetails(
          vehicle: car!,
          onClose: () {
            setState(() {
              showCarDetails = false;
              if (cars.length > 19) {
                _showSearch = true;
              }
            });
          },
        ),
        );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
