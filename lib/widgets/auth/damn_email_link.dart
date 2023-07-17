import 'package:account_picker/account_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/language_and_color_chooser.dart';
import 'package:open_mail_app/open_mail_app.dart' as mail;

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
  const DamnEmailLink({Key? key}) : super(key: key);

  @override
  DamnEmailLinkState createState() => DamnEmailLinkState();
}

class DamnEmailLinkState extends State<DamnEmailLink>
    with SingleTickerProviderStateMixin
    implements EmailLinkAuthListener {
  late AnimationController _controller;
  static const mm = '😡😡😡😡😡😡😡 DamnEmailLink: 💪 ';
  var emailController = TextEditingController(text: "jackmalengata@gmail.com");

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
      errorEmailVerification,
      successEmailVerification,
      emailAuthTitle;
  String openMailApp = "Open Mail App";
  String noMailApps = "No mail apps installed";
  String ok = 'OK';
  String pleaseCheckEmail = "Check email";
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    emailLinkAuthProvider.authListener = this;
  }

  void _getEmail() async {
    final EmailResult? emailResult = await AccountPicker.emailHint();
    if (emailResult != null) {
      pp('$mm emailResult: ${emailResult.email} - ${emailResult.type}');
      emailController.text = emailResult.email;
      setState(() {});
    }
  }

  _setTexts() async {
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
    pleaseCheckEmail = await translator.translate('pleaseCheckEmail', c.locale);
    setState(() {});
    Future.delayed(const Duration(milliseconds: 100), () {
      _getEmail();
    });
  }

  _chooseColor() async {
    await navigateWithScale(const LanguageAndColorChooser(), context);
    _setTexts();
  }

  _sendEmail() async {
    pp('$mm ... _sendEmail ....');

    try {
      final email = emailController.value.text;
      pp('$mm emailLinkAuthProvider: ${emailLinkAuthProvider.providerId}');
      await prefs.saveEmail(email);
      emailLinkAuthProvider.sendLink(email);
    } catch (e) {
      pp(e);
    }
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
        title:
            Text(emailAuthTitle == null ? 'Email Link Auth' : emailAuthTitle!),
      ),
      body: Column(
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
                            context, Theme.of(context).primaryColorLight, 16),
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
                            child: Text(
                                submitText == null ? 'Submit' : submitText!),
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
    ));
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
