import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:mobile_number/mobile_number.dart';

import '../../auth/phone_auth_signin.dart';
import '../../bloc/list_api_dog.dart';
import '../../data/schemas.dart' as lib;
import '../../isolates/routes_isolate.dart';
import '../../isolates/vehicles_isolate.dart';
import '../../l10n/translation_handler.dart';
import '../../utils/emojis.dart';
import '../../utils/functions.dart';
import '../../utils/prefs.dart';
import 'my_sms_code_input.dart';

late ui.PhoneAuthProvider phoneAuthProvider;

class CustomPhoneVerification extends StatefulWidget {
  const CustomPhoneVerification({super.key});

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
  String waiting = 'Wait data';

  @override
  void initState() {
    super.initState();
    _setTexts();
    provider = ui.PhoneAuthProvider();
    provider.auth = fb.FirebaseAuth.instance;
    provider.authListener = this;
    initMobileNumberState();
  }
// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final mobileNumber = (await MobileNumber.mobileNumber)!;
      final simCard = (await MobileNumber.getSimCards)!;
      pp('$mm ................. mobileNumber: $mobileNumber');
      if (simCard.isNotEmpty) {
        pp('$mm ... ${simCard.first.carrierName} SIM CARD .... ');
        myPrettyJsonPrint(simCard.first.toMap());
      }
    } on PlatformException catch (e) {
      debugPrint(" ${E.redDot}Failed to get mobile number because of '${e.message}'");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }
  Future _setTexts() async {
    final sett = await prefs.getSettings();
    if (sett == null) {
      return;
    }
    signInStrings = await SignInStrings.getTranslated(sett);
    final c = await prefs.getColorAndLocale();
    loading = await translator.translate(loading, c.locale);
    waiting = await translator.translate(waiting, c.locale);

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
    final res = await _danceWithFirebase();
    if (res == 0 && mounted) {
      pp('$mm ${E.leaf2}${E.leaf2}${E.leaf2}${E.leaf2} ${E.leaf2} about to pop!');
      Navigator.of(context).pop(true);
    }
  }

  bool initializing = false;
  Future _danceWithFirebase() async {
    pp('$mm ...................... ${E.redDot} _danceWithFirebase; '
        '\n ${E.blueDot} verificationId: $verificationId ${E.blueDot} smsCode: $smsCode');
    if (smsCode == null) {
      pp('$mm ...................... ${E.redDot} _danceWithFirebase; quitting, sms-code is null');
      return;
    }

    setState(() {
      initializing = true;
      //child = TimerWidget(title: loading, subTitle: loadingRoutes,);
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
        pp('$mm KasieTransie user found on database:  🍎 ${mUser.toJson()} 🍎');
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
          pp('$mm KasieTransie countries found on database:  🍎 ${countries.length} 🍎');
          pp('$mm KasieTransie; my country the beloved:  🍎 ${myCountry!.name!} 🍎');
        } catch (e) {
          pp(e);
        }


      } else {
        if (mounted) {
          showSnackBar(
              padding: 20,
              duration: const Duration(seconds: 5),
              message: 'User not found',
              context: context);
          return 9;
        }
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
            final res = await _danceWithFirebase();
            if (res == 0 && mounted) {
              Navigator.of(context).pop(true);
            }
          }
          // final res = await _danceWithFirebase();
          // if (res == 0 && mounted) {
          //   Navigator.of(context).pop(true);
          // }

          // provider.verifySMSCode(
          //     action: AuthAction.signIn,
          //     verificationId: verificationId,
          //     code: smsCode,
          //     confirmationResult: confirmationResult);
          //_verifyPhoneNumber();
        },
      );
    });
  }

  bool busy = false;
  bool verificationCompleted = false;
  final firebaseAuth = fb.FirebaseAuth.instance;
  final phoneController = TextEditingController(text: "+19095550008");
  final codeController = TextEditingController(text: "123456");

  // lib.User? user;
  SignInStrings? signInStrings;
  bool verificationFailed = false;
  String? phoneVerificationId;

  @override
  void onVerificationCompleted(fb.PhoneAuthCredential credential) {
    pp('$mm ... onVerificationCompleted, credential: $credential');

    provider.onCredentialReceived(credential, AuthAction.signIn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title:  Text(signInStrings == null? 'Phone Authentication': signInStrings!.phoneAuth),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Stack(
            children: [
              child,
              initializing
                  ? Positioned(
                      child: TimerWidget(
                      title: loading,
                    ))
                  : const SizedBox()
            ],
          ),
        ),
      )),
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

    setState(() {
      child = const Text("Phone verification cancelled");
    });
  }

  @override
  void onCredentialLinked(fb.AuthCredential credential) {
    pp('$mm ... onCredentialLinked ... navigate to ??? credential: $credential');

    //Navigator.of(context).pushReplacementNamed('/profile');
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
    pp('\n\n$mm ...... onSignedIn: ${E.blueDot} credential: $credential ${E.leaf}${E.leaf}${E.leaf}');

    Navigator.of(context).pop();
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
