import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/cache_manager.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/error_handler.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:realm/realm.dart' as rm;
import 'package:kasie_transie_library/messaging/fcm_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fb;


import '../data/schemas.dart';
import 'functions.dart';

final Initializer initializer = Initializer();
class Initializer {
  final mm = '😡😡😡😡😡😡😡 Initializer 😡 ';
  final config = rm.Configuration.local([
    Country.schema,
    City.schema,
    Association.schema,
    Route.schema,
    RoutePoint.schema,
    Position.schema,
    User.schema,
    Landmark.schema,
    RouteInfo.schema,
    CalculatedDistance.schema,
    SettingsModel.schema,

  ],);

  Future initializeBasics() async {
    pp('$mm ... initializeBasics starting ....');
    appAuth = AppAuth(fb.FirebaseAuth.instance);
    final http.Client client = http.Client();
    final realm = rm.Realm(config);
    prefs = Prefs();
    cacheManager = CacheManager();
    locationBloc = DeviceLocationBloc();
    errorHandler = ErrorHandler(locationBloc, prefs);
    listApiDog = ListApiDog(client, appAuth, cacheManager, prefs, errorHandler, realm);
    dataApiDog = DataApiDog(client, appAuth, cacheManager, prefs, errorHandler);

    fcmBloc = FCMBloc(fb.FirebaseMessaging.instance);
  }
  Future initializeHeavyStuff() async {
    pp('$mm ... initializeHeavyStuff starting ....');

    locationBloc = DeviceLocationBloc();
    errorHandler = ErrorHandler(locationBloc, prefs);

    await listApiDog.initializeRealm();
    fcmBloc.initialize();

    var list = await listApiDog.getCountries();
    pp('$mm ... initialization almost complete ... countries found: ${list.length}');
    pp('$mm ... initialization complete!');

  }
}
