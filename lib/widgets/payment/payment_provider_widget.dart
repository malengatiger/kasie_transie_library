import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/commuter_cash_payment.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/country_selection.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:uuid/v4.dart';

import '../../bloc/list_api_dog.dart';
import '../../data/commuter_cash_check_in.dart';
import '../../data/data_schemas.dart' as lib;
import '../../data/data_schemas.dart';
import '../../data/payment_provider.dart';
import '../../utils/device_location_bloc.dart';
import '../../utils/prefs.dart';

class PaymentProviderWidget extends StatefulWidget {
  const PaymentProviderWidget({
    super.key,
    this.paymentProvider,
  });

  final PaymentProvider? paymentProvider;

  @override
  PaymentProviderWidgetState createState() => PaymentProviderWidgetState();
}

class PaymentProviderWidgetState extends State<PaymentProviderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '💙💙💙💙PaymentProviderWidget 💙';
  final TextEditingController providerNameController = TextEditingController();
  final TextEditingController baseUrlController = TextEditingController();
  final TextEditingController sandboxUrlController = TextEditingController();

  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();

  Prefs prefs = GetIt.instance<Prefs>();
  List<Country> countries = [];
  Country? country;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getCountries();
    _populate();
  }

  _populate() {
    if (widget.paymentProvider != null) {
      providerNameController.text =
          widget.paymentProvider!.paymentProviderName!;
      baseUrlController.text = widget.paymentProvider!.baseUrl!;
      sandboxUrlController.text = widget.paymentProvider!.sandboxUrl!;
    }
  }

  _getCountries() async {
    setState(() {
      busy = true;
    });
    countries = await listApiDog.getCountries();
    pp('$mm ${countries.length} countries found');
    setState(() {
      busy = false;
    });
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

    if (country == null) {
      showErrorToast(
          message: 'Please select the country of the $title', context: context);
      return;
    }
    var user = prefs.getUser();

    final PaymentProvider paymentProvider = PaymentProvider(
      paymentProviderId: const UuidV4().toString(),
      created: DateTime.now().toUtc().toIso8601String(),
      paymentProviderName: providerNameController.text,
      baseUrl: baseUrlController.text,
      sandboxUrl: sandboxUrlController.text,
      countryId: country!.countryId,
      countryName: country!.name,
    );

    if (widget.paymentProvider != null) {
      var res = await dataApiDog.updatePaymentProvider(ccp);
      pp('$mm $title submitted OK: ${res.toJson()}');
    } else {

    }
    try {
      var res = await dataApiDog.addPaymentProvider(ccp);
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

  static const title = 'Payment Provider';

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
                  gapH32,
                  CountrySearch(onCountrySelected: (c) {
                    setState(() {
                      country = c;
                    });
                  }),
                  gapH32,
                  PaymentProviderForm(
                    globalKey: mKey,
                    providerNameController: providerNameController,
                    baseUrlController: baseUrlController,
                    sandboxUrlController: sandboxUrlController,
                    onSubmit: () {
                      _onSubmit();
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

class PaymentProviderForm extends StatelessWidget {
  const PaymentProviderForm({
    super.key,
    required this.globalKey,
    required this.onSubmit,
    required this.providerNameController,
    required this.baseUrlController,
    required this.sandboxUrlController,
  });

  final GlobalKey<FormState> globalKey;
  final TextEditingController providerNameController;
  final TextEditingController baseUrlController;
  final TextEditingController sandboxUrlController;

  final Function onSubmit;
  static const title = 'Payment Provider';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: globalKey,
      child: Column(
        children: [
          gapH32,
          Text(
            '$title Form',
            style: myTextStyleMediumLarge(context, 24),
          ),
          gapH32,
          TextFormField(
            keyboardType: TextInputType.number,
            style: myTextStyleMediumLarge(context, 36),
            decoration: const InputDecoration(
              hintText: title,
              label: Text('$title Amount'),
            ),
            validator: (value) {
              if (value == null) {
                return 'Please enter $title Name';
              }
              return null;
            },
          ),
          gapH32,
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
