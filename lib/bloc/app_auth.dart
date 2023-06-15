import 'package:firebase_auth/firebase_auth.dart';

import '../utils/emojis.dart';
import '../utils/functions.dart';


late AppAuth appAuth;
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
}
