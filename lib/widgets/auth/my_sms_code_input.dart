import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../l10n/translation_handler.dart';
import '../../utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';

class MySmsCodeInput extends StatefulWidget {
  const MySmsCodeInput({Key? key, required this.onSMSCode}) : super(key: key);
  final Function(String) onSMSCode;

  @override
  State<MySmsCodeInput> createState() => _MySmsCodeInputState();
}

class _MySmsCodeInputState extends State<MySmsCodeInput> {
  final mm = '🥬🥬🥬🥬🥬🥬😡 MySmsCodeInput: 😡';

  final sb = StringBuffer();
  String enterCode = 'Enter SMS Code';
  @override
  void initState() {
    super.initState();
    _setTexts();
  }

  void _setTexts() async {
    final c = await prefs.getColorAndLocale();
    enterCode = await translator.translate('enterCode', c.locale);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final codeController = TextEditingController();
    final errorController = StreamController<ErrorAnimationType>();
    return Card(
      elevation: 8,
      shape: getRoundedBorder(radius: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 48, height: 48, child: Image.asset('assets/gio.png')),
            const SizedBox(
              height: 64,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                enterCode,
                style: myTextStyleMediumLargeWithColor(
                    context, Theme.of(context).primaryColorLight, 18),
              ),
            ),
            const SizedBox(
              height: 48,
            ),
            Card(
              elevation: 8,
              shape: getRoundedBorder(radius: 16),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: PinCodeTextField(
                  length: 6,
                  obscureText: false,
                  textStyle: myTextStyleMediumLargeWithColor(
                      context, Colors.black, 20),
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 60,
                    fieldWidth: 48,
                    activeFillColor: Theme.of(context).primaryColorLight,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  backgroundColor: Theme.of(context).colorScheme.background,
                  enableActiveFill: true,
                  errorAnimationController: errorController,
                  controller: codeController,
                  onCompleted: (v) {
                    pp("$mm PinCodeTextField: Completed: $v - should call submit ...");
                    widget.onSMSCode(v);
                  },
                  onChanged: (value) {
                    pp(value);
                  },
                  beforeTextPaste: (text) {
                    pp("$mm Allowing to paste $text");
                    //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                    //but you can show anything you want here, like your pop up saying wrong paste format or etc
                    return true;
                  },
                  appContext: context,
                ),
              ),
            ),
            const SizedBox(
              height: 48,
            ),
          ],
        ),
      ),
    );
  }

  void _onKeyboardTap(String text) {}
}
