import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kasie_transie_library/auth/phone_auth_signin.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/isolates/country_cities_isolate.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:pinput/pinput.dart' as pin;

import '../data/schemas.dart' as lib;
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/initialiazer_cover.dart';
import 'package:intl_phone_field/countries.dart' as cnt;

class PhoneAuthSignin extends StatefulWidget {
  const PhoneAuthSignin({
    Key? key,
    required this.dataApiDog,
    required this.onGoodSignIn,
    required this.onSignInError,
  }) : super(key: key);

  final Function onGoodSignIn;
  final Function onSignInError;
  final DataApiDog dataApiDog;

  @override
  PhoneAuthSigninState createState() => PhoneAuthSigninState();
}

class PhoneAuthSigninState extends State<PhoneAuthSignin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final _formKey = GlobalKey<FormState>();
  bool _codeHasBeenSent = false;
  fb.FirebaseAuth firebaseAuth = fb.FirebaseAuth.instance;
  final mm = '🥬🥬🥬🥬🥬🥬😡 AuthPhoneSigninCard: 😡';
  String? phoneVerificationId;
  String? code;
  final phoneController = TextEditingController(text: "+19095550008");
  final codeController = TextEditingController(text: '123456');

  String? currentText;
  bool verificationFailed = false;
  bool verificationCompleted = false;
  bool busy = false;
  bool initializing = false;
  lib.User? user;
  SignInStrings? signInStrings;

  @override
  void initState() {
    super.initState();
    _setTexts();
  }

  Future _setTexts() async {
    final sett = await prefs.getSettings();
    if (sett == null) {
      return;
    }
    signInStrings = await SignInStrings.getTranslated(sett);
    setState(() {});
  }

  void _processSignIn() async {
    pp('\n\n$mm _processSignIn ... sign in the user using code: ${codeController.value.text}');
    setState(() {
      busy = true;
    });
    code = codeController.value.text;

    if (code == null || code!.isEmpty) {
      showSnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).primaryColor,
          textStyle: myTextStyleMedium(context),
          message: signInStrings == null
              ? 'Please put in the code that was sent to you'
              : signInStrings!.putInCode,
          context: context);
      setState(() {
        busy = false;
      });
      return;
    }
    fb.UserCredential? userCred;
    try {
      fb.PhoneAuthCredential authCredential = fb.PhoneAuthProvider.credential(
          verificationId: phoneVerificationId!, smsCode: code!);
      userCred = await firebaseAuth.signInWithCredential(authCredential);
      pp('\n$mm user signed in to firebase? userCred: $userCred');
      pp('$mm seeking to acquire this user from the Kasie database by their id: 🌀🌀🌀${userCred.user?.uid}');
      user = await listApiDog.getUserById(userCred.user!.uid); //

      if (user != null) {
        pp('$mm KasieTransie user found on database:  🍎 ${user!.toJson()} 🍎');
        await prefs.saveUser(user!);
        final ass = await listApiDog.getAssociationById(user!.associationId!);
        final users =
            await listApiDog.getAssociationUsers(user!.associationId!);
        final countries = await listApiDog.getCountries();
        lib.Country? myCountry;
        for (var country in countries) {
          if (country.countryId == ass.countryId!) {
            myCountry = country;
            await prefs.saveCountry(myCountry);
            break;
          }
        }
        pp('$mm KasieTransie users found on database:  🍎 ${users.length} 🍎');
        pp('$mm KasieTransie my country:  🍎 ${myCountry!.name!} 🍎');
        countryCitiesIsolate.getCountryCities(myCountry.countryId!);
        setState(() {
          initializing = true;
        });
      }
    } catch (e) {
      pp('\n\n\n $mm ${E.redDot} This is annoying! .... $e \n\n\n');
      String msg = 'Unable to Sign in. Have you registered an association?';
      if (msg.contains('dup key')) {
        msg = signInStrings == null
            ? 'Duplicate association name'
            : signInStrings!.duplicateOrg;
      }
      if (msg.contains('not found')) {
        msg = signInStrings == null
            ? 'User not found'
            : signInStrings!.memberNotExist;
      }
      if (msg.contains('Bad response format')) {
        msg = signInStrings == null
            ? 'User not found'
            : signInStrings!.memberNotExist;
      }
      if (msg.contains('server cannot be reached')) {
        msg = signInStrings == null
            ? 'Server cannot be reached'
            : signInStrings!.serverUnreachable;
      }
      pp(msg);
      widget.onSignInError();
      // if (mounted) {
      //   showSnackBar(
      //       duration: const Duration(seconds: 5),
      //       textStyle: myTextStyleMedium(context),
      //       padding: 20.0,
      //       message: msg,
      //       context: context);
      //   setState(() {
      //     busy = false;
      //   });
      // }
      // return;
    }
  }

  final focusNode = FocusNode();
  final defaultPinTheme = pin.PinTheme(
    width: 60,
    height: 64,
    textStyle: GoogleFonts.poppins(
      fontSize: 20,
      color: const Color.fromRGBO(70, 69, 66, 1),
    ),
    decoration: BoxDecoration(
      color: const Color.fromRGBO(232, 235, 241, 0.37),
      borderRadius: BorderRadius.circular(24),
    ),
  );

  void _verifyPhoneNumber() async {
    pp('$mm _start: ....... Verifying phone number ...');
    setState(() {
      busy = true;
    });

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneController.value.text,
        timeout: const Duration(seconds: 90),
        verificationCompleted: (fb.PhoneAuthCredential phoneAuthCredential) {
          pp('$mm firebaseAuth.verifyPhoneNumber: verificationCompleted: $phoneAuthCredential');
          var message = phoneAuthCredential.smsCode ?? "";
          if (message.isNotEmpty) {
            codeController.text = message;
          }
          if (mounted) {
            setState(() {
              verificationCompleted = true;
              busy = false;
            });
            showSnackBar(
                backgroundColor: Theme.of(context).colorScheme.background,
                textStyle: myTextStyleMedium(context),
                message: signInStrings == null
                    ? 'Verification completed. Thank you!'
                    : signInStrings!.verifyComplete,
                context: context);
          }
        },
        verificationFailed: (fb.FirebaseAuthException error) {
          pp('\n$mm firebaseAuth.verifyPhoneNumber: verificationFailed : $error \n');
          if (mounted) {
            setState(() {
              verificationFailed = true;
              busy = false;
            });
            showSnackBar(
                backgroundColor:Colors.red,
                textStyle: myTextStyleMedium(context),
                message: signInStrings == null
                    ? 'Verification failed. Please try later'
                    : signInStrings!.verifyFailed,
                context: context);
          }
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          pp('$mm firebaseAuth.verifyPhoneNumber: onCodeSent: 🔵 verificationId: $verificationId 🔵 will set state ...');
          phoneVerificationId = verificationId;
          if (mounted) {
            pp('$mm setting state  _codeHasBeenSent to true');
            setState(() {
              _codeHasBeenSent = true;
              busy = false;
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          pp('$mm firebaseAuth.verifyPhoneNumber: codeAutoRetrievalTimeout verificationId: $verificationId');
          if (mounted) {
            setState(() {
              busy = false;
              _codeHasBeenSent = false;
            });
            showSnackBar(
                message: signInStrings == null
                    ? 'Code retrieval failed, please try again'
                    : signInStrings!.verifyFailed,
                context: context);
            Navigator.of(context).pop();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Phone SignIn'),
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(100), child: Column()),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: getDefaultRoundedBorder(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      busy
                          ? const TimerWidget(title: "Signing in ...")
                          : const SizedBox(
                              height: 12,
                            ),
                      const SizedBox(
                        height: 24,
                      ),
                      SizedBox(
                        width: 400,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              signInStrings == null
                                  ? 'Phone Authentication'
                                  : signInStrings!.phoneAuth,
                              style: myTextStyleMediumBold(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                SizedBox(
                                  width: 400,
                                  child: IntlPhoneField(
                                    style: myTextStyleMediumLargeWithColor(
                                        context,
                                        Theme.of(context).primaryColor,
                                        20),
                                    onChanged: (value) {},
                                    onSubmitted: (value) {},
                                    controller: phoneController,
                                    countries: cnt.countries,
                                    enabled: true,
                                    initialCountryCode: 'ZA',
                                    autofocus: true,
                                    validator: (phone) {
                                      pp('$mm phone: $phone');
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 60,
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _verifyPhoneNumber();
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(signInStrings == null
                                          ? 'Verify Phone Number'
                                          : signInStrings!.verifyPhone),
                                    )),
                                const SizedBox(
                                  height: 20,
                                ),
                                _codeHasBeenSent
                                    ? SizedBox(
                                        height: 200,
                                        child: Column(
                                          children: [
                                            Text(
                                              signInStrings == null
                                                  ? 'Enter SMS pin code sent'
                                                  : signInStrings!.enterSMS,
                                              style: myTextStyleSmall(context),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: pin.Pinput(
                                                controller: codeController,
                                                autofocus: true,
                                                onSubmitted: (phone) {
                                                  pp('$mm onSubmitted, phone: $phone');
                                                },
                                                onChanged: (value) {
                                                  pp('$mm onChanged, phone: $value');
                                                },
                                                focusedPinTheme:
                                                    defaultPinTheme.copyWith(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            0,
                                                            0,
                                                            0,
                                                            0.05999999865889549),
                                                        offset: Offset(0, 3),
                                                        blurRadius: 16,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 28,
                                            ),
                                            busy
                                                ? const SizedBox(
                                                    height: 16,
                                                    width: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 4,
                                                      backgroundColor:
                                                          Colors.pink,
                                                    ),
                                                  )
                                                : ElevatedButton(
                                                    onPressed: _processSignIn,
                                                    style: ButtonStyle(
                                                      elevation:
                                                          MaterialStateProperty
                                                              .all<double>(8.0),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text(
                                                          signInStrings == null
                                                              ? 'Send Code'
                                                              : signInStrings!
                                                                  .sendCode),
                                                    )),
                                          ],
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          initializing
              ? Positioned(
                  child: InitializerCover(onInitializationComplete: () {
                  pp('$mm ................................'
                      '... onInitializationComplete .... ');
                  Navigator.of(context).pop();
                  widget.onGoodSignIn();
                }, onError: () {
                  pp('$mm ................................'
                      '... onError .... ');

                  Navigator.of(context).pop();
                  widget.onSignInError();
                }))
              : const SizedBox(),
        ],
      ),
    ));
  }
}
