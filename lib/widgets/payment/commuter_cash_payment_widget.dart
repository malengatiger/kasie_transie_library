import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/commuter_cash_payment.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:uuid/v4.dart';

import '../../data/data_schemas.dart' as lib;
import '../../utils/device_location_bloc.dart';
import '../../utils/prefs.dart';

class CommuterCashPaymentWidget extends StatefulWidget {
  const CommuterCashPaymentWidget(
      {super.key,
      required this.vehicle,
      required this.route,
      required this.onError});

  final lib.Vehicle vehicle;
  final lib.Route route;
  final Function(String) onError;

  @override
  CommuterCashPaymentWidgetState createState() =>
      CommuterCashPaymentWidgetState();
}

class CommuterCashPaymentWidgetState extends State<CommuterCashPaymentWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '💙💙💙💙CommuterCashPaymentWidget 💙';
  final TextEditingController amountController = TextEditingController();
  final TextEditingController passengersController = TextEditingController();

  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  GlobalKey<FormState> mKey = GlobalKey();
  bool busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future _onSubmit() async {
    setState(() {
      busy = true;
    });
    if (!mKey.currentState!.validate()) {
      return;
    }

    try {
      var user = prefs.getUser();
      DeviceLocationBloc bloc = GetIt.instance<DeviceLocationBloc>();
      var loc = await bloc.getLocation();
      var payment = CommuterCashPayment(
          commuterCashPaymentId: const UuidV4().generate(),
          vehicleId: widget.vehicle.vehicleId,
          vehicleReg: widget.vehicle.vehicleReg,
          associationId: widget.vehicle.associationId,
          associationName: widget.vehicle.associationName,
          amount: double.parse(amountController.text),
          numberOfPassengers: int.parse(passengersController.text),
          userId: user!.userId,
          userName: '${user.firstName} ${user.lastName}',
          routeName: widget.route.name,
          routeId: widget.route.routeId,
          position: lib.Position(type: 'Point', coordinates: [
            loc.longitude,
            loc.latitude,
          ]),
          created: DateTime.now().toUtc().toIso8601String());
      pp('$mm ....... submitting Commuter Cash Payment ... ');
      myPrettyJsonPrint(payment.toJson());

      var res =  dataApiDog.addCommuterCashPayment(payment);
      pp('$mm Commuter Cash Payment is OK');
      if (mounted) {
        showOKToast(
            duration: const Duration(seconds: 2),
            message: 'Commuter Cash Payment submitted successfully',
            context: context);
        Navigator.of(context).pop();
      }

    } catch (e, s) {
      pp('$e $s');
      if (mounted) {
        showErrorToast(message: "Cash Payment failed: $e", context: context);
      }
      widget.onError('Cash Payment failed: $e');
    }
    setState(() {
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Commuter Payment',
            style: myTextStyle(),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Commuter Cash Payment',
                      style: myTextStyle(fontSize: 20),
                    ),
                    gapH32,
                    Text('${widget.vehicle.vehicleReg}',
                        style:
                            myTextStyle(fontSize: 36, weight: FontWeight.w900)),
                    gapH8,
                    Text(
                      '${widget.route.name}',
                      style: myTextStyle(fontSize: 20, color: Colors.grey),
                    ),
                    gapH32,
                    Expanded(
                      child: CommuterCashPaymentForm(
                          globalKey: mKey,
                          amountController: amountController,
                          passengersController: passengersController,
                          onSubmit: () {
                            _onSubmit();
                          }),
                    ),
                    gapH32,
                  ],
                ),
              ),
              // Positioned(
              //     right: 16, bottom: 16,
              //     child: SizedBox(
              //   width: 300,
              //   child: Padding(
              //     padding: const EdgeInsets.all(16),
              //     child: ElevatedButton(
              //         onPressed: () {
              //           Navigator.of(context).pop();
              //         },
              //         child: const Text('Done')),
              //   ),
              // )),
              busy
                  ? const Positioned(
                      child: Center(
                      child: TimerWidget(
                          title: 'Saving Commuter cash payment',
                          isSmallSize: true),
                    ))
                  : gapH32,
            ],
          ),
        ));
  }
}

class CommuterCashPaymentForm extends StatelessWidget {
  const CommuterCashPaymentForm(
      {super.key,
      required this.globalKey,
      required this.amountController,
      required this.passengersController,
      required this.onSubmit});

  final GlobalKey<FormState> globalKey;
  final TextEditingController amountController;
  final TextEditingController passengersController;
  final Function onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: globalKey,
        child: Expanded(
          child: Column(
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                style: myTextStyle(fontSize: 28, weight: FontWeight.w900),
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2),
                  ),
                  hintText: "Please enter amount",
                  label: Text('Amount'),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Enter proper amount';
                  }
                  return null;
                },
              ),
              gapH16,
              TextFormField(
                controller: passengersController,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                style: myTextStyle(fontSize: 28, weight: FontWeight.w900),
                decoration: const InputDecoration(
                  hintText: "EnterNumber of Passengers",
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  label: Text('Number of Passengers'),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please enter number of passengers';
                  }
                  return null;
                },
              ),
              gapH32,
              gapH32,
              gapH32,
              gapH32,
              SizedBox(
                width: 300,
                child: ElevatedButton(
                    style: const ButtonStyle(
                      elevation: WidgetStatePropertyAll(8),
                      backgroundColor: WidgetStatePropertyAll(Colors.blue),
                      padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
                    ),
                    onPressed: () {
                      onSubmit();
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Submit Payment',
                            style: myTextStyle(
                                fontSize: 20, color: Colors.white)))),
              ),
              gapH32,
            ],
          ),
        ),
      ),
    );
  }
}
