import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/commuter_cash_payment.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:uuid/v4.dart';

import '../../data/data_schemas.dart' as lib;
import '../../data/rank_fee_cash_payment.dart';
import '../../utils/device_location_bloc.dart';
import '../../utils/prefs.dart';

class RankFeeCashPaymentWidget extends StatefulWidget {
  const RankFeeCashPaymentWidget(
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
  RankFeeCashPaymentWidgetState createState() =>
      RankFeeCashPaymentWidgetState();
}

class RankFeeCashPaymentWidgetState extends State<RankFeeCashPaymentWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '💙💙💙💙RankFeeCashPaymentWidget 💙';
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
    pp('$mm submitting $title ...');

    var user = prefs.getUser();
    DeviceLocationBloc bloc = GetIt.instance<DeviceLocationBloc>();
    var loc = await bloc.getLocation();
    var rfPayment = RankFeeCashPayment(
        rankFeeCashPaymentId: const UuidV4().toString(),
        vehicleId: widget.vehicle.vehicleId,
        vehicleReg: widget.vehicle.vehicleReg,
        associationId: widget.vehicle.associationId,
        associationName: widget.vehicle.associationName,
        amount: double.parse(amountController.text),
        userId: user!.userId,
        userName: '${user.firstName} ${user.lastName}',
        position: lib.Position(coordinates: [
          loc.longitude,
          loc.latitude,
        ]),
        created: DateTime.now().toUtc().toIso8601String());
    try {
      var res = await dataApiDog.addRankFeeCashPayment(rfPayment);
      pp('$mm $title is OK: ${res.toJson()}');
      if (mounted) {
        showToast(message: '$title submitted', context: context);
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

  static const title = 'RankFee Cash Payment';

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
                  RankFeeCashPaymentForm(
                      globalKey: mKey,
                      amountController: amountController,
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

class RankFeeCashPaymentForm extends StatelessWidget {
  const RankFeeCashPaymentForm(
      {super.key,
      required this.globalKey,
      required this.amountController,
      required this.onSubmit});

  final GlobalKey<FormState> globalKey;
  final TextEditingController amountController;
  final Function onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: globalKey,
      child: Column(
        children: [
          gapH32,
          Text(
            'Rank Fee Form',
            style: myTextStyleMediumLarge(context, 24),
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Please enter amount",
              label: Text('Amount'),
            ),
            validator: (value) {
              if (value == null) {
                return 'Please enter the Rank Fee amount';
              }
              return null;
            },
          ),
          gapH16,
          gapH32,
          ElevatedButton(
              style: const ButtonStyle(
                elevation: WidgetStatePropertyAll(8),
                padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
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
