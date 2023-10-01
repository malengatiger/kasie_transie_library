import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/app_auth_get.dart';
import 'package:kasie_transie_library/bloc/cache_manager.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/error_handler.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:realm/realm.dart' as realm;

import '../data/schemas.dart' as lib;
import '../utils/emojis.dart';

final getIt = GetIt.instance;
final http.Client client = http.Client();
final config = realm.Configuration.local(
  [
    lib.Country.schema,
    lib.City.schema,
    lib.Association.schema,
    lib.Route.schema,
    lib.RoutePoint.schema,
    lib.Position.schema,
    lib.User.schema,
    lib.Landmark.schema,
    lib.RouteInfo.schema,
    lib.CalculatedDistance.schema,
    lib.SettingsModel.schema,
    lib.RouteStartEnd.schema,
    lib.RouteLandmark.schema,
    lib.RouteCity.schema,
    lib.StateProvince.schema,
    lib.Vehicle.schema,
    lib.LocationResponse.schema,
    lib.LocationRequest.schema,
    lib.DispatchRecord.schema,
    lib.VehiclePhoto.schema,
    lib.VehicleVideo.schema,
    lib.VehicleMediaRequest.schema,
    lib.RouteUpdateRequest.schema,
    lib.AmbassadorPassengerCount.schema,
    lib.AmbassadorCheckIn.schema,
    lib.CommuterRequest.schema,
    lib.Commuter.schema,
    lib.VehicleHeartbeat.schema,
    lib.VehicleArrival.schema,
    lib.RouteAssignment.schema,
  ],
);
final GetItInitializer getItInitializer = GetItInitializer();
class GetItInitializer {
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵️ ❤️ GetItInitializer: ❤️: ';

  void registerServices() {
    pp('$mm ... Register services here ....');
    final prefs = Prefs();
    final loc = DeviceLocationBloc();
    final cacheManager =  CacheManager();
    final errHandler = ErrorHandler(loc, prefs);
    //final auth = AppAuth(FirebaseAuth.instance);

    try {
    getIt.registerSingleton<AppAuthGet>(AppAuthGet(FirebaseAuth.instance));
    pp('$mm ... AppAuth registered');
    getIt.registerSingleton<Prefs>(Prefs());
    pp('$mm ... Prefs registered');
    getIt.registerSingleton<ListApiDog>(ListApiDog(
        http.Client(),
        AppAuth(FirebaseAuth.instance),
        cacheManager,
        prefs,
        ErrorHandler(loc, prefs),
        realm.Realm(config)));
    pp('$mm ... ListApiDog registered');
    getIt.registerSingleton(DataApiDog(client, appAuth, cacheManager, prefs, errHandler));
    } catch ( e, stack) {
      pp('$mm GetIt Registrations failed. ${E.redDot} $stack');
    }

  }
}
