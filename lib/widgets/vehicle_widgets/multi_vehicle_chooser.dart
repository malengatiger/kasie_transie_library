
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:badges/badges.dart' as bd;
import 'package:kasie_transie_library/widgets/vehicle_widgets/vehicle_search.dart';
import '../../l10n/translation_handler.dart';
import '../../utils/emojis.dart';

class MultiVehicleChooser extends StatefulWidget {
  const MultiVehicleChooser(
      {super.key, required this.onVehiclePicked, required this.vehicles, required this.vehiclesToHighlight});

  final List<lib.Vehicle> vehicles;
  final List<lib.Vehicle> vehiclesToHighlight;

  final Function(lib.Vehicle) onVehiclePicked;

  @override
  MultiVehicleChooserState createState() => MultiVehicleChooserState();
}

class MultiVehicleChooserState extends State<MultiVehicleChooser> with AutomaticKeepAliveClientMixin{
  final mm = '🔷🔷🔷 MultiVehicleChooser: ${E.appleRed}';

  var list = <lib.Vehicle>[];
  String selectCars = 'Select Vehicles';

  @override
  void initState() {
    super.initState();
    pp('$mm ... initState: list of cars: ${widget.vehicles.length} ......');
    _control();
  }

  void _control() async {
    await _setTexts();
    _setList();
    setState(() {});
  }

  void _setList() {
    list = widget.vehicles;
    pp('$mm ... _setCheckList: list of cars: ${list.length} ......');

    setState(() {

    });
  }

  Prefs prefs = GetIt.instance<Prefs>();

  Future _setTexts() async {
    final c =  prefs.getColorAndLocale();
    final loc = c.locale;
    selectCars = await translator.translate('selectCars', loc);
    selectedCars = await translator.translate('selectedCars', loc);
    showCars = await translator.translate('', loc);
    setState(() {});
  }

  var selectedCars = 'Selected Vehicles';
  var showCars = 'Show Vehicles';

  @override
  Widget build(BuildContext context) {
    final type = getThisDeviceType();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        gapH16,

       // widget.vehicles.length < 25? gapH32: VehicleSearch(cars: widget.vehicles, carsFound: (carsFound){
       //   setState(() {
       //     list = carsFound;
       //   });
       // }),
        const SizedBox(
          height: 8,
        ),
        Expanded(
          child: bd.Badge(
            badgeContent: Text('${list.length}', style: myTextStyleTiny(context),),
            badgeStyle: const bd.BadgeStyle(
                elevation: 16.0,
                padding: EdgeInsets.all(8.0)),
            position: bd.BadgePosition.topEnd(top: -12, end: -12),
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemCount: list.length,
                itemBuilder: (ctx, index) {
                  final car = list.elementAt(index);
                  var color = Colors.white;
                  for (var value in widget.vehiclesToHighlight) {
                    if (value.vehicleId == car.vehicleId) {
                      color = Colors.tealAccent;
                    }
                  }
                  return GestureDetector(
                    onTap: () {
                      widget.onVehiclePicked(car);
                    },
                    child: Card(
                      shape: getRoundedBorder(radius: 8),
                      elevation: 12,
                      child: SizedBox(height: 48,
                        child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.airport_shuttle, color: color,),
                            gapH4,
                            Text(
                              '${car.vehicleReg}',
                              style: myTextStyleSmall(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
