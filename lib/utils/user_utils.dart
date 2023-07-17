
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kasie_transie_library/utils/prefs.dart';

import '../bloc/list_api_dog.dart';
import '../widgets/auth/damn_email_link.dart';
import 'emojis.dart';
import 'functions.dart';

Future<bool> checkUser(User? firebaseUser) async {
  var user = await prefs.getUser();
  bool ch = false;
  if (user != null && firebaseUser != null) {
    pp('$mex _getAuthenticationStatus .......  '
        '🥬🥬🥬auth is DEFINITELY authenticated and OK');
    user = await prefs.getUser();
    ch = true;
  } else {
    pp('$mex _getAuthenticationStatus ....... NOT AUTHENTICATED! '
        '🌼🌼🌼 ... will start the painful process ${E.heartOrange}!!');
  }
  return ch;
}

Future<bool> checkEmail(User? firebaseUser) async {
  final email = await prefs.getEmail();
  var ch = false;
  if (email != null && firebaseUser == null) {
    try {
      final mUser = await listApiDog.getUserByEmail(email);
      if (mUser != null) {
        myPrettyJsonPrint(mUser.toJson());
        await prefs.saveUser(mUser);
        pp('$mex _getAuthenticationStatus .......${E.redDot} NEED to sign user in with Firebase ');
        final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, password: mUser.password!);
        if (cred.user != null) {
          pp('$mex checkEmail .......${E.leaf} We tracking real good, Boss! cred: $cred');
          ch = true;
        }
      }
    } catch (e) {
      pp(e);
    }
  }
  return ch;
}
