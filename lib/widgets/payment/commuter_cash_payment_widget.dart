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
      required this.payment,
      required this.onError});

  final lib.Vehicle vehicle;
  final lib.Route route;
  final Function(CommuterCashPayment) payment;
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
    pp('$mm submitting Commuter Cash Payment ...');

    var user = prefs.getUser();
    DeviceLocationBloc bloc = GetIt.instance<DeviceLocationBloc>();
    var loc = await bloc.getLocation();
    var ccp = CommuterCashPayment(
        commuterCashPaymentId: const UuidV4().toString(),
        vehicleId: widget.vehicle.vehicleId,
        vehicleReg: widget.vehicle.vehicleReg,
        associationId: widget.vehicle.associationId,
        associationName: widget.vehicle.associationName,
        amount: double.parse(amountController.text),
        numberOfPassengers: int.parse(passengersController.text),
        userId: user!.userId,
        userName: '${user.firstName} ${user.lastName}',
        routeName:  widget.route.name,
        routeId: widget.route.routeId,
        position: lib.Position(coordinates: [loc.longitude, loc.latitude,]),
        created: DateTime.now().toUtc().toIso8601String());
    try {
      var res = await dataApiDog.addCommuterCashPayment(ccp);
      pp('$mm Commuter Cash Payment is OK: ${res.toJson()}');
      if (mounted) {
        showToast(message: 'Commuter Cash Payment submitted', context: context);
      }
    } catch (e) {
      if (mounted) {
        showErrorToast(message: "Cash Payment failed: $e", context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Commuter Cash Payment'),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  CommuterCashPaymentForm(
                      globalKey: mKey,
                      amountController: amountController,
                      passengersController: passengersController,
                      onSubmit: () {
                        _onSubmit();
                      }),
                ],
              ),
              busy
                  ? const Positioned(
                      child: TimerWidget(
                          title: 'Saving Commuter cash payment',
                          isSmallSize: true),
                    )
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
    return Form(
      key: globalKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Please enter amount",
              label: Text('Amount'),
            ),
            validator: (value) {
              if (value == null) {
                return 'Not working, Jack!';
              }
              return null;
            },
          ),
          gapH16,
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Number of Passengers",
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
          ElevatedButton(
              style: const ButtonStyle(
                elevation: WidgetStatePropertyAll(8),padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
              ),
              onPressed: () {
                onSubmit();
              },
              child: const Text('Submit'))
        ],
      ),
    );
  }
}
