import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/auth/sign_in_strings.dart';
import 'package:kasie_transie_library/utils/functions.dart';

import '../bloc/app_auth.dart';
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
        }
        widget.onGoodSignIn();
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
