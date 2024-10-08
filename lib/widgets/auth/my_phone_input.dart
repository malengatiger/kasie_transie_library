import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/widgets/auth/my_sms_code_input.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:page_transition/page_transition.dart';

import '../../bloc/list_api_dog.dart';
import '../../data/data_schemas.dart';
import '../../utils/emojis.dart';
import '../../utils/functions.dart';
import '../../utils/prefs.dart';
import 'country_ui.dart';

class MyPhoneInput extends StatefulWidget {
  const MyPhoneInput(
      {super.key, required this.onPhoneNumber, required this.onError});

  final Function(String) onPhoneNumber;
  final Function(String) onError;

  @override
  State<MyPhoneInput> createState() => _MyPhoneInputState();
}

class _MyPhoneInputState extends State<MyPhoneInput>
    implements ui.PhoneAuthListener {
  final mm = '🥬🥬 MyPhoneInput: 😡';
  @override
  final auth = fb.FirebaseAuth.instance;
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

  @override
  late ui.PhoneAuthProvider provider;

  String? verificationId;
  fb.ConfirmationResult? confirmationResult;

  String loading = 'Loading data';
  String waiting = 'Wait data', notRegistered = '';
  bool verificationCompleted = false;
  final firebaseAuth = fb.FirebaseAuth.instance;
  String enteredText = '';
  String mText = '';
  Country? countrySelected;
  bool busy = false;
  bool initializing = false;
  List<Country> countries = [];
  @override
  void initState() {
    provider = ui.PhoneAuthProvider();
    provider.auth = fb.FirebaseAuth.instance;
    super.initState();
    provider.authListener = this;
    _getCountry();
  }

  void _getCountry() async {
    pp('$mm ... get countries and set device country  ...');
    try {
      setState(() {
        busy = true;
      });
      countries = await listApiDog.getCountries();
      countrySelected = await getDeviceCountry(countries);
      if (countrySelected != null) {
        if (mounted) {
          setState(() {});
          return;
        }
      } else {
        for (var c in countries) {
          if (c.name == 'South Africa') {
            countrySelected = c;
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  void _navigateToCountryList() async {
    final c = await NavigationUtils.navigateTo(context: context, widget: const CountryUi(), transitionType: PageTransitionType.leftToRight);

    if (c is Country) {
      pp('$mm .... CountryUi returned country:: ${c.toJson()} ');
      setState(() {
        countrySelected = c;
      });
    }
  }

  bool ignoreTap = false;

  //@override
  // TODO: implement auth
  // FirebaseAuth get auth =>fb.FirebaseAuth.instance;

  @override
  void onBeforeProvidersForEmailFetch() {
    // TODO: implement onBeforeProvidersForEmailFetch
  }

  @override
  void onBeforeSignIn() {
    // TODO: implement onBeforeSignIn
  }

  @override
  void onCanceled() {
    pp('$mm ... onCanceled ');
  }

  @override
  void onCodeSent(String verificationId, [int? forceResendToken]) {
    pp('$mm ... onCodeSent, verificationId: $verificationId ... should navigate????');
    this.verificationId = verificationId;
    setState(() {
      initializing = false;
      enteredText = '';
    });
    _navigateToSMSInput(verificationId);
  }

  int restartCount = 0;

  Future _initializeData() async {
    pp('$mm ...................... ${E.redDot} _initializeData; '
        '\n ${E.blueDot} verificationId: $verificationId ${E.blueDot} smsCode: $smsCode');
    // var routesIsolate = GetIt.instance<SemCache>();
    // if (smsCode.isEmpty) {
    //   pp('$mm ...................... ${E.redDot} _initializeData; quitting, sms-code is null');
    //   showSnackBar(
    //       backgroundColor: Colors.red,
    //       textStyle: myTextStyleMediumWithColor(context, Colors.white),
    //       message: 'SMS Verification failed, please try again',
    //       context: context);
    //   return;
    // }
    //
    // pp('$mm ..................... sms code: $smsCode ${E.appleRed} will start Firebase authentication ...');
    //
    // setState(() {
    //   initializing = true;
    // });
    //
    // fb.UserCredential? userCred;
    //
    // final start = DateTime.now();
    // try {
    //   fb.PhoneAuthCredential authCredential = fb.PhoneAuthProvider.credential(
    //       verificationId: verificationId!, smsCode: smsCode);
    //   userCred =
    //       await fb.FirebaseAuth.instance.signInWithCredential(authCredential);
    //   pp('\n$mm user signed in to firebase? userCred: $userCred');
    //   //
    //   lib.User? mUser;
    //   pp('$mm seeking to acquire this user from the Kasie database by their id: 🌀🌀🌀${userCred.user?.uid}');
    //   if (userCred.user != null) {
    //     try {
    //       mUser = await listApiDog.getUserById(userCred.user!.uid);
    //     } catch (e) {
    //       pp('Error getting user: $e');
    //       if (restartCount == 0) {
    //         restartCount++;
    //         _initializeData();
    //         return;
    //       }
    //       if (mounted) {
    //         setState(() {
    //           initializing = false;
    //           enteredText = '';
    //         });
    //         showSnackBar(
    //             duration: const Duration(seconds: 12),
    //             message: 'Error input: $e',
    //             context: context);
    //         // Navigator.of(context).pop();
    //         widget.onError(e.toString());
    //       } else {
    //         pp('... Widget not mounted ... ');
    //       }
    //       return;
    //     }
    //   }
    //
    //   if (mUser != null) {
    //     pp('$mm KasieTransie user found on database: 🍎 ${mUser.name} 🍎 will initialize ...');
    //     myPrettyJsonPrint(mUser.toJson());
    //     prefs.saveUser(mUser);
    //     final ass = await listApiDog.getAssociationById(mUser.associationId!);
    //     prefs.saveAssociation(ass!);
    //
    //     try {
    //
    //       final countries = await routesIsolate.getCountries(true);
    //       pp('$mm KasieTransie countries found on database:  🍎 ${countries.length} 🍎');
    //       lib.Country? myCountry;
    //       for (var country in countries) {
    //         if (country.countryId == ass.countryId!) {
    //           myCountry = country;
    //           prefs.saveCountry(myCountry);
    //           pp('$mm KasieTransie country:  🍎 ${country.toJson()} 🍎');
    //           break;
    //         }
    //       }
    //       //
    //
    //       try {
    //         final users =
    //             await routesIsolate.getUsers(mUser.associationId!, true);
    //         pp('$mm KasieTransie users found on database:  🍎 ${users.length} 🍎');
    //         var vehicleIsolate = GetIt.instance<SemCache>();
    //         await vehicleIsolate.getVehicles(mUser.associationId!);
    //         await routesIsolate.getCities(myCountry!.countryId!, true);
    //         await routesIsolate.getRoutes(mUser.associationId!, true);
    //       } catch (e, stackTrace) {
    //         pp('$mm SOMETHING REALLY WRONG!, Bubba! : $e $stackTrace');
    //       }
    //       //
    //       final elapsed = DateTime.now().difference(start).inSeconds;
    //
    //       pp('\n\n$mm ... ${E.leaf}${E.leaf} we should be good! .... '
    //           'elapsed time: $elapsed seconds} ${E.leaf}'
    //           '${E.leaf}${E.leaf}${E.leaf}');
    //       //
    //       if (mounted) {
    //         pp('$mm KasieTransie initialization completed  🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎 should pop');
    //         Navigator.of(context).pop(mUser);
    //         return;
    //       } else {
    //         pp('$mm ... ${E.redDot}${E.redDot}${E.redDot} NOT MOUNTED, wtf??  cannot poop!!!');
    //       }
    //     } catch (e) {
    //       pp(e);
    //       if (mounted) {
    //         setState(() {
    //           initializing = false;
    //           enteredText = '';
    //         });
    //         // Navigator.of(context).pop(mUser);
    //         widget.onError(e.toString());
    //       }
    //     }
    //   } else {
    //     if (mounted) {
    //       const msg = 'User unknown, please check with your Admin';
    //       showSnackBar(message: msg, context: context);
    //       // Navigator.of(context).pop();
    //       widget.onError(msg);
    //       return;
    //     }
    //   }
    // } catch (e) {
    //   pp(e);
    //   if (mounted) {
    //     showSnackBar(message: '$e', context: context);
    //     // Navigator.of(context).pop();
    //     widget.onError(e.toString());
    //   }
    // }
    // return 0;
  }

  @override
  void onConfirmationRequested(ConfirmationResult result) {
    pp('$mm ... onConfirmationRequested: ${result.verificationId}');
  }

  @override
  void onCredentialLinked(AuthCredential credential) {
    // TODO: implement onCredentialLinked
  }

  @override
  void onCredentialReceived(AuthCredential credential) {
    pp('$mm ... onCredentialReceived, AuthCredential: $credential ... should navigate????');
  }

  @override
  void onDifferentProvidersFound(
      String email, List<String> providers, AuthCredential? credential) {}

  @override
  void onError(Object error) {
    pp('$mm ......... show snack but do nothing ... ??????  ${E.redDot}${E.redDot} onError, credential: $error');
    if (mounted) {
      showSnackBar(
          duration: const Duration(seconds: 10),
          padding: 16.0,
          elevation: 16.0,
          message: 'Error: $error',
          context: context);

      Navigator.of(context).pop();
      widget.onError(error.toString());
    }
  }

  @override
  void onMFARequired(MultiFactorResolver resolver) {
    // TODO: implement onMFARequired
  }

  String smsCode = '';

  Future<void> _navigateToSMSInput(verification) async {
    setState(() {
      initializing = false;
    });
    smsCode = await NavigationUtils.navigateTo(context: context, widget: const MySmsCodeInput(), transitionType: PageTransitionType.leftToRight);


    pp('\n\n$mm ... ${E.redDot} back from sms code input: ${E.appleRed} smsCode : $smsCode');
    _initializeData();
  }

  @override
  void onSMSCodeRequested(String phoneNumber) {
    pp('$mm ... onSMSCodeRequested, phoneNumber: $phoneNumber, waiting for shit! ....');
    enteredText = phoneNumber;
    setState(() {
      initializing = true;
    });
  }

  @override
  void onSignedIn(UserCredential credential) {
    pp('$mm ... onSignedIn, UserCredential: $credential ... should navigate????');
  }

  @override
  void onVerificationCompleted(PhoneAuthCredential credential) {
    pp('$mm ... onVerificationCompleted, PhoneAuthCredential: $credential ... should navigate????');

    provider.onCredentialReceived(credential, ui.AuthAction.signIn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Phone Authentication', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            gapH16,
            GestureDetector(
              onTap: () {
                _navigateToCountryList();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Select Country',
                    style: myTextStyleSmall(context),
                  ),
                  gapW16,
                  IconButton(
                    onPressed: () {
                      _navigateToCountryList();
                    },
                    icon: Icon(
                      Icons.search,
                      color: Theme.of(context).primaryColor,
                      size: 48,
                    ),
                  ),
                  gapW8,
                ],
              ),
            ),
            gapH32,
            countrySelected == null
                ? gapW16
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('+${countrySelected!.phoneCode}'),
                      gapW16,
                      Text(
                        countrySelected!.name!,
                        style: myTextStyleMediumLargeWithColor(
                            context, Theme.of(context).primaryColorLight, 18),
                      ),
                    ],
                  ),
            gapH32,
            countrySelected == null
                ? gapW16
                : initializing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(),
                      )
                    : Card(
                        shape: getDefaultRoundedBorder(),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            '+${countrySelected!.phoneCode}$enteredText',
                            style: myTextStyleMediumLargeWithColor(
                                context, Theme.of(context).primaryColor, 32),
                          ),
                        ),
                      ),
            gapH32,
            Expanded(
              child: initializing
                  ? const TimerWidget(
                      title: 'Sending code to your phone',
                      isSmallSize: true,
                    )
                  : NumericKeyboard(
                      textColor: Theme.of(context).primaryColorLight,
                      rightIcon: Icon(
                        Icons.backspace,
                        color: Theme.of(context).primaryColor,
                      ),
                      rightButtonFn: () {
                        setState(() {
                          enteredText = '';
                          mText = '';
                        });
                      },
                      leftIcon: const Icon(
                        Icons.check,
                        size: 64,
                        color: Colors.green,
                      ),
                      leftButtonFn: () {
                        var m = enteredText.trim().replaceAll(' ', '');
                        pp('$mm ... left button tapped; call provider.sendVerificationCode with : $m');
                        ignoreTap = true;

                        provider.sendVerificationCode(
                            phoneNumber: '+${countrySelected!.phoneCode}$m');
                      },
                      onKeyboardTap: (text) {
                        if (!ignoreTap) {
                          setState(() {
                            enteredText = '$enteredText$text';
                            mText = '$mText$text';
                          });
                        }
                        //widget.onSMSCode(v);
                      }),
            ),
          ],
        ),
      ),
    ));
  }
}
