import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';

import '../data/constants.dart';
import '../data/data_schemas.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';
import 'list_api_dog.dart';

String? fcmToken;

class AppAuth {
  static const locks = '🔐🔐🔐🔐🔐🔐🔐🔐 AppAuth: 🔐🔐🔐';
  final auth.FirebaseAuth firebaseAuth;
  late ListApiDog listApiDog;
  late Prefs prefs;
  late SemCache semCache;

  AppAuth({required this.firebaseAuth}) {
    listen();
    startAuthenticationTimer();
  }

  late Timer timer;

  auth.User? getUser()  {
    return firebaseAuth.currentUser;
  }
  Future signInAssociation(String associationId) async {
    pp('$locks signInAssociation .... ${E.redDot}${E.redDot}${E.redDot}');
    listApiDog = GetIt.instance<ListApiDog>();
    var email = '$associationId${Constants.associationEmailSuffix}';
    var password = '${Constants.associationPasswordPrefix}$associationId';
    var cred = await firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    var user = cred.user;
    if (user != null) {
      var ass = await listApiDog.getAssociationById(associationId);
      if (ass != null) {
        return ass;
      }
    }
    throw Exception('Failed to sign in Association');
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    pp('$locks signInWithEmail .... ${E.redDot}${E.redDot}${E.redDot} $email - $password');
    listApiDog = GetIt.instance<ListApiDog>();
    prefs = GetIt.instance<Prefs>();

    User? mUser;
    try {
      auth.UserCredential uc = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      var user = uc.user;
      if (user != null) {
        mUser = await listApiDog.getUserById(user.uid);
        if (mUser != null) {
          prefs.saveUser(mUser);
          pp('signInWithEmail is good: user: 🍎${mUser.toJson()}');
        }
        var asses = await listApiDog.getAssociations(true);
        Association? ass;
        for (var association in asses) {
          pp('$locks association: ${association.associationName}');
          if (association.associationId == mUser!.associationId) {
            ass = association;
          }
        }
        if (ass != null) {
          if (mUser!.associationId != null) {
            if (mUser.associationId != 'ADMIN') {
              prefs.saveAssociation(ass);
            }
          }
          final countries = await listApiDog.getCountries();
          for (var country in countries) {
            pp('$locks KasieTransie user country: 🍎 ${country.name} 🍎');
            if (country.countryId == ass.countryId) {
              prefs.saveCountry(country);
            }
          }
        }
        return mUser;
      }
      pp('$locks 😈😈 No go with sign in: $email; 😈 wtf?');
      throw Exception('No success signing in with $email');
    } catch (e) {
      pp('😈😈Bad moon rising! $e');
      rethrow;
    }
  }

  void startAuthenticationTimer() {
    pp('$locks ✳️ ✳️ Auth Timer starting ...');
    timer = Timer.periodic(const Duration(minutes: 30), (timer) {
      pp('$locks ✳️ ✳️ Auth Timer ticked: tick #${timer.tick} at ${DateTime.now().toIso8601String()} ✳️ will check And possibly refreshToken ...');
      getAuthToken();
    });
    var isActive = timer.isActive;
    pp('$locks ✳️ ✳️ Auth Timer is active: $isActive; duration: minutes: 30');
  }

  void listen() {
    pp('$locks listen for  FirebaseAuth.instance idTokenChanges and authStateChanges ...');
    firebaseAuth.idTokenChanges().listen((auth.User? user) async {
      if (user == null) {
        pp('$locks idTokenChanges: User is currently signed out!');
      } else {
        // pp('$locks idTokenChanges: User is not null! ${user.displayName}, checking auth token state ');
        // await getAuthToken();
      }
    });

    firebaseAuth.authStateChanges().listen((auth.User? user) async {
      if (user == null) {
        pp('$locks authStateChanges: User is currently signed out!');
      } else {
        pp('$locks authStateChanges: User is signed in! ${user.displayName}, checking auth token state ...');
        // await getAuthToken();
      }
    });
  }

  static const msg =
      '👿👿 Authentication token expired or failed. Sorry! You should consider restarting have your app';

  Future<String?> getAuthToken() async {
    try {
      String? token = await _checkAndRefreshToken();
      if (token != null) {
        pp('$locks getAuthToken has a  ✅ good token. We good to trot!!  ✅ ');
        return token;
      } else {
        pp('$locks getAuthToken has fallen down. 👿👿👿👿 throwing toys! ');
        throw Exception(msg);
      }
    } catch (e, s) {
      pp('\n\n $locks 👿👿👿 getAuthToken failed: $e $s 👿👿👿\n\n');
      throw Exception(msg);
    }
  }

  Future<String?> _checkAndRefreshToken() async {
    auth.User? user = firebaseAuth.currentUser;
    String? token;
    if (user != null) {
      token = await user.getIdToken(true);
      await user.getIdTokenResult(true).then((idTokenResult) async {
        pp('$locks getIdTokenResult: 🍎 expirationTime: ${idTokenResult.expirationTime?.toIso8601String()} ');

        DateTime expirationTime = idTokenResult.expirationTime as DateTime;
        Duration diff = expirationTime.difference(DateTime.now());
        token = idTokenResult.token;
        pp('$locks expiration difference in 🍎 seconds: ${diff.inSeconds} ');
        if (diff.inSeconds < 0) {
          token = await user.getIdToken(true);
          return token;
        }
        if (diff.inMinutes < 10) {
          pp('$locks expiration difference in 🍎 minutes: ${diff.inMinutes} ');
          token = await user.getIdToken(true);
          return token;
        }

        return token;
      });
    } else {
      throw Exception('No current user');
    }
    return token;
  }
}
