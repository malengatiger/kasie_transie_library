import 'package:firebase_auth/firebase_auth.dart';

import '../utils/emojis.dart';
import '../utils/functions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as env;


final AppAuth appAuth = AppAuth(FirebaseAuth.instance);

class AppAuth {
  static const locks = '🔐🔐🔐🔐🔐🔐🔐🔐 AppAuth: ';
  final FirebaseAuth? firebaseAuth;

  AppAuth(this.firebaseAuth);

  Future<String?> getAuthToken() async {
    String? token;
    if (firebaseAuth!.currentUser != null) {
      token = await firebaseAuth!.currentUser!.getIdToken();
    }
    if (token != null) {
      // pp('$locks getAuthToken has a 🌸🌸 GOOD!! 🌸🌸 Firebase id token 🍎');
    } else {
      pp('$locks getAuthToken has fallen down. ${E.redDot}${E.redDot}${E.redDot}  Firebase id token not found 🍎');

    }
    return token;
  }

  Future signInVehicle() async {
    pp('$locks signInVehicle .... ${E.redDot}${E.redDot}${E.redDot} 🍎');

    await env.dotenv.load(fileName: '.env');
    final email = env.dotenv.get('EMAIL');
    final password = env.dotenv.get('PASSWORD');

    final userCred = await firebaseAuth?.signInWithEmailAndPassword(
        email: email, password: password);
    if (userCred != null) {
      if (userCred.user != null) {
        pp('$locks Car has been authenticated : ${userCred.user!.email};'
            ' ${E.leaf}${E.leaf}${E.leaf}');
        return 0;
      }
    } else {
      pp('$locks Car authentication failed '
          ' ${E.redDot}${E.redDot}${E.redDot}');
      throw Exception('Firebase vehicle authentication failed');
    }
  }

}
