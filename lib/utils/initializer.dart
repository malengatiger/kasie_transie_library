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

  Future initialize() async {
    pp('$mm ... starting ....');
    appAuth = AppAuth(fb.FirebaseAuth.instance);
    final http.Client client = http.Client();
    locationBloc = DeviceLocationBloc();
    final realm = rm.Realm(config);
    prefs = Prefs();
    errorHandler = ErrorHandler(locationBloc, prefs);
    cacheManager = CacheManager();
    listApiDog = ListApiDog(client, appAuth, cacheManager, prefs, errorHandler, realm);
    dataApiDog = DataApiDog(client, appAuth, cacheManager, prefs, errorHandler);

    await listApiDog.initializeRealm();
    var list = await listApiDog.getCountries();
    pp('$mm ... initialization almost complete ... countries found: ${list.length}');


    pp('$mm ... initialization complete!');

  }
}
