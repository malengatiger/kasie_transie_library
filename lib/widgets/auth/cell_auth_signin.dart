import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/color_and_locale.dart';
import 'package:kasie_transie_library/widgets/auth/sign_in_landing.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';

import '../../auth/phone_auth_signin.dart';
import '../../bloc/list_api_dog.dart';
import '../../data/schemas.dart' as lib;
import '../../isolates/country_cities_isolate.dart';
import '../../isolates/routes_isolate.dart';
import '../../isolates/vehicles_isolate.dart';
import '../../l10n/translation_handler.dart';
import '../../utils/emojis.dart';
import '../../utils/functions.dart';
import '../../utils/navigator_utils.dart';
import '../../utils/prefs.dart';
import '../language_and_color_chooser.dart';
import 'my_sms_code_input.dart';

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

class CustomPhoneVerificationState extends State<CustomPhoneVerification>
    implements PhoneAuthListener {
  final mm = '🥬🥬🥬🥬🥬🥬😡 CustomPhoneVerification: 😡';

  @override
  final auth = fb.FirebaseAuth.instance;
  @override
  late ui.PhoneAuthProvider provider;

  String? verificationId;
  fb.ConfirmationResult? confirmationResult;

  String loading = 'Loading data';
  String waiting = 'Wait data', notRegistered = '';
  bool _showVerifier = false;
  bool busy = false;
  bool verificationCompleted = false;
  final firebaseAuth = fb.FirebaseAuth.instance;
  final phoneController = TextEditingController(text: "+19095550008");
  final codeController = TextEditingController(text: "123456");

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
    provider = ui.PhoneAuthProvider();
    provider.auth = fb.FirebaseAuth.instance;
    provider.authListener = this;
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

  late Widget child = PhoneInput(
    initialCountryCode: 'US',
    onSubmit: (phoneNumber) {
      pp('$mm ...................... ${E.redDot} onSubmit; phoneNumber: $phoneNumber');

      provider.sendVerificationCode(
          phoneNumber: phoneNumber, action: AuthAction.signIn);
    },
  );

  @override
  Future<void> onCodeSent(String verificationId,
      [int? forceResendToken]) async {
    this.verificationId = verificationId;
    pp('\n\n$mm ...................... ${E.redDot} onCodeSent; verificationId: $verificationId');
    _initializeData();
  }

  bool initializing = false;
  Future _initializeData() async {
    pp('$mm ...................... ${E.redDot} _initializeData; '
        '\n ${E.blueDot} verificationId: $verificationId ${E.blueDot} smsCode: $smsCode');
    if (smsCode == null) {
      pp('$mm ...................... ${E.redDot} _initializeData; quitting, sms-code is null');
      return;
    }

    setState(() {
      initializing = true;
    });
    fb.UserCredential? userCred;

    try {
      fb.PhoneAuthCredential authCredential = fb.PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: smsCode!);
      userCred =
          await fb.FirebaseAuth.instance.signInWithCredential(authCredential);
      pp('\n$mm user signed in to firebase? userCred: $userCred');

      lib.User? mUser;
      pp('$mm seeking to acquire this user from the Kasie database by their id: 🌀🌀🌀${userCred.user?.uid}');
      if (userCred.user != null) {
        mUser = await listApiDog.getUserById(userCred.user!.uid);
      }

      if (mUser != null) {
        pp('$mm KasieTransie user found on database:  🍎 ${mUser.name} 🍎');
        myPrettyJsonPrint(mUser.toJson());
        await prefs.saveUser(mUser);
        final ass = await listApiDog.getAssociationById(mUser.associationId!);
        await prefs.saveAssociation(ass);

        try {
          await vehicleIsolate.getVehicles(mUser.associationId!);
          await routesIsolate.getRoutes(mUser.associationId!);
          final countries = await listApiDog.getCountries();
          lib.Country? myCountry;
          for (var country in countries) {
            if (country.countryId == ass.countryId!) {
              myCountry = country;
              await prefs.saveCountry(myCountry);

              break;
            }
          }
          //
          pp('$mm KasieTransie countries found on database:  🍎 ${countries.length} 🍎');
          pp('$mm KasieTransie; my country the beloved:  🍎 ${myCountry!.name!} 🍎');
          await countryCitiesIsolate.getCountryCities(myCountry.countryId!);
          //
          setState(() {
            initializing = false;
          });
          widget.onUserAuthenticated(mUser);
        } catch (e) {
          pp(e);
        }
      } else {
        widget.onError();
      }
    } catch (e) {
      pp(e);
    }
    return 0;
  }

  @override
  void onConfirmationRequested(fb.ConfirmationResult result) {
    confirmationResult = result;
    pp('$mm ... onConfirmationRequested: ${result.verificationId}');
  }

  String? cellphoneNumber, smsCode;
  @override
  void onSMSCodeRequested(String phoneNumber) {
    pp('$mm ... onSMSCodeRequested, phoneNumber: $phoneNumber');
    cellphoneNumber = phoneNumber;
    setState(() {
      child = MySmsCodeInput(
        onSMSCode: (smsCode) async {
          pp('$mm ...onSMSCodeRequested:  SMSCodeInput ${E.blueDot} onSubmit: $smsCode provider: ${provider.providerId}'
              ' ${E.redDot} verificationId: $verificationId');
          this.smsCode = smsCode;
          if (verificationId != null) {
            pp('$mm ...onSMSCodeRequested:  verificationId: $verificationId');
            await _initializeData();
          }
        },
      );
    });
  }

  @override
  void onVerificationCompleted(fb.PhoneAuthCredential credential) {
    pp('$mm ... onVerificationCompleted, credential: $credential');

    provider.onCredentialReceived(credential, AuthAction.signIn);
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
      // appBar: AppBar(
      //   title: Text(signInStrings == null
      //       ? 'Phone Authentication'
      //       : signInStrings!.phoneAuth),
      // ),
      body: _showVerifier
          ? Center(
              child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                  children: [
                    child,
                    initializing
                        ? Positioned(
                            left: 2,
                            right: 2,
                            top: 8,
                            bottom: 8,
                            child: TimerWidget(
                              title: loading,
                            ))
                        : const SizedBox()
                  ],
                ),
              ),
            ))
          : Center(
              child: Card(
                shape: getDefaultRoundedBorder(),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SignInLanding(
                      welcome: welcome,
                      firstTime: firstTime,
                      changeLanguage: changeLanguage,
                      signInWithPhone: signInWithPhone,
                      startEmailLinkSignin: '',
                      onNavigateToEmailAuth: () {},
                      onNavigateToPhoneAuth: () {
                        setState(() {
                          _showVerifier = true;
                        });
                      },
                      onNavigateToColor: () {
                        _navigateToColor();
                      }),
                ),
              ),
            ),
    ));
  }

  @override
  void onBeforeProvidersForEmailFetch() {
    pp('$mm ... onBeforeProvidersForEmailFetch');

    setState(() {
      child = const CircularProgressIndicator();
    });
  }

  @override
  void onBeforeSignIn() {
    pp('$mm ... onBeforeSignIn');

    setState(() {
      child = const CircularProgressIndicator();
    });
  }

  @override
  void onCanceled() {
    pp('$mm ... onCanceled');
    widget.onCancel();
  }

  @override
  void onCredentialLinked(fb.AuthCredential credential) {
    pp('$mm ... onCredentialLinked ... navigate to ??? credential: $credential');
  }

  @override
  void onDifferentProvidersFound(
      String email, List<String> providers, fb.AuthCredential? credential) {
    showDifferentMethodSignInDialog(
      context: context,
      availableProviders: providers,
      providers: FirebaseUIAuth.providersFor(fb.FirebaseAuth.instance.app),
    );
  }

  @override
  void onError(Object error) {
    pp('$mm ...... ERROR: ${E.redDot} $error ${E.redDot}${E.redDot}${E.redDot}');
    try {
      // tries default recovery strategy
      //defaultOnAuthError(provider, error);
    } catch (err) {
      setState(() {
        //defaultOnAuthError(provider, error);
      });
    }
  }

  @override
  Future<void> onSignedIn(fb.UserCredential credential) async {
    pp('\n\n$mm ...... onSignedIn: ${E.blueDot} credential: '
        '$credential ${E.leaf}${E.leaf}${E.leaf} - doin nuthin!');
  }

  @override
  void onCredentialReceived(fb.AuthCredential credential) {
    pp('$mm onCredentialReceived ');
  }

  @override
  void onMFARequired(fb.MultiFactorResolver resolver) {
    pp('$mm onMFARequired ');
  }
}
