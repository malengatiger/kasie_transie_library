import 'package:currency_formatter/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/data/rank_fee_cash_payment.dart';
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:kasie_transie_library/widgets/vehicle_widgets/payment_provider_handler.dart';
import 'package:page_transition/page_transition.dart';
import 'package:uuid/v4.dart';

import '../../bloc/data_api_dog.dart';
import '../../bloc/list_api_dog.dart';
import '../../data/payment_provider.dart';
import '../../data/rank_fee_provider_payment.dart';
import '../../isolates/local_finder.dart';
import '../photo_handler.dart';

class RankFeeSender extends StatefulWidget {
  const RankFeeSender({super.key, required this.vehicle});

  final lib.Vehicle vehicle;

  @override
  RankFeeSenderState createState() => RankFeeSenderState();
}

class RankFeeSenderState extends State<RankFeeSender>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  DeviceLocationBloc locationBloc = GetIt.instance<DeviceLocationBloc>();
  static const mm = '☘️☘️☘️☘️☘️RankFeeSender ☘️';

  final DataApiDog _dataApiDog = GetIt.instance<DataApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  PaymentProvider? paymentProvider;
  List<PaymentProvider> paymentProviders = [];
  String? dispatchText,
      selectRouteText,
      scannerWaiting,
      cancelText,
      working,
      dispatchTaxi,
      confirmDispatch,
      no,
      yes,
      dispatchFailed,
      allPhotosVideos;
  lib.User? user;

  bool busy = false;

  Future _setTexts() async {
    final c = prefs.getColorAndLocale();
    final loc = c.locale;
    dispatchText = await translator.translate('dispatch', loc);
    selectRouteText = await translator.translate('pleaseSelectRoute', loc);
    scannerWaiting = await translator.translate('scannerWaiting', loc);
    cancelText = await translator.translate('cancel', loc);
    working = await translator.translate('working', loc);
    confirmDispatch = await translator.translate('confirmDispatch', loc);
    no = await translator.translate('no', loc);
    yes = await translator.translate('yes', loc);
    dispatchTaxi = await translator.translate('dispatchTaxi', loc);

    setState(() {});
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _getPaymentProviders();
  }

  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  CurrencyFormat euroSettings = const CurrencyFormat(
    code: 'za',
    symbol: 'R',
    symbolSide: SymbolSide.left,
    thousandSeparator: ',',
    decimalSeparator: '.',
    symbolSeparator: ' ',
  );

  String msg = 'loading Payment Providers ...';

  _getPaymentProviders() async {
    setState(() {
      busy = true;
    });
    try {
      paymentProviders = await listApiDog.getPaymentProviders();
    } catch (e, s) {
      pp('$mm $e %s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
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

  Future<lib.RouteLandmark?> findNearestLandmark(Position loc) async {
    final m = await localFinder.findNearestRouteLandmark(
        latitude: loc.latitude, longitude: loc.longitude, radiusInMetres: 200);
    if (m != null) {
      pp('$mm ... findNearestLandmark found: ${m.landmarkName} ${E.pear}  route: ${m.routeName}');
    }
    return m;
  }

  int passengerCount = 0;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController amtController = TextEditingController();

  Future<void> _sendRankFee() async {
    pp('$mm ... _sendRankFee ... paymentProviderName: ${paymentProvider?.paymentProviderName}');
    late RankFeeCashPayment rankFeePayment;
    if (!formKey.currentState!.validate()) {
      return;
    }
    if (paymentProvider != null) {
      showToast(
          backgroundColor: Colors.amber.shade900,
          textStyle: myTextStyle(color: Colors.white),
          message: 'Payment provider feature under construction. Use Cash Payment', context: context);
      setState(() {
        paymentProvider = null;
      });
      return;
    }
    user = prefs.getUser();
    final loc = await locationBloc.getLocation();
    pp('$mm ... _sendRankFee ... ${loc.latitude} ${loc.longitude}');

    lib.RouteLandmark? mark = await findNearestLandmark(loc);
    if (paymentProvider != null) {
      var rfpp = RankFeeProviderPayment(
          rankFeeProviderPaymentId: const UuidV4().generate(),
          vehicleId: widget.vehicle.vehicleId,
          vehicleReg: widget.vehicle.vehicleReg,
          associationId: widget.vehicle.associationId,
          associationName: widget.vehicle.associationName,
          amount: amount,
          numberOfPassengers: 0,
          userId: user!.userId,
          userName: '${user!.firstName} ${user!.lastName}',
          paymentProvider: paymentProvider,
          position: lib.Position(coordinates: [loc.longitude, loc.latitude]),
          created: DateTime.now().toUtc().toIso8601String());
      if (mounted) {
        var result = await NavigationUtils.navigateTo(
          context: context,
          widget: PaymentProviderHandler(
            paymentProvider: paymentProvider!,
            rankFeeProviderPayment: rfpp,
          ),
        );
        if (result != null) {
          if (mounted) {
            showToast(
                padding: 24,
                backgroundColor: Colors.green.shade900,
                duration: const Duration(seconds: 3),
                textStyle: const TextStyle(color: Colors.white),
                message:
                    '${widget.vehicle.vehicleReg} - Rank Fee sent OK with amount $formattedAmount',
                context: context);
          }
        }
        if (mounted) {
          Navigator.of(context).pop(result);
        }
      }
      return;
    }
    try {
      msg = 'Sending RankFeeCashPayment to backend ...';
      setState(() {
        busy = true;
      });

      rankFeePayment = RankFeeCashPayment(
          rankFeeCashPaymentId: const UuidV4().generate(),
          userId: user!.userId,
          userName: '${user!.firstName} ${user!.lastName}',
          created: DateTime.now().toUtc().toIso8601String(),
          vehicleId: widget.vehicle!.vehicleId,
          vehicleReg: widget.vehicle!.vehicleReg,
          associationId: widget.vehicle!.associationId,
          associationName: widget.vehicle!.associationName,
          position: lib.Position(
            type: 'Point',
            coordinates: [loc.longitude, loc.latitude],
            latitude: loc.latitude,
            longitude: loc.longitude,
          ),
          landmarkName: mark?.landmarkName,
          routeLandmarkId: mark?.landmarkId,
          amount: double.parse(amtController.text));
      //
      var res = await _dataApiDog.addRankFeeCashPayment(rankFeePayment);
      pp('$mm ... _sendRankFee ... sent ..... ${res.toJson()}');

      if (mounted) {
        showToast(
            padding: 24,
            backgroundColor: Colors.green.shade900,
            duration: const Duration(seconds: 3),
            textStyle: const TextStyle(color: Colors.white),
            message:
                '${widget.vehicle.vehicleReg} - Rank Fee sent OK with amount $formattedAmount',
            context: context);
        Navigator.of(context).pop(res);
      }
    } catch (e, s) {
      pp('$e $s');
    }
    setState(() {
      busy = false;
    });
  }

  bool showPaymentProvider = false;
  bool isPaymentProvider = true;
  String? formattedAmount;
  double? amount;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
          title: Text(
            'Rank Fees',
            style: myTextStyleMedium(context),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  NavigationUtils.navigateTo(
                      context: context,
                      widget: PhotoHandler(
                        vehicle: widget.vehicle,
                        onPhotoTaken: (image, thumb) {},
                      ));
                },
                icon: const FaIcon(FontAwesomeIcons.camera))
          ]),
      body: SizedBox(
        width: width,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  gapH32, gapH32,
                  Text(
                    'Rank Fees',
                    style: myTextStyle(fontSize: 28, weight: FontWeight.w900),
                  ),
                  Text(
                    '${widget.vehicle.vehicleReg}',
                    style: myTextStyle(
                        color: Colors.pink,
                        fontSize: 28,
                        weight: FontWeight.w400),
                  ),
                  gapH4,
                  SizedBox(
                    height: 120,
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                autofocus: true,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        signed: false, decimal: true),
                                controller: amtController,
                                decoration: InputDecoration(
                                  label: const Text(
                                      'Tap to enter Vehicle Rank Fee'),
                                  enabled: true,
                                  border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.horizontal()),
                                  hintText: 'Enter Vehicle Rank Fee',
                                  hintStyle: myTextStyle(),
                                ),
                                style: myTextStyle(
                                    fontSize: 20,
                                    weight: FontWeight.w300,
                                    color: Colors.green.shade900),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      double.parse(value) == 0) {
                                    return 'Please a enter an amount greater than 0';
                                  }
                                  return null;
                                },
                                onChanged: (text) {
                                  String formatted = CurrencyFormatter.format(
                                      double.parse(text),
                                      euroSettings); // 1.910,93 €
                                  setState(() {
                                    formattedAmount = formatted;
                                    amount = double.parse(text);
                                  });
                                },
                              ),
                            ],
                          )),
                    ),
                  ),
                  gapH4,
                  const Text('Select Payment Provider if needed'),
                  paymentProvider == null
                      ? Text(
                          'Cash Payment',
                          style: myTextStyle(
                              fontSize: 28, weight: FontWeight.w900),
                        )
                      : Text(
                          '${paymentProvider!.paymentProviderName}',
                          style: myTextStyle(
                              fontSize: 28, weight: FontWeight.w900),
                        ),
                  SizedBox(
                    height: paymentProviders.length * 120,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView.builder(
                        itemCount: paymentProviders.length,
                        itemBuilder: (_, index) {
                          var pp = paymentProviders[index];
                          return GestureDetector(
                            onTap: () {
                              if (paymentProvider != null) {
                                setState(() {
                                  paymentProvider = null;
                                });
                              } else {
                                setState(() {
                                  paymentProvider = pp;
                                });
                              }
                            },
                            child: Card(
                                elevation: 8,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text('${pp.paymentProviderName}',
                                      style: myTextStyle(
                                          fontSize: 20,
                                          weight: FontWeight.normal)),
                                )),
                          );
                        },
                      ),
                    ),
                  ),

                  gapH32,
                  formattedAmount == null
                      ? gapH4
                      : Text(formattedAmount!,
                          style: myTextStyle(
                              color: Colors.green.shade800,
                              fontSize: 48,
                              weight: FontWeight.w200)),
                  gapH8,
                  amount == null
                      ? gapW32
                      : ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.blue),
                              elevation: WidgetStatePropertyAll(8.0)),
                          onPressed: () {
                            _sendRankFee();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Submit Rank Fee',
                              style: myTextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  weight: FontWeight.normal),
                            ),
                          ),
                        ),
                  // gapH32,
                ],
              ),
            ),
            busy
                ? Positioned(
                    child: Center(
                      child: TimerWidget(title: msg, isSmallSize: true),
                    ),
                  )
                : gapH32,
          ],
        ),
      ),
    ));
  }
}
