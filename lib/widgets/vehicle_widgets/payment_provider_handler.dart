import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/commuter_provider_payment.dart';
import 'package:kasie_transie_library/data/rank_fee_provider_payment.dart';

import '../../data/payment_provider.dart';

class PaymentProviderHandler extends StatefulWidget {
  const PaymentProviderHandler({super.key, required this.paymentProvider, this.rankFeeProviderPayment, this.commuterProviderPayment});

  final PaymentProvider paymentProvider;
  final RankFeeProviderPayment? rankFeeProviderPayment;
  final CommuterProviderPayment? commuterProviderPayment;
  @override
  PaymentProviderHandlerState createState() => PaymentProviderHandlerState();
}

class PaymentProviderHandlerState extends State<PaymentProviderHandler>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Provider Handler'),
      ),
      body: const SafeArea(
        child: Stack(
          children: [
            Center(child: Text('Payment Provider Handler'))
          ],
        ),
      )
    );
  }
}
