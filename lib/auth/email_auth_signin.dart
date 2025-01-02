import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/auth/sign_in_strings.dart';
import 'package:kasie_transie_library/utils/functions.dart';

import '../bloc/app_auth.dart';
import '../bloc/data_api_dog.dart';
import '../bloc/list_api_dog.dart';
import '../data/data_schemas.dart';
import '../utils/emojis.dart';
import '../utils/prefs.dart';

class EmailAuthSignin extends StatefulWidget {
  const EmailAuthSignin(
      {super.key, required this.onGoodSignIn, required this.onSignInError});

  final Function onGoodSignIn;
  final Function onSignInError;

  @override
  EmailAuthSigninState createState() => EmailAuthSigninState();
}

//😎😎marshal: thabsnkuna@awesometaxi.com  - pass123
//😎😎ambassador: smithmol@awesometaxi.com  - pass123
//😎😎Internal Admin: peterj_admin@sowertech.com - pass123 - user belongs to sowertech and does not belong to association

class EmailAuthSigninState extends State<EmailAuthSignin>
    with SingleTickerProviderStateMixin {
  final mm = '💦💦💦💦💦💦 EmailAuthSignin 🔷🔷';
  late AnimationController _controller;
  TextEditingController emailController = TextEditingController();
  TextEditingController pswdController = TextEditingController();

  var formKey = GlobalKey<FormState>();
  bool busy = false;

  // bool initializing = false;
  User? user;
  SignInStrings? signInStrings;
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();

  Prefs prefs = GetIt.instance<Prefs>();
  AppAuth appAuth = GetIt.instance<AppAuth>();

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

  void _signIn() async {
    setState(() {
      busy = true;
    });
    try {
      pp('\n\n$mm ... sign in ....: ${emailController.text} ${pswdController.text} - ${E.leaf}');

      user = await appAuth.signInWithEmailAndPassword(
          emailController.text, pswdController.text);
      if (user != null) {
        var ass = await listApiDog.getAssociationById(user!.associationId!);
        if (ass != null) {
          prefs.saveAssociation(ass);
          var settings = await listApiDog.getSettings(ass.associationId!, true);
          if (settings.isNotEmpty) {
            prefs.saveSettings(settings.last);
          } else {
            var s = SettingsModel(
                associationId: ass.associationId!,
                locale: 'en',
                created: DateTime.now().toUtc().toIso8601String(),
                refreshRateInSeconds: 300,
                themeIndex: 0,
                geofenceRadius: 500,
                commuterGeofenceRadius: 500,
                vehicleSearchMinutes: 10,
                heartbeatIntervalSeconds: 300,
                loiteringDelay: 60,
                commuterSearchMinutes: 10,
                commuterGeoQueryRadius: 500,
                vehicleGeoQueryRadius: 10000,
                numberOfLandmarksToScan: 0,
                geofenceRefreshMinutes: 30,
                distanceFilter: 500);
            await dataApiDog.addSettings(s);
            prefs.saveSettings(s);
          }
        }
        widget.onGoodSignIn();

      } else {
        widget.onSignInError();
      }
    } catch (e) {
      pp(e);
      widget.onSignInError();
      if (mounted) {
        showErrorToast(message: 'SignIn failed. $e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Kasie Transie Email Sign In',
              style: myTextStyle(),
            ),
          ),
        ),
        body: Stack(
          children: [
            Center(
              child: SizedBox(
                  width: 480,
                  height: 660,
                  child: Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            gapH16,
                            SizedBox(
                              width: 420,
                              child: TextFormField(
                                controller: emailController,
                                style: myTextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  label: const Text('Email Address'),
                                  hintText: 'Enter your Email address',
                                  icon: const Icon(Icons.email),
                                  iconColor: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            gapH32,
                            SizedBox(
                              width: 420,
                              child: TextFormField(
                                controller: pswdController,
                                style: myTextStyle(fontSize: 18),
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  label: const Text('Password'),
                                  hintText: 'Enter your password',
                                  icon: const Icon(Icons.lock),
                                  iconColor: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 80,
                            ),
                            busy
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 12,
                                      backgroundColor: Colors.amber,
                                    ),
                                  )
                                : SizedBox(
                                    width: 300,
                                    height: 60,
                                    child: ElevatedButton(
                                        style: const ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.pink),
                                          elevation:
                                              WidgetStatePropertyAll<double>(
                                                  8.0),
                                        ),
                                        onPressed: () {
                                          _signIn();
                                        },
                                        child: Text(
                                          'Send Sign In Credentials',
                                          style: myTextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              weight: FontWeight.normal),
                                        )),
                                  )
                          ],
                        ),
                      ))),
            ),
          ],
        ),
      ),
    );
  }
}
