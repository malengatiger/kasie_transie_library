import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/auth/sign_in_strings.dart';
import 'package:kasie_transie_library/utils/functions.dart';

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
  Prefs prefs = GetIt.instance<Prefs>();

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

      fb.UserCredential userCred = await fb.FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text,
              password: pswdController.text);

      pp('\n\n$mm ... Firebase user creds after sign in: ${userCred.user} - ${E.leaf}');
      pp('\n\n$mm ... about to initialize KasieTransie data ..... uid: ${userCred.user!.uid}');
      var asses = await listApiDog.getAssociations(true);
      for (var element in asses) {
        pp('$mm association: ${element.associationName}');
      }
      pp('$mm ... about to run listApiDog.getUserById ..... uid: ${userCred.user!.uid}');

      if (userCred.user != null) {
        user = await listApiDog.getUserById(userCred.user!.uid);
        if (user != null) {
          await _handleUser();
        }
      } else {
        widget.onSignInError();
      }
    } catch (e) {
      pp(e);
      widget.onSignInError();
    }
    setState(() {
      busy = false;
    });
  }

  Future<void> _handleUser() async {
    pp('$mm KasieTransie user found on database:  🍎 ${user!.toJson()} 🍎');
    user!.password = pswdController.text;
    prefs.saveUser(user!);
    pp('$mm KasieTransie user cached:  🍎 ${user!.toJson()} 🍎');
    Association? association;
    if (user!.associationId != null) {
      if (user!.associationId != 'ADMIN') {
        association = await listApiDog.getAssociationById(user!.associationId!);
        if (association != null) {
          prefs.saveAssociation(association);
          pp('$mm KasieTransie association found on database:  🍎 ${association.toJson()} 🍎');
          final users =
              await listApiDog.getAssociationUsers(user!.associationId!, true);
          pp('$mm users in association: ${users.length}');
        }
      }
    }
    final countries = await listApiDog.getCountries();
    for (var country in countries) {
      if (country.countryId == user?.countryId!) {
        prefs.saveCountry(country);
        pp('$mm KasieTransie user country: 🍎 ${country.name} 🍎');
        break;
      }
    }

    widget.onGoodSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'KasieTransie Email Sign In',
              style: myTextStyleLarge(context),
            ),
          ),
        ),
        body: Stack(
          children: [
            Center(
              child: SizedBox(
                width: 480,
                height: 660,
                child: Card(
                    elevation: 8,
                    child: Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              gapH16,
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
                                            elevation:
                                                WidgetStatePropertyAll<double>(
                                                    8.0),
                                          ),
                                          onPressed: () {
                                            _signIn();
                                          },
                                          child: const Text(
                                              'Send Sign In Credentials')),
                                    )
                            ],
                          ),
                        ))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
