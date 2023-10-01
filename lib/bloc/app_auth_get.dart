import 'package:firebase_auth/firebase_auth.dart';

import '../utils/emojis.dart';
import '../utils/functions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as env;


String? fcmToken;

class AppAuthGet {
  static const locks = '🔐🔐🔐🔐🔐🔐🔐🔐 AppAuthGet: ';
  final FirebaseAuth? firebaseAuth;

  AppAuthGet(this.firebaseAuth);

  Future<String?> getAuthToken() async {
    try {
      String? token;
      if (firebaseAuth!.currentUser != null) {
        token = await firebaseAuth!.currentUser!.getIdToken();
      }
      if (token != null) {
        pp('$locks getAuthToken has a 🌸🌸 GOOD!! 🌸🌸 Firebase id token 🍎');
      } else {
        pp('$locks getAuthToken has fallen down. ${E.redDot}${E.redDot}${E.redDot}  Firebase id token not found 🍎');
      }
      fcmToken = token;
      return token;
    } catch (e) {
      pp(e);
    }
    return '';
  }

}
