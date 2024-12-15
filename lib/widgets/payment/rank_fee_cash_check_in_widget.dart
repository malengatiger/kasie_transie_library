import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/commuter_cash_payment.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:uuid/v4.dart';

import '../../data/commuter_cash_check_in.dart';
import '../../data/data_schemas.dart' as lib;
import '../../utils/device_location_bloc.dart';
import '../../utils/prefs.dart';

class RankFeeCashCheckInWidget extends StatefulWidget {
  const RankFeeCashCheckInWidget(
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
  RankFeeCashCheckInWidgetState createState() =>
      RankFeeCashCheckInWidgetState();
}

class RankFeeCashCheckInWidgetState extends State<RankFeeCashCheckInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '💙💙💙💙RankFeeCashCheckInWidget 💙';
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
    pp('$mm submit $title ...');

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
    var ccp = CommuterCashCheckIn(
        commuterCashCheckInId: const UuidV4().toString(),
        vehicleId: widget.vehicle.vehicleId,
        vehicleReg: widget.vehicle.vehicleReg,
        associationId: widget.vehicle.associationId,
        associationName: widget.vehicle.associationName,
        amount: double.parse(amountController.text),
        userId: user!.userId,
        userName: '${user.firstName} ${user.lastName}',
        created: DateTime.now().toUtc().toIso8601String(),
        position: null,
        receiptBucketFileName: '');
    try {
      var res = await dataApiDog.addCommuterCashCheckIn(ccp);
      pp('$mm $title submitted OK: ${res.toJson()}');
      if (mounted) {
        showToast(message: '$title submitted OK', context: context);
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

  onReceiptPhoto() async {
    pp('$mm take photo of receipt ...');
  }

  static const title = 'Rank Fee Cash CheckIn';
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
                  RankFeeCashCheckInForm(
                    globalKey: mKey,
                    amountController: amountController,
                    onSubmit: () {
                      _onSubmit();
                    },
                    onReceiptPhoto: () {
                      onReceiptPhoto();
                    },
                  ),
                ],
              ),
              busy
                  ? const Positioned(
                      child: TimerWidget(
                          title: 'Saving $title', isSmallSize: true),
                    )
                  : gapH32,
            ],
          ),
        ));
  }
}

class RankFeeCashCheckInForm extends StatelessWidget {
  const RankFeeCashCheckInForm(
      {super.key,
      required this.globalKey,
      required this.amountController,
      required this.onSubmit,
      required this.onReceiptPhoto});
  final GlobalKey<FormState> globalKey;
  final TextEditingController amountController;
  final Function onSubmit;
  final Function onReceiptPhoto;

  static const title = 'Rank Fee Cash CheckIn';
  @override
  Widget build(BuildContext context) {
    return Form(
      key: globalKey,
      child: Column(
        children: [
          gapH32,
          Text(title,
            style: myTextStyleMediumLarge(context, 24),
          ),
          gapH32,
          TextFormField(
            keyboardType: TextInputType.number,
            style: myTextStyleMediumLarge(context, 36),
            decoration: const InputDecoration(
              hintText: "$title  Amount",
              label: Text('$title Amount'),
            ),
            validator: (value) {
              if (value == null) {
                return 'Please enter $title  Amount';
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
                onReceiptPhoto();
              },
              child: const Text('Take Receipt Photo')),
          gapH32,
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
