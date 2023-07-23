import 'package:account_picker/account_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot;
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/isolates/routes_isolate.dart';
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/language_and_color_chooser.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:open_mail_app/open_mail_app.dart' as mail;

import '../../isolates/vehicles_isolate.dart';

late EmailLinkAuthProvider emailLinkAuthProvider;
const mex = '🔷🔷🔷🔷EmailLinkAuthProvider 🔷🔷🔷🔷';

Future<void> initializeEmailLinkProvider(ActionCodeSettings action) async {
  emailLinkAuthProvider = EmailLinkAuthProvider(
    actionCodeSettings: action,
  );
  emailLinkAuthProvider.auth = FirebaseAuth.instance;

  FirebaseUIAuth.configureProviders([
    emailLinkAuthProvider,
    // ... other providers
  ]);
  pp('$mex  EmailLinkAuthProvider has been initialized! ${E.leaf}');
  myPrettyJsonPrint(action.asMap());
  // check if email
  final email = await prefs.getEmail();
  if (email != null) {
    pp('$mex .... yea! email is $email}');
  } else {
    pp('$mex .... yea! email is NULL');
  }
  // Check if you received the link via `getInitialLink` first
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();

  if (initialLink != null) {
    final Uri deepLink = initialLink.link;
    pp('$mex  ....... initialLink! ${E.leaf}: ${deepLink.data}');

    // Example of using the dynamic link to push the user to a different screen
    //Navigator.of(context).push(route)
  } else {
    pp('$mex  initialLink is null! ${E.redDot}');
  }

  FirebaseDynamicLinks.instance.onLink.listen(
    (pendingDynamicLinkData) {
      // Set up the `onLink` event listener next as it may be received here
      final Uri deepLink = pendingDynamicLinkData.link;
      pp('$mex  deepLink from listen! ${E.leaf}: ${deepLink.data}');
    },
  );
}

class DamnEmailLink extends StatefulWidget {
  const DamnEmailLink({Key? key, required this.onLanguageChosen}) : super(key: key);

  final Function onLanguageChosen;

  @override
  DamnEmailLinkState createState() => DamnEmailLinkState();
}

class DamnEmailLinkState extends State<DamnEmailLink>
    with SingleTickerProviderStateMixin
    implements EmailLinkAuthListener {
  late AnimationController _controller;
  static const mm = '😡😡😡😡😡😡😡 DamnEmailLink: 💪 ';
  var emailController = TextEditingController();

  final actionCodeSettings = ActionCodeSettings(
    url: 'https://kasietransie2023.page.link/1gGs',
    handleCodeInApp: true,
    androidInstallApp: true,
    androidMinimumVersion: '1',
    dynamicLinkDomain: 'kasietransie2023.page.link',
    androidPackageName: 'com.boha.kasie_transie_ambassador',
    // iOSBundleId: 'com.boha.kasieTransieOwner',
  );
  final formKey = GlobalKey<FormState>();

  String? enterEmail,
      pleaseEnterEmail,
      selectLangColor,
      emailAddress,
      submitText,
      desc,
      signedIn = 'Signed In',
      errorEmailVerification,
      successEmailVerification,
      loading = 'Loading ...',
      emailAuthTitle;
  String openMailApp = "Open Mail App";
  String noMailApps = "No mail apps installed";
  String ok = 'OK';
  String waitingForEmail = 'Waiting for Email';
  String pleaseCheckEmail = "Check email";
  bool busy = false;
  late String adminEmail, adminPassword;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    emailLinkAuthProvider.authListener = this;
    _check();
  }

  Future<void> _check() async {
    await dot.dotenv.load();

    await _setTexts();

    if (FirebaseAuth.instance.currentUser != null) {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  void _getEmail() async {
    final EmailResult? emailResult = await AccountPicker.emailHint();
    if (emailResult != null) {
      pp('$mm emailResult: ${emailResult.email} - ${emailResult.type}');
      emailController.text = emailResult.email;
      _sendEmail();
    }
  }

  Future _setTexts() async {
    final c = await prefs.getColorAndLocale();
    emailAuthTitle = await translator.translate('emailAuthTitle', c.locale);
    desc = await translator.translate('desc', c.locale);
    pleaseEnterEmail = await translator.translate('pleaseEnterEmail', c.locale);
    submitText = await translator.translate('submitText', c.locale);
    enterEmail = await translator.translate('enterEmail', c.locale);
    selectLangColor = await translator.translate('selectLangColor', c.locale);
    errorEmailVerification =
        await translator.translate('errorEmailVerification', c.locale);
    successEmailVerification =
        await translator.translate('successEmailVerification', c.locale);
    emailAddress = await translator.translate('emailAddress', c.locale);
    openMailApp = await translator.translate('openMailApp', c.locale);
    noMailApps = await translator.translate('noMailApps', c.locale);
    ok = await translator.translate('ok', c.locale);
    signedIn = await translator.translate('signedIn', c.locale);
    loading = await translator.translate('loading', c.locale);
    waitingForEmail = await translator.translate('waitingForEmail', c.locale);

    pleaseCheckEmail = await translator.translate('pleaseCheckEmail', c.locale);
    setState(() {});
    Future.delayed(const Duration(milliseconds: 100), () {
      _getEmail();
    });
  }

  void _chooseColor() async {
    await navigateWithScale( LanguageAndColorChooser(onLanguageChosen: (){
      _setTexts();
      widget.onLanguageChosen();
    },), context);
    _setTexts();
  }

  void _sendEmail() async {
    pp('\n\n$mm ... _sendEmail checking if email is known ....');

    adminEmail = dot.dotenv.get('EMAIL');
    adminPassword = dot.dotenv.get('PASSWORD');

    final email = emailController.value.text;
    if (email.isEmpty) {
      {
        showSnackBar(message: 'Please enter email', context: context);
        return;
      }
    }

    if (mounted) {
      setState(() {
        busy = true;
      });
    }
    //use admin user to get the basics set up
    final adminCreds = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: adminEmail, password: adminPassword);
    final tok = await appAuth.getAuthToken();
    pp(tok);
    try {
      if (adminCreds.user != null) {
        pp('\n$mm ...................................'
            ' admin user logged in: creds: $adminCreds getUserByEmail: $email');
        final userFromRemote = await listApiDog.getUserByEmail(email);
        if (userFromRemote != null) {
          userFromRemote.password = 'pass123';
          final mUser = await dataApiDog.updateUser(userFromRemote);
          //sign out the admin userFromRemote ... then sign in new userFromRemote
          await FirebaseAuth.instance.signOut();
          pp('\n$mm ...................................'
              ' ${E.redDot} admin user logged out!');
          //sign in the device updated user
          final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: mUser.email!, password: mUser.password!);

          if (cred.user != null) {
            pp('$mm ... signInWithEmailAndPassword: ${E.leaf2} USER IS SIGNED IN!!! will send email with link, '
                'but will start routesIsolate and vehicleIsolate ....');
            await prefs.saveEmail(email);
            await prefs.saveUser(userFromRemote);
            await vehicleIsolate.getVehicles(mUser.associationId!);
            await routesIsolate.getRoutes(mUser.associationId!);

            try {
              pp('$mm emailLinkAuthProvider: ${emailLinkAuthProvider.providerId} '
                  '${E.diamond} ......... start listening for email link tap! '
                  '${E.diamond}${E.diamond}${E.diamond}');

              FirebaseDynamicLinks.instance.onLink
                  .listen((dynamicLinkData) async {
                await _signInWitheReceivedEmailLink(dynamicLinkData, mUser);
              });

              //send the link .....
              Future.delayed(const Duration(seconds: 10), () {
                emailLinkAuthProvider.sendLink(email);
              });
            } catch (e) {
              pp(e);
              _displayError();
            }
          }
        }
      }
    } catch (e) {
      pp(e);
      _displayError();
    }
  }

  Future<void> _signInWitheReceivedEmailLink(
      PendingDynamicLinkData dynamicLinkData, lib.User mUser) async {
    final Uri deepLink = dynamicLinkData.link;
    bool isEmailLink =
        FirebaseAuth.instance.isSignInWithEmailLink(deepLink.toString());
    pp('\n\n$mm ...... Yebo! ${E.leaf} ${E.leaf}${E.leaf}${E.leaf}'
        ' deepLink is email link? $isEmailLink ${E.appleGreen}');
    myPrettyJsonPrint(dynamicLinkData.asMap());
    setState(() {
      busy = false;
    });
    if (isEmailLink) {
      showSnackBar(
          message: signedIn!,
          textStyle: myTextStyleSmallBlack(context),
          duration: const Duration(seconds: 10),
          context: context);

      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: mUser.email!, password: mUser.password!);
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      _displayError();
      Navigator.of(context).pop(false);
    }
  }

  void _displayError() {
    showSnackBar(
        message: 'Sign in failed',
        duration: const Duration(seconds: 10),
        context: context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                  emailAuthTitle == null ? 'Email Link Auth' : emailAuthTitle!),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 48,
                    ),
                    Form(
                      key: formKey,
                      child: Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 48,
                                ),
                                Text(
                                  desc == null ? 'Description' : desc!,
                                  style: myTextStyleMediumLargeWithColor(
                                      context,
                                      Theme.of(context).primaryColorLight,
                                      16),
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                TextButton(
                                  onPressed: () {
                                    _chooseColor();
                                  },
                                  child: Text(
                                    selectLangColor == null
                                        ? 'Select language and color'
                                        : selectLangColor!,
                                    style: myTextStyleSmall(context),
                                  ),
                                ),
                                const SizedBox(
                                  height: 48,
                                ),
                                TextFormField(
                                  controller: emailController,
                                  validator: (value) {
                                    pp('$mm ...validator value: $value - pleaseEnterEmail: $pleaseEnterEmail');
                                    if (value == null || value.isEmpty) {
                                      return pleaseEnterEmail;
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      label: Text(emailAddress == null
                                          ? 'Email Address'
                                          : emailAddress!),
                                      hintText: pleaseEnterEmail == null
                                          ? 'Please enter your email address'
                                          : pleaseEnterEmail!),
                                ),
                                const SizedBox(
                                  height: 48,
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        _sendEmail();
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(submitText == null
                                          ? 'Submit'
                                          : submitText!),
                                    )),
                                const SizedBox(
                                  height: 48,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                ),
                busy
                    ? Positioned(
                        child:
                            Center(child: TimerWidget(title: waitingForEmail)))
                    : const SizedBox(),
              ],
            )));
  }

  @override
  FirebaseAuth get auth => FirebaseAuth.instance;

  @override
  void onBeforeLinkSent(String email) {
    pp('$mm ... onBeforeLinkSent $email');
  }

  @override
  void onBeforeProvidersForEmailFetch() {
    pp('$mm ... onBeforeProvidersForEmailFetch');
  }

  @override
  void onBeforeSignIn() {
    pp('$mm ... onBeforeSignIn');
  }

  @override
  void onCanceled() {
    pp('$mm ... onCanceled');
  }

  @override
  void onCredentialLinked(AuthCredential credential) {
    pp('$mm ... onCredentialLinked: cred: $credential');
  }

  @override
  void onCredentialReceived(AuthCredential credential) {
    pp('$mm ... onCredentialReceived: $credential');
  }

  @override
  void onDifferentProvidersFound(
      String email, List<String> providers, AuthCredential? credential) {
    pp('$mm ... onDifferentProvidersFound: ${providers.length} cred: $credential');
  }

  @override
  void onError(Object error) {
    pp('$mm ... onError: $error');
  }

  @override
  Future<void> onLinkSent(String email) async {
    pp('\n\n$mm ... onLinkSent signin link sent to: ${E.blueDot} $email ${E.blueDot}');

    showSnackBar(
        duration: const Duration(seconds: 10),
        message: pleaseCheckEmail,
        context: context);

    var result = await mail.OpenMailApp.openMailApp();
    pp('$mm ... OpenMailApp ... result, didOpen: ${result.didOpen}');
    // If no mail apps found, show error
    if (mounted) {
      if (!result.didOpen && !result.canOpen) {
        showNoMailAppsDialog(context);
      } else if (!result.didOpen && result.canOpen) {
        showDialog(
          context: context,
          builder: (_) {
            return mail.MailAppPickerDialog(
              mailApps: result.options,
            );
          },
        );
      }
    }
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(openMailApp),
          content: Text(noMailApps),
          actions: <Widget>[
            TextButton(
              child: Text(ok),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  void onMFARequired(MultiFactorResolver resolver) {
    pp('$mm ... onMFARequired');
  }

  @override
  void onSignedIn(UserCredential credential) {
    pp('$mm ... onSignedIn cred: $credential');
  }

  @override
  AuthProvider<AuthListener, AuthCredential> get provider =>
      throw UnimplementedError();
}
