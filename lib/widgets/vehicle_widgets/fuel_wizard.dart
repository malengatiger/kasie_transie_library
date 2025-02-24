import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../bloc/data_api_dog.dart';
import '../../bloc/list_api_dog.dart';
import '../../bloc/sem_cache.dart';
import '../../data/data_schemas.dart';
import '../../utils/device_location_bloc.dart';
import '../../utils/functions.dart';
import '../../utils/prefs.dart';

class FuelWizard extends StatefulWidget {
  const FuelWizard({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  FuelWizardState createState() => FuelWizardState();
}

class FuelWizardState extends State<FuelWizard>
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
  TextEditingController litreController = TextEditingController(text: '0');
  TextEditingController amountController = TextEditingController(text: '0');

  _getFuelBrands(bool refresh) async {
    setState(() {
      busy = true;
    });
    try {
      fuelBrands = await listApiDog.getFuelBrands(refresh);
      pp('$mm ... fuelBrands found : ${fuelBrands.length}');
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

  _submit() async {
    setState(() {
      busy = true;
    });
    pp('\n\n$mm ... ........... submit fuel top up ..');
    try {
      var loc = await dlb.getLocation();
      var pos =
          Position(coordinates: [loc.longitude, loc.latitude], type: 'Point');
      pp('$mm ... ........... create FuelTopUp ...');

      var ft = FuelTopUp(
          fuelTopUpId: DateTime.now().toUtc().toIso8601String(),
          vehicleId: widget.vehicle.vehicleId!,
          vehicleReg: widget.vehicle.vehicleReg!,
          fuelBrandId: fuelBrand!.fuelBrandId!,
          brandName: fuelBrand!.brandName!,
          userId: null,
          userName: null,
          associationId: widget.vehicle.associationId,
          associationName: widget.vehicle.associationName,
          amount: double.parse(amountController.text),
          numberOfLitres: double.parse(litreController.text),
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
  GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel TopUp'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5),
                  itemCount: fuelBrands.length,
                  itemBuilder: (_, index) {
                    var fb = fuelBrands[index];
                    return GestureDetector(
                      onTap: () {
                        pp('... tapped: ${fb.brandName}');
                        setState(() {
                          showForm = true;
                          fuelBrand = fb;
                          litreController = TextEditingController(text: '0');
                          amountController = TextEditingController(text: '0');
                        });
                      },
                      child: Card(
                          elevation: 4,
                          child: Image.network(fb.logoUrl!,
                              height: 100, width: 100)),
                    );
                  }),
            ),
            showForm
                ? Positioned(
                    bottom: 24,
                    child: Center(
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Form(
                                key: key,
                                child: Column(
                                  children: [
                                    fuelBrand == null
                                        ? gapW32
                                        : Image.network(fuelBrand!.logoUrl!,
                                            height: 128, width: 128),
                                    gapH32,
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 24),
                                      child: Card(
                                        elevation: 8,
                                        child: SizedBox(
                                          width: 300,
                                          child: Padding(
                                            padding: EdgeInsets.all(16),
                                            child: TextFormField(
                                              onChanged: (t) {
                                                pp('... litres changed: $t');
                                                setState(() {
                                                  setSubmit();
                                                });
                                              },
                                              controller: litreController,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: true),
                                              style:
                                                  myTextStyleBold(fontSize: 28),
                                              decoration: const InputDecoration(
                                                hintText: 'Litres',
                                                label: Text('Litres'),
                                              ),
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Please enter Litres';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 24),
                                      child: Card(
                                        elevation: 8,
                                        child: SizedBox(
                                          width: 300,
                                          child: Padding(
                                            padding: EdgeInsets.all(16),
                                            child: TextFormField(
                                              onChanged: (t) {
                                                pp('... amount changed: $t');
                                                setState(() {
                                                  setSubmit();
                                                });
                                              },
                                              controller: amountController,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: true),
                                              style:
                                                  myTextStyleBold(fontSize: 28),
                                              decoration: const InputDecoration(
                                                hintText: 'Amount',
                                                label: Text('Amount'),
                                              ),
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Please enter Amount';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    gapH32,
                                    showSubmit
                                        ? SizedBox(
                                            width: 300,
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  _submit();
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Colors.pink),
                                                  elevation:
                                                      MaterialStatePropertyAll(
                                                          8.0),
                                                ),
                                                child: Text(
                                                  'Submit',
                                                  style: myTextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                )),
                                          )
                                        : gapW32,
                                  ],
                                )))))
                : Positioned(
                    bottom: 240,
                    left: 48,
                    child: Center(
                      child: Text(
                        'Please select Fuel Brand',
                        style: myTextStyleBold(fontSize: 20, color: Colors.grey),
                      ),
                    )),
            busy? Positioned(child: Center(child: CircularProgressIndicator(
              strokeWidth: 6, backgroundColor: Colors.red,
            ))): gapW32,
          ],
        ),
      ),
    );
  }

  bool showSubmit = false;
  setSubmit() {
    pp('....... shouldSubmit?');
    try {
      int cnt = 0;
      if (double.parse(litreController.text) > 0) {
        cnt++;
      }
      if (double.parse(amountController.text) > 0) {
        cnt++;
      }
      if (cnt == 2) {
        pp('....... shouldSubmit? : 😝😝😝😝 YES ');
        setState(() {
          showSubmit = true;
        });
        return;
      }
      setState(() {
        showSubmit = false;
      });
    } catch (e) {
      pp(e);
    }
  }
}
