import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../l10n/translation_handler.dart';
import '../../utils/functions.dart';
import '../../utils/prefs.dart';


class MySmsCodeInput extends StatefulWidget {
  const MySmsCodeInput({super.key,});

  @override
  State<MySmsCodeInput> createState() => _MySmsCodeInputState();
}

class _MySmsCodeInputState extends State<MySmsCodeInput> {
  final mm = '🥬🥬🥬🥬🥬🥬😡 MySmsCodeInput: 😡';
  Prefs prefs = GetIt.instance<Prefs>();

  final sb = StringBuffer();
  String enterCode = 'Enter SMS Code';
  @override
  void initState() {
    super.initState();
    _setTexts();
  }

  void _setTexts() async {
    final c =  prefs.getColorAndLocale();
    enterCode = await translator.translate('enterCode', c.locale);
    setState(() {});
  }

  final focusNode = FocusNode();
  var enteredText = "";
  final StreamController<ErrorAnimationType> error = StreamController();

  void  closeMe(String smsCode) {
    pp('$mm ... closing SMS input; returning smsCode: $smsCode');
    Navigator.of(context).pop(smsCode);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: const Text('SMS Code Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          elevation: 8,
          shape: getDefaultRoundedBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                gapH16,
                SizedBox(
                    width: 300, height: 100, child: Image.asset('assets/ktlogo_red.png')),
                const SizedBox(
                  height: 32,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    enterCode,
                    style: myTextStyleMediumLargeWithColor(
                        context, Theme.of(context).primaryColorLight, 14),
                  ),
                ),
                gapH32,
                Card(
                  elevation: 16,
                  shape: getDefaultRoundedBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      enteredText,
                      style: myTextStyleMediumLargeWithColor(
                          context, Colors.white, 36),
                    ),
                  ),
                ),
                NumericKeyboard(
                    textColor: Theme.of(context).primaryColorLight,
                    rightIcon: Icon(
                      Icons.backspace,
                      color: Theme.of(context).primaryColor,
                    ),
                    rightButtonFn: () {
                      setState(() {
                        enteredText = '';
                      });
                    },
                    leftIcon: const Icon(
                      Icons.check,
                      size: 64,
                      color: Colors.amber,
                    ),
                    leftButtonFn: () {
                      var smsCode = enteredText.replaceAll(' ', '');
                      pp('$mm ... left button tapped; pop with : $smsCode');
                      setState(() {
                        enteredText = '';
                      });
                      closeMe(smsCode);
                    },
                    onKeyboardTap: (text) {
                      pp("$mm NumericKeyboard: onKeyboardTap: $text - should call submit ...");
                      setState(() {
                        enteredText = '$enteredText $text';
                      });
                    }),

                gapH16,
              ],
            ),
          ),
        ),
      ),
    ));
  }

}
