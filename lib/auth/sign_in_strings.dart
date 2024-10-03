import '../data/data_schemas.dart';
import '../l10n/translation_handler.dart';

class SignInStrings {
  late String signIn,
      memberSignedIn,
      putInCode,
      duplicateOrg,
      enterPhone,
      serverUnreachable,
      phoneSignIn,
      phoneAuth,
      phoneNumber,
      verifyPhone,
      enterSMS,
      sendCode,
      verifyComplete,
      verifyFailed,
      enterOrg,
      orgName,
      enterAdmin,
      adminName,
      enterEmail,
      pleaseSelectCountry,
      memberNotExist,
      registerOrganization,
      signInOK,
      enterPassword,
      password,
      emailAddress;

  SignInStrings({required this.signIn,
    required this.memberSignedIn,
    required this.putInCode,
    required this.duplicateOrg,
    required this.enterPhone,
    required this.serverUnreachable,
    required this.phoneSignIn,
    required this.phoneAuth,
    required this.phoneNumber,
    required this.verifyPhone,
    required this.enterSMS,
    required this.sendCode,
    required this.registerOrganization,
    required this.verifyComplete,
    required this.verifyFailed,
    required this.enterOrg,
    required this.orgName,
    required this.enterAdmin,
    required this.adminName,
    required this.memberNotExist,
    required this.enterEmail,
    required this.pleaseSelectCountry,
    required this.signInOK,
    required this.enterPassword,
    required this.password,
    required this.emailAddress});

  static Future<SignInStrings> getTranslated(SettingsModel sett) async {
    var signIn = await translator.translate('signIn', sett.locale!);
    var memberNotExist =
    await translator.translate('memberNotExist', sett.locale!);
    var memberSignedIn =
    await translator.translate('memberSignedIn', sett.locale!);
    var putInCode = await translator.translate('putInCode', sett.locale!);
    var duplicateOrg = await translator.translate('duplicateOrg', sett.locale!);
    var pleaseSelectCountry =
    await translator.translate('pleaseSelectCountry', sett.locale!);

    var registerOrganization =
    await translator.translate('registerOrganization', sett.locale!);

    var enterPhone = await translator.translate('enterPhone', sett.locale!);
    var signInOK = await translator.translate('signInOK', sett.locale!);

    var enterPassword =
    await translator.translate('enterPassword', sett.locale!);

    var password = await translator.translate('password', sett.locale!);

    var serverUnreachable =
    await translator.translate('serverUnreachable', sett.locale!);
    var phoneSignIn = await translator.translate('phoneSignIn', sett.locale!);
    var phoneAuth = await translator.translate('phoneAuth', sett.locale!);
    var phoneNumber = await translator.translate('phoneNumber', sett.locale!);
    var verifyPhone = await translator.translate('verifyPhone', sett.locale!);
    var enterSMS = await translator.translate('enterSMS', sett.locale!);
    var sendCode = await translator.translate('sendCode', sett.locale!);
    var verifyComplete =
    await translator.translate('verifyComplete', sett.locale!);
    var verifyFailed = await translator.translate('verifyFailed', sett.locale!);
    var enterOrg = await translator.translate('enterOrg', sett.locale!);
    var orgName = await translator.translate('orgName', sett.locale!);
    var enterAdmin = await translator.translate('enterAdmin', sett.locale!);
    var adminName = await translator.translate('adminName', sett.locale!);
    var enterEmail = await translator.translate('enterEmail', sett.locale!);
    var emailAddress = await translator.translate('emailAddress', sett.locale!);

    final m = SignInStrings(
        signIn: signIn,
        signInOK: signInOK,
        password: password,
        enterPassword: enterPassword,
        memberSignedIn: memberSignedIn,
        putInCode: putInCode,
        duplicateOrg: duplicateOrg,
        enterPhone: enterPhone,
        serverUnreachable: serverUnreachable,
        phoneSignIn: phoneSignIn,
        phoneAuth: phoneAuth,
        pleaseSelectCountry: pleaseSelectCountry,
        phoneNumber: phoneNumber,
        verifyPhone: verifyPhone,
        enterSMS: enterSMS,
        sendCode: sendCode,
        registerOrganization: registerOrganization,
        verifyComplete: verifyComplete,
        verifyFailed: verifyFailed,
        enterOrg: enterOrg,
        orgName: orgName,
        enterAdmin: enterAdmin,
        adminName: adminName,
        enterEmail: enterEmail,
        memberNotExist: memberNotExist,
        emailAddress: emailAddress);

    return m;
  }
}
