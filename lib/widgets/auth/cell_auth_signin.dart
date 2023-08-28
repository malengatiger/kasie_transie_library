import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/color_and_locale.dart';
import 'package:kasie_transie_library/widgets/auth/sign_in_landing.dart';

import '../../auth/phone_auth_signin.dart';
import '../../data/schemas.dart' as lib;
import '../../l10n/translation_handler.dart';
import '../../utils/functions.dart';
import '../../utils/navigator_utils.dart';
import '../../utils/prefs.dart';
import '../language_and_color_chooser.dart';
import 'my_phone_input.dart';

late ui.PhoneAuthProvider phoneAuthProvider;

class CustomPhoneVerification extends StatefulWidget {
  const CustomPhoneVerification(
      {super.key,
      required this.onUserAuthenticated,
      required this.onError,
      required this.onCancel,
      required this.onLanguageChosen});

  final Function(lib.User) onUserAuthenticated;
  final Function onError;
  final Function onCancel;
  final Function onLanguageChosen;

  @override
  State<CustomPhoneVerification> createState() =>
      CustomPhoneVerificationState();
}

class CustomPhoneVerificationState extends State<CustomPhoneVerification> {
  final mm = '🥬🥬🥬🥬🥬🥬😡 CustomPhoneVerification: 😡';


  String loading = 'Loading data';
  String waiting = 'Wait data', notRegistered = '';
  bool busy = false;

  // lib.User? user;
  SignInStrings? signInStrings;
  bool verificationFailed = false;
  String? phoneVerificationId;
  String changeLanguage = 'Change Language or Color';
  String signInWithPhone = 'Sign in with your phone';
  String firstTime = 'This is the first time here ...';
  String welcome = 'Welcome!';

  @override
  void initState() {
    super.initState();
    _control();

  }

  void _control() async {
    await _setTexts();
  }

  Future _setTexts() async {
    // signInStrings = await SignInStrings.getTranslated(sett);
    final c = await prefs.getColorAndLocale();
    loading = await translator.translate('loading', c.locale);
    waiting = await translator.translate('waiting', c.locale);
    notRegistered = await translator.translate('notRegistered', c.locale);
    firstTime = await translator.translate('firstTime', c.locale);
    changeLanguage = await translator.translate('changeLanguage', c.locale);
    welcome = await translator.translate('welcome', c.locale);
    signInWithPhone = await translator.translate('signInWithPhone', c.locale);

    setState(() {});
  }


  Future<void> _navToPhoneInput() async {
    lib.User? user = await navigateWithScale(MyPhoneInput(onPhoneNumber: (number ) {  },), context);
    pp('\n\n\n$mm .............................. back from MyPhoneInput  🍎 🍎 ');

    if (user != null) {
      myPrettyJsonPrint(user.toJson());
      //widget.onUserAuthenticated(user);
      if (mounted) {
        pp('\n\n\n$mm .............................. '
            'popping out from CustomPhoneVerification  🍎 🍎 with user: ${user.name} ');
        Navigator.of(context).pop(user);
      }
    } else {
      if (mounted) {
        showSnackBar(message: 'Something went wrong, please try again', context: context);
      }
    }
  }


  ColorAndLocale? colorAndLocale;

  Future _navigateToColor() async {
    pp('$mm _navigateToColor ......');
    await navigateWithScale(LanguageAndColorChooser(
      onLanguageChosen: () async {
        await _setTexts();
        widget.onLanguageChosen();
      },
    ), context);
    colorAndLocale = await prefs.getColorAndLocale();
    await _setTexts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: getDefaultRoundedBorder(),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SignInLanding(
                        welcome: welcome,
                        firstTime: firstTime,
                        changeLanguage: changeLanguage,
                        signInWithPhone: signInWithPhone,
                        startEmailLinkSignin: '',
                        onNavigateToEmailAuth: () {},
                        onNavigateToPhoneAuth: () {
                          _navToPhoneInput();
                        },
                        onNavigateToColor: () {
                          _navigateToColor();
                        }),
                  ),
                ),
              ),
            ),
    ));
  }


}
