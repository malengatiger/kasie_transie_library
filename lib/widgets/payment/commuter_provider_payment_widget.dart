import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/commuter_provider_payment.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:uuid/v4.dart';

import '../../data/data_schemas.dart' as lib;
import '../../data/payment_provider.dart';
import '../../utils/prefs.dart';

class CommuterProviderPaymentWidget extends StatefulWidget {
  const CommuterProviderPaymentWidget(
      {super.key,
      required this.vehicle,
      required this.route,
      required this.payment,
      required this.onError});

  final lib.Vehicle vehicle;
  final lib.Route route;
  final Function(CommuterProviderPayment) payment;
  final Function(String) onError;

  @override
  CommuterProviderPaymentWidgetState createState() =>
      CommuterProviderPaymentWidgetState();
}

class CommuterProviderPaymentWidgetState
    extends State<CommuterProviderPaymentWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '💙💙💙💙CommuterProviderPaymentWidget 💙';
  final TextEditingController amountController = TextEditingController();
  final TextEditingController passengersController = TextEditingController();

  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  List<PaymentProvider> providers = [];
  GlobalKey<FormState> mKey = GlobalKey();
  bool busy = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    _getProviders();
  }

  PaymentProvider? paymentProvider;
  Future _getProviders() async {
    setState(() {
      busy = true;
    });
    try {
      providers = await listApiDog.getPaymentProviders();
    } catch (e) {
      if (mounted) {
        showErrorToast(
            message: "Payment Providers failed: $e", context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  Future _onSubmit() async {
    setState(() {
      busy = true;
    });
    if (!mKey.currentState!.validate()) {
      return;
    }
    pp('$mm submitting Commuter Provider Payment ...');
    if (paymentProvider == null) {
      showErrorToast(
          message: 'Please select Payment Provider', context: context);
      return;
    }
    if (!mKey.currentState!.validate()) {
      return;
    }
    DeviceLocationBloc bloc = GetIt.instance<DeviceLocationBloc>();
    var loc = await bloc.getLocation();
    var user = prefs.getUser();
    var ccp = CommuterProviderPayment(
      commuterProviderPaymentId: const UuidV4().toString(),
      paymentProvider: paymentProvider!,
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
      created: DateTime.now().toUtc().toIso8601String(),
      position: lib.Position(coordinates: [loc.longitude, loc.latitude]),
    );
    try {
      var res = await dataApiDog.addCommuterProviderPayment(ccp);
      pp('$mm $title submitted successfully. ${res.toJson()}');
      if (mounted) {
        showToast(message: '$title submitted successfully', context: context);
      }
    } catch (e) {
      if (mounted) {
        showErrorToast(message: "$title failed: $e", context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  static const title = 'Commuter Provider Payment';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  CommuterProviderPaymentForm(
                    globalKey: mKey,
                    amountController: amountController,
                    passengersController: passengersController,
                    onSubmit: () {
                      _onSubmit();
                    },
                    providerName: '',
                  ),
                ],
              ),
              busy
                  ? const Positioned(
                      child: TimerWidget(
                          title: 'Saving Commuter provider payment ...',
                          isSmallSize: true),
                    )
                  : gapH32,
            ],
          ),
        ));
  }
}

class CommuterProviderPaymentForm extends StatelessWidget {
  const CommuterProviderPaymentForm(
      {super.key,
      required this.globalKey,
      required this.amountController,
      required this.passengersController,
      required this.onSubmit,
      required this.providerName});
  final GlobalKey<FormState> globalKey;
  final TextEditingController amountController;
  final TextEditingController passengersController;
  final Function onSubmit;
  final String providerName;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: globalKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Amount",
              label: Text('Amount'),
            ),
            validator: (value) {
              if (value == null) {
                return 'Please enter amount';
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
          Text(providerName),
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
