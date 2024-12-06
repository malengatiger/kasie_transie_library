import 'package:firebase_auth/firebase_auth.dart';

import '../utils/emojis.dart';
import '../utils/functions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as env;

final AppAuth appAuth = AppAuth(FirebaseAuth.instance);

String? fcmToken;

class AppAuth {
  static const locks = '🔐🔐🔐🔐🔐🔐🔐🔐 AppAuth: 🔐🔐🔐';
  final FirebaseAuth firebaseAuth;

  AppAuth(this.firebaseAuth) {
    listen();
  }

  void listen() {
    pp('$locks listen for  FirebaseAuth.instance idTokenChanges and authStateChanges ...');
    firebaseAuth?.idTokenChanges().listen((User? user) {
      if (user == null) {
        pp('$locks idTokenChanges: User is currently signed out!');
      } else {
        pp('$locks User is signed in! ${user.displayName}');
      }
    });
    firebaseAuth.authStateChanges().listen((User? user) {
      if (user == null) {
        pp('$locks authStateChanges: User is currently signed out!');
      } else {
        pp('$locks authStateChanges: User is signed in! ${user.displayName}');
      }
    });
  }

  Future<String?> getAuthToken() async {
    try {
      String? token;
      if (firebaseAuth.currentUser != null) {
        token = await firebaseAuth.currentUser!.getIdToken(true);
      }
      if (token != null) {
        pp('$locks getAuthToken has a 🌸🌸 GOOD!! 🌸🌸 Firebase id token 🍎🍎🍎🍎');
      } else {
        pp('$locks getAuthToken has fallen down. ${E.redDot}${E.redDot}${E.redDot}  Firebase id token not found 🍎');
        throw Exception('getAuthToken failed: token is null');
      }
      fcmToken = token;
      return token;
    } catch (e, s) {
      pp('$e $s');
      throw Exception('getAuthToken failed: $e');
    }
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
