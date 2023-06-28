import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:kasie_transie_library/auth/phone_auth_signin.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/initialiazer_cover.dart';
import 'package:kasie_transie_library/utils/initializer.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';

import '../bloc/list_api_dog.dart';
import '../bloc/theme_bloc.dart';
import '../data/schemas.dart' as lib;
import '../utils/emojis.dart';
import '../utils/prefs.dart';

class EmailAuthSignin extends StatefulWidget {
  const EmailAuthSignin({Key? key}) : super(key: key);

  @override
  EmailAuthSigninState createState() => EmailAuthSigninState();
}

/*
{
  "_partitionKey": null,
  "_id": "6493511c5d5c1e6cd275ce2b",
  "userType": "ASSOCIATION_OFFICIAL",
  "userId": "8UnQARfMOgdpj4BtqtmWRasNSop2",
  "firstName": "St. Vincent",
  "lastName": "Peters-Maltbie",
  "gender": null,
  "countryId": "7a2328bf-915f-4194-82ae-6c220c046cac",
  "associationId": "2f3faebd-6159-4b03-9857-9dad6d9a82ac",
  "associationName": "The Most Awesome Taxi Association",
  "fcmToken": null,
  "email": "stvincent@theawesome.com",
  "cellphone": "+19095550007",
  "password": "pass123",
  "countryName": "South Africa",
  "dateRegistered": null,
  "name": "St. Vincent Peters-Maltbie"
}
 */
class EmailAuthSigninState extends State<EmailAuthSignin>
    with SingleTickerProviderStateMixin {
  final mm = '💦💦💦💦💦💦 EmailAuthSignin 🔷🔷';
  late AnimationController _controller;
  TextEditingController emailController =
      TextEditingController(text: "stvincent@theawesome.com");
  TextEditingController pswdController = TextEditingController(text: "pass123");

  var formKey = GlobalKey<FormState>();
  bool busy = false;
  lib.User? user;
  SignInStrings? signInStrings;

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
      fb.UserCredential userCred = await fb.FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.value.text,
              password: pswdController.value.text);

      pp('\n\n$mm ... Firebase user creds after signin: ${userCred.user} - ${E.leaf}');

      if (userCred.user != null) {
        user = await listApiDog.getUserById(userCred.user!.uid);
        if (user != null) {
          pp('$mm KasieTransie user found on database:  🍎 ${user!.toJson()} 🍎');
          final association = await listApiDog.getAssociationById(user!.associationId!);
          final users =
              await listApiDog.getAssociationUsers(user!.associationId!);
          final countries = await listApiDog.getCountries();
          lib.Country? myCountry;
          for (var country in countries) {
            if (country.countryId == association.countryId!) {
              myCountry = country;
              await prefs.saveCountry(myCountry);
              pp('$mm KasieTransie user country: ${myCountry.name}');
              break;
            }
          }
          pp('$mm KasieTransie users found on database:  🍎 ${users.length} 🍎');
          pp('$mm KasieTransie my country:  🍎 ${myCountry!.name!} 🍎');

          try {
            await prefs.saveUser(user!);
            pp('\n\n\n$mm ... about to initialize KasieTransie data ..... ');

            await _doSettings();

            if (mounted) {
              showSnackBar(
                  duration: const Duration(seconds: 2),
                  padding: 20,
                  backgroundColor: Theme.of(context).primaryColor,
                  textStyle: myTextStyleMedium(context),
                  message: 'You have been signed in OK. Welcome!',
                  context: context);

              var ok = await navigateWithScale(const InitializerCover(), context);
              pp('$mm initialization should be complete! : $ok');
              pp('$mm every check is cool. about to pop!');
              if (mounted) {
                Navigator.of(context).pop(user!);
              }
            }
          } catch (e) {
            pp('$mm ${E.redDot} We are fucked, Jack! The problem: $e');
          }
          setState(() {
            busy = false;
          });
          return;
        }
      } else {
        if (mounted) {
          showSnackBar(
              message:
                  'Authentication failed, please check your email and password',
              context: context);
        }
      }
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(
            backgroundColor: Colors.red,
            textStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            padding: 20,
            message:
                'We may have a slight problem here. Let us solve it together!',
            context: context);
      }
    }
    setState(() {
      busy = false;
    });
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _doSettings() async {
    try {
    var settingsList =
        await listApiDog.getSettings(user!.associationId!);
    if (settingsList.isNotEmpty) {
      settingsList.sort((a, b) => b.created!.compareTo(a.created!));
      await themeBloc.changeToTheme(settingsList.first.themeIndex!);
      pp('$mm KasieTransie theme has been set to:  🍎 ${settingsList.first.themeIndex!} 🍎');
      await themeBloc.changeToLocale(settingsList.first.locale!);
      await prefs.saveSettings(settingsList.first);
      pp('$mm ........ settings should be saved by now ...');
    }
    } catch (e) {
      pp('$mm ... settings fucking up! ${E.redDot}');
      pp(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Kasie Email Sign In',
              style: myTextStyleLarge(context),
            ),
          ),
        ),
        body: Stack(
          children: [
            Center(
              child: SizedBox(
                width: 480,
                height: 640,
                child: Card(
                  shape: getRoundedBorder(radius: 16),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 48,
                        ),
                        Text(
                          'Email Authentication',
                          style: myTextStyleMediumLarge(context),
                        ),
                        const SizedBox(
                          height: 48,
                        ),
                        Expanded(
                            child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 48,
                              ),
                              SizedBox(
                                width: 420,
                                child: TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    label: const Text('Email Address'),
                                    hintText: 'Enter your Email address',
                                    icon: const Icon(Icons.email),
                                    iconColor: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 36,
                              ),
                              SizedBox(
                                width: 420,
                                child: TextFormField(
                                  controller: pswdController,
                                  obscureText: true,
                                  decoration: InputDecoration(
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
                                            elevation: MaterialStatePropertyAll<
                                                double>(8.0),
                                          ),
                                          onPressed: () {
                                            _signIn();
                                          },
                                          child: const Text(
                                              'Send Sign In Credentials')),
                                    )
                            ],
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
