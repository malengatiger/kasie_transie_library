
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/utils/prefs.dart';

import '../bloc/list_api_dog.dart';
import 'emojis.dart';
import 'functions.dart';

Future<bool> checkUser(User? firebaseUser) async {
  Prefs prefs = GetIt.instance<Prefs>();

  var user =  prefs.getUser();
  bool ch = false;
  if (user != null && firebaseUser != null) {
    pp('_getAuthenticationStatus .......  '
        '🥬🥬🥬auth is DEFINITELY authenticated and OK');
    user = prefs.getUser();
    ch = true;
  } else {
    pp('_getAuthenticationStatus ....... NOT AUTHENTICATED! '
        '🌼🌼🌼 ... will start the painful process ${E.heartOrange}!!');
  }
  return ch;
}

Future<bool> checkEmail(User? firebaseUser) async {
  Prefs prefs = GetIt.instance<Prefs>();
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();


  final email =  prefs.getEmail();
  var ch = false;
  if (email != null && firebaseUser == null) {
    try {
      final mUser = await listApiDog.getUserByEmail(email);
      if (mUser != null) {
        myPrettyJsonPrint(mUser.toJson());
         prefs.saveUser(mUser);
        pp(' _getAuthenticationStatus .......${E.redDot} NEED to sign user in with Firebase ');
        final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, password: mUser.password!);
        if (cred.user != null) {
          pp(' checkEmail .......${E.leaf} We tracking real good, Boss! cred: $cred');
          ch = true;
        }
      }
    } catch (e) {
      pp(e);
    }
  }
  return ch;
}
