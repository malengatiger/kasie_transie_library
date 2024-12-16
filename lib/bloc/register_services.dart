import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/cloud_storage_bloc.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/bloc/the_great_geofencer.dart';
import 'package:kasie_transie_library/bloc/theme_bloc.dart';
import 'package:kasie_transie_library/bloc/vehicle_telemetry_service.dart';

import 'package:kasie_transie_library/messaging/telemetry_manager.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/route_update_listener.dart';
import 'package:kasie_transie_library/utils/zip_handler.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/error_handler.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';
import '../utils/route_distance_calculator.dart';
import 'app_auth.dart';
import 'cache_manager.dart';
import 'data_api_dog.dart';
import 'list_api_dog.dart';

class RegisterServices {
  static const mm = '🅿️🅿️🅿️🅿️ RegisterServices  🅿️🅿️';
  static String dbPath = 'kasie.db';
  static DatabaseFactory dbFactoryWeb = databaseFactoryWeb;

  static Future<String> register( {required FirebaseStorage firebaseStorage}) async {
    pp('\n\n$mm  ... initialize service singletons with GetIt .... 🍎🍎🍎');
    pp('$mm .... QRGeneration: 🦠qrgGeneration initialized');
    final http.Client client = http.Client();
    pp('$mm .... http.Client: 🦠client initialized');
    final AppAuth appAuth = AppAuth( firebaseAuth: FirebaseAuth.instance);
    pp('$mm .... AppAuth: 🦠auth initialized');
    final DeviceLocationBloc deviceLocationBloc = DeviceLocationBloc();
    pp('$mm .... DeviceLocationBloc: 🦠deviceLocationBloc initialized');
    final CacheManager cacheManager = CacheManager();
    pp('$mm .... CacheManager: 🦠cacheManager initialized');
    final Prefs prefs = Prefs(await SharedPreferences.getInstance());
    pp('$mm .... Prefs: 🦠prefs initialized');
    final ErrorHandler errorHandler = ErrorHandler(DeviceLocationBloc(), prefs);
    pp('$mm .... ErrorHandler: 🦠errorHandler initialized');
    final SemCache semCache = SemCache();
    pp('$mm .... SemCache: 🦠cache initialized');
    final ZipHandler zipHandler = ZipHandler(appAuth, semCache);
    pp('$mm .... ZipHandler: 🦠handler initialized');

    final VehicleTelemetryService telemetryService = VehicleTelemetryService();
    final listApi =
        ListApiDog(client, appAuth, prefs, errorHandler, zipHandler, semCache);
    pp('$mm .... ListApiDog: 🦠listApiDog initialized');
    //
    CloudStorageBloc csb = CloudStorageBloc(dataApiDog: DataApiDog(),
        prefs: prefs, firebaseStorage: firebaseStorage,
      locationBloc: deviceLocationBloc, );
    pp('$mm .... CloudStorageBloc: 🦠csb initialized');
    pp('\n\n$mm ..... 🦠🦠🦠🦠🦠registerLazySingletons ...');

    final GetIt instance = GetIt.instance;

    instance.registerLazySingleton<Prefs>(() => prefs);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... Prefs');

    instance.registerLazySingleton<CloudStorageBloc>(() => csb);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... CloudStorageBloc');

    instance.registerLazySingleton<KasieThemeManager>(() => KasieThemeManager(prefs));
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... KasieThemeManager');

    instance.registerLazySingleton<RouteUpdateListener>(() => RouteUpdateListener());
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... RouteUpdateListener');

    instance.registerLazySingleton<DeviceLocationBloc>(() => deviceLocationBloc);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... DeviceLocationBloc');

    instance.registerLazySingleton<SemCache>(() => semCache);

    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... SemCache');

    instance.registerLazySingleton<ZipHandler>(() => zipHandler);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... ZipHandler');

    instance.registerLazySingleton<RouteDistanceCalculator>(
        () => RouteDistanceCalculator(prefs, listApi, DataApiDog()));
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... RouteDistanceCalculator');

    instance.registerLazySingleton<TheGreatGeofencer>(
        () => TheGreatGeofencer(DataApiDog(), listApi, prefs));
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... TheGreatGeofencer');

    instance.registerLazySingleton<ListApiDog>(() => listApi);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... ListApiDog');

    instance.registerLazySingleton<DataApiDog>(() => DataApiDog());
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... DataApiDog');

    instance.registerLazySingleton<CacheManager>(() => cacheManager);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... CacheManager');

    instance.registerLazySingleton<AppAuth>(() => appAuth);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... AppAuth');

    instance.registerLazySingleton<ErrorHandler>(() => errorHandler);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... ErrorHandler');

    instance.registerLazySingleton<TelemetryManager>(() => TelemetryManager());
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... TelemetryManager');
    // instance.registerLazySingleton<QRGenerationService>(() => qrgGenerationService);
    // pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... QRGenerationService');

    instance.registerLazySingleton<VehicleTelemetryService>(() => telemetryService);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... VehicleTelemetryService');

    pp('\n\n$mm  returning message form RegisterService  🍎🍎🍎\n\n');
    return '\n🍎🍎🍎 RegisterServices: 16 Service singletons registered!';
  }
}
