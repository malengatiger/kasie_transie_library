import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';

import '../../bloc/sem_cache.dart';
import '../../utils/prefs.dart';

class TopUpFuel extends StatefulWidget {
  const TopUpFuel({
    super.key,
    required this.vehicle,
    required this.isLandscape,
  });

  final Vehicle vehicle;
  final bool isLandscape;

  @override
  TopUpFuelState createState() => TopUpFuelState();
}

class TopUpFuelState extends State<TopUpFuel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🖐🖐🏽🖐🏽🖐🏽🖐🏽🖐🏽 TopUpFuel: 🖐🏽🖐🏽';

  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  SemCache semCache = GetIt.instance<SemCache>();

  Prefs prefs = GetIt.instance<Prefs>();
  DeviceLocationBloc dlb = GetIt.instance<DeviceLocationBloc>();

  bool busy = false;
  String? startDate, endDate;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getFuelBrands(false);
  }

  List<FuelTopUp> fuelTopUps = [];
  List<FuelBrand> fuelBrands = [];
  FuelBrand? fuelBrand;

  _getFuelBrands(bool refresh) async {
    setState(() {
      busy = true;
    });
    try {
      fuelBrands = await listApiDog.getFuelBrands(refresh);
      pp('$mm ... fuelBrands found : ${fuelBrands.length}');
      for (var c in fuelBrands) {
        litreControllers.add(TextEditingController(text: "0"));
        amountControllers.add(TextEditingController(text: "0"));
      }
    } catch (e, s) {
      pp('$e $s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  _submit(FuelBrand fuelBrand, int index) async {
    setState(() {
      busy = true;
    });
    pp('\n\n$mm ... ........... submit ...');
    try {
      var loc = await dlb.getLocation();
      var pos =
          Position(coordinates: [loc.longitude, loc.latitude], type: 'Point');
      pp('$mm ... ........... create FuelTopUp ...');

      var ft = FuelTopUp(
          fuelTopUpId: DateTime.now().toUtc().toIso8601String(),
          vehicleId: widget.vehicle.vehicleId!,
          vehicleReg: widget.vehicle.vehicleReg!,
          fuelBrandId: fuelBrands[index].fuelBrandId,
          brandName: fuelBrands[index].brandName,
          userId: null,
          userName: null,
          associationId: widget.vehicle.associationId,
          associationName: widget.vehicle.associationName,
          amount: double.parse(amountControllers[index].text),
          numberOfLitres: double.parse(litreControllers[index].text),
          position: pos);
      pp('$mm ... ........... send FuelTopUp ...');
      var result = await dataApiDog.addFuelTopUp(ft);
      pp('$mm ... result: ${result.toJson()}');
      if (mounted) {
        Navigator.of(context).pop();
        showOKToast(message: 'Fuel TopUp saved', context: context);
      }
    } catch (e, s) {
      pp('$mm $e $s');
      if (mounted) {
        showErrorToast(message: 'Failed to submit: $e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool showForm = false;
  double? amount, litres;
  bool showClose = false;
  NumberFormat nf = NumberFormat('###,###,##0.0');
  NumberFormat af = NumberFormat('###,###,##0.00');

  List<TextEditingController> litreControllers = [];
  List<TextEditingController> amountControllers = [];

  @override
  Widget build(BuildContext context) {
    if (widget.isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }

    double dataFilledIn(int index) {
      var ok1 = double.parse(amountControllers[index].text );
      var ok2 = double.parse(litreControllers[index].text );
      var checker = 0;
      if (ok1 > 0) {
        checker++;
      }
      if (ok2 > 0) {
        checker++;
      }
      if (checker == 2) {
        return 120;
      }

      return 72.0;
    }

    return widget.isLandscape
        ? Scaffold(
            appBar: AppBar(title: Text('Taxi Fuel TopUp')),
            body: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ListView.builder(
                      itemCount: fuelBrands.length,
                      itemBuilder: (_, index) {
                        var fb = fuelBrands[index];
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {});
                              },
                              child: Image.network(fb.logoUrl!,
                                  height: 64, width: 64),
                            ),
                            gapW32,
                            SizedBox(
                              width: 120,
                              child: TextFormField(
                                controller: litreControllers[index],
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                style: myTextStyleBold(fontSize: 16),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Please enter litres',
                                  label: Text('Litres of Fuel'),
                                ),
                              ),
                            ),
                            gapW32,
                            GestureDetector(
                              onTap: () {
                                setState(() {});
                              },
                              child: SizedBox(
                                width: 120,
                                child: TextFormField(
                                  controller: amountControllers[index],
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  style: myTextStyleBold(fontSize: 16),
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Please enter amount',
                                      label: Text('Total Amount')),
                                ),
                              ),
                            ),
                            gapW32,
                            if (double.parse(amountControllers[index].text) >
                                    0 &&
                                double.parse(litreControllers[index].text) > 0)
                              ElevatedButton(
                                style: ButtonStyle(
                                    elevation: WidgetStatePropertyAll(8),
                                    backgroundColor:
                                        WidgetStatePropertyAll(Colors.blue)),
                                onPressed: () {
                                  _submit(fb, index);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('Submit TopUp',
                                      style: myTextStyle(color: Colors.white)),
                                ),
                              ),
                          ],
                        );
                      }),
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(title: Text('Taxi Fuel TopUp')),
            body: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ListView.builder(
                      itemCount: fuelBrands.length,
                      itemBuilder: (_, index) {
                        var fb = fuelBrands[index];
                        return Card(
                            elevation: 4,
                            child: SizedBox(
                                height:  dataFilledIn(index),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showSubmit = true;
                                            });
                                          },
                                          child: Image.network(fb.logoUrl!,
                                              height: 64, width: 64),
                                        ),
                                        gapW8,
                                        SizedBox(
                                          width: 80,
                                          child: TextFormField(
                                            controller: litreControllers[index],
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            style:
                                                myTextStyleBold(fontSize: 16),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: 'Please enter litres',
                                              label: Text('Litres'),
                                            ),
                                          ),
                                        ),
                                        gapW8,
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {});
                                          },
                                          child: SizedBox(
                                            width: 80,
                                            child: TextFormField(
                                              controller:
                                                  amountControllers[index],
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: true),
                                              style:
                                                  myTextStyleBold(fontSize: 16),
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  hintText:
                                                      'Please enter amount',
                                                  label: Text('Amount')),
                                            ),
                                          ),
                                        ),
                                        showSubmit
                                            ? ElevatedButton(
                                          style: ButtonStyle(
                                              elevation:
                                              WidgetStatePropertyAll(8),
                                              backgroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.blue)),
                                          onPressed: () {
                                            _submit(fb, index);
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Text('Submit',
                                                style: myTextStyle(
                                                    color: Colors.white)),
                                          ),
                                        )
                                            : gapW32,
                                      ],
                                    ),
                                  ],
                                )));
                      }),
                ),
              ],
            ),
          );
  }

  bool showSubmit = false;
}
