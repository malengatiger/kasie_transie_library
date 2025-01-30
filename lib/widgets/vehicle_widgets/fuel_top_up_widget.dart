import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';

import '../../utils/prefs.dart';

class FuelTopUpWidget extends StatefulWidget {
  const FuelTopUpWidget(
      {Key? key, required this.vehicle, required this.isLandscape})
      : super(key: key);

  final Vehicle vehicle;
  final bool isLandscape;

  @override
  FuelTopUpWidgetState createState() => FuelTopUpWidgetState();
}

class FuelTopUpWidgetState extends State<FuelTopUpWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🖐🏽🖐🏽🖐🏽🖐🏽🖐🏽🖐🏽 FuelTopUpWidget: 🖐🏽🖐🏽';

  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  DeviceLocationBloc dlb = GetIt.instance<DeviceLocationBloc>();

  bool busy = false;
  String? startDate, endDate;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getFuelBrands();
  }

  List<FuelTopUp> fuelTopUps = [];
  List<FuelBrand> fuelBrands = [];
  FuelBrand? fuelBrand;

  _getFuelBrands() async {
    setState(() {
      busy = true;
    });
    try {
      fuelBrands = await listApiDog.getFuelBrands();
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
    pp('\n\n$mm ... ........... submit ...');
    try {
      var user = prefs.getUser();
      var loc = await dlb.getLocation();
      var pos =
          Position(coordinates: [loc.longitude, loc.latitude], type: 'Point');
      pp('$mm ... ........... create FuelTopUp ...');

      var ft = FuelTopUp(
          fuelTopUpId: DateTime.now().toUtc().toIso8601String(),
          vehicleId: widget.vehicle.vehicleId!,
          vehicleReg: widget.vehicle.vehicleReg!,
          fuelBrandId: fuelBrand!.fuelBrandId,
          brandName: fuelBrand!.brandName,
          userId: widget.isLandscape? null: user!.userId,
          userName:  widget.isLandscape? null: '${user!.firstName} ${user.lastName}',
          associationId: widget.vehicle.associationId,
          associationName: widget.vehicle.associationName,
          amount: amount,
          numberOfLitres: litres,
          position: pos);
      pp('$mm ... ........... send FuelTopUp ...');
      var result = await dataApiDog.addFuelTopUp(ft);
      pp('$mm ... result: ${result.toJson()}');
      showClose = true;
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

  _displayForm() async {
    if (fuelBrand == null) {
      return;
    }
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return AlertDialog(
              title: Text(
                "${widget.vehicle.vehicleReg}",
                style: myTextStyleBold(fontSize: widget.isLandscape ? 16 : 24),
              ),
              content: widget.isLandscape
                  ? FuelFormLandscape(
                      litresController: litresController,
                      amountController: amountController,
                      onSubmit: () {
                        setState(() {});
                        Navigator.of(context).pop();
                        pp('$mm calling submit from dialog');
                        _submit();
                      },
                      formKey: formKey,
                      fuelBrand: fuelBrand!)
                  : FuelForm(
                      litresController: litresController,
                      amountController: amountController,
                      onSubmit: () {
                        amount = double.parse(amountController.text);
                        litres = double.parse(litresController.text);
                        setState(() {});
                        Navigator.of(context).pop();
                        _submit();
                      },
                      formKey: formKey,
                      fuelBrand: fuelBrand!,
                    ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close')),
              ]);
        });
  }

  double? amount, litres;
  bool showClose = false;
  NumberFormat nf = NumberFormat('###,###,##0.0');
  NumberFormat af = NumberFormat('###,###,##0.00');

  @override
  Widget build(BuildContext context) {
    if (widget.isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Fuel TopUp ...'),
        ),
        body: SafeArea(
            child: Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: BrandSelector(
                    fuelBrands: fuelBrands,
                    isLandscape: widget.isLandscape,
                    onPicked: (brand) {
                      pp('$mm tapped: ${brand.toJson()}');
                      setState(() {
                        fuelBrand = brand;
                      });
                      _displayForm();
                    }),
              ),
              widget.isLandscape ? SizedBox() : gapH32,
              widget.isLandscape ? SizedBox() : gapH32,
              widget.isLandscape ? SizedBox() : gapH32,
              fuelBrand == null
                  ? gapW32
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 64),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundImage: NetworkImage(fuelBrand!.logoUrl!),
                          ),
                          gapW32,
                          Text('${fuelBrand!.brandName}'),
                        ],
                      ),
                    ),
              gapH32,
              litres == null
                  ? gapW32
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Litres'),
                        gapW16,
                        Text(nf.format(litres!),
                            style: myTextStyleBold(fontSize: 24)),
                        gapW32,
                      ],
                    ),
              amount == null
                  ? gapW32
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Amount'),
                        gapW16,
                        Text(af.format(amount!),
                            style: myTextStyleBold(fontSize: 32)),
                        gapW32,
                      ],
                    ),
              Expanded(
                  child: ListView.builder(
                      itemCount: fuelTopUps.length,
                      itemBuilder: (_, index) {
                        var ft = fuelTopUps[index];
                        return Card(
                            elevation: 8,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('Amount'),
                                  Text('${ft.amount}'),
                                  gapW32,
                                  Text('Litres'),
                                  Text('${ft.numberOfLitres}'),
                                  gapW32,
                                  Text('${ft.created}'),
                                ],
                              ),
                            ));
                      }))
            ],
          ),
          showClose
              ? Positioned(
                  bottom: 16,
                  right: 16,
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Done')))
              : gapW32,
          busy
              ? Positioned(
                  child: Center(
                      child: CircularProgressIndicator(
                  strokeWidth: 6,
                  backgroundColor: Colors.pink,
                )))
              : gapW32,
        ])));
  }

  final TextEditingController litresController = TextEditingController(),
      amountController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
}

class BrandSelector extends StatelessWidget {
  const BrandSelector(
      {super.key,
      required this.fuelBrands,
      required this.onPicked,
      required this.isLandscape});

  final List<FuelBrand> fuelBrands;
  final Function(FuelBrand) onPicked;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          height: isLandscape ? 64 : 200,
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isLandscape ? 6 : 3),
              itemCount: fuelBrands.length,
              itemBuilder: (_, index) {
                var b = fuelBrands[index];
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        pp(' ... onPicked: ${b.toJson()}');
                        onPicked(b);
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(b.logoUrl!),
                      ),
                    ),
                    Text(b.brandName!),
                  ],
                );
              }),
        ),
      ),
    );
  }
}

class FuelForm extends StatelessWidget {
  const FuelForm(
      {super.key,
      required this.litresController,
      required this.amountController,
      required this.onSubmit,
      required this.formKey,
      required this.fuelBrand});

  final TextEditingController litresController, amountController;
  final Function() onSubmit;
  final GlobalKey<FormState> formKey;
  final FuelBrand fuelBrand;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 360,
        child: Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(fuelBrand!.logoUrl!),
                    ),
                    gapW32,
                    Text('${fuelBrand!.brandName}'),
                  ],
                ),
                gapH32,
                TextFormField(
                  controller: litresController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: myTextStyleBold(fontSize: 20),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Please enter litres',
                    label: Text('Litres of Fuel'),
                  ),
                ),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: myTextStyleBold(fontSize: 28),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Please enter amount',
                      label: Text('Total Amount')),
                ),
                gapH32,
                gapH32,
                ElevatedButton(
                  style: ButtonStyle(
                      elevation: WidgetStatePropertyAll(12),
                      backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                  onPressed: () {
                    onSubmit();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child:
                        Text('Submit', style: myTextStyle(color: Colors.white)),
                  ),
                )
              ],
            )));
  }
}

class FuelFormLandscape extends StatelessWidget {
  const FuelFormLandscape(
      {super.key,
      required this.litresController,
      required this.amountController,
      required this.onSubmit,
      required this.formKey,
      required this.fuelBrand});

  final TextEditingController litresController, amountController;
  final Function() onSubmit;
  final GlobalKey<FormState> formKey;
  final FuelBrand fuelBrand;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 340,
        child: Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        controller: litresController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        style: myTextStyleBold(fontSize: 20),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Please enter litres',
                          label: Text('Litres of Fuel'),
                        ),
                      ),
                    ),
                    gapW32,
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        controller: amountController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        style: myTextStyleBold(fontSize: 28),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Please enter amount',
                            label: Text('Total Amount')),
                      ),
                    )
                  ],
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      elevation: WidgetStatePropertyAll(12),
                      backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                  onPressed: () {
                    onSubmit();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child:
                        Text('Submit TopUp', style: myTextStyle(color: Colors.white)),
                  ),
                ),

              ],
            )));
  }
}
