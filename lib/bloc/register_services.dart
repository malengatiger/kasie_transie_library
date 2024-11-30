import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/cloud_storage_bloc.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/bloc/the_great_geofencer.dart';
import 'package:kasie_transie_library/bloc/theme_bloc.dart';
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

  static Future<void> register() async {
    pp('\n\n$mm  ... initialize service singletons with GetIt .... 🍎🍎🍎');

    final http.Client client = http.Client();
    final AppAuth appAuth = AppAuth(FirebaseAuth.instance);
    pp('$mm .... AppAuth: 🦠auth initialized');

    final CacheManager cacheManager = CacheManager();
    final Prefs prefs = Prefs(await SharedPreferences.getInstance());
    final ErrorHandler errorHandler = ErrorHandler(DeviceLocationBloc(), prefs);

    final SemCache semCache = SemCache();
    pp('$mm .... SemCache: 🦠cache initialized');
    final ZipHandler zipHandler = ZipHandler(appAuth, semCache);
    pp('$mm .... ZipHandler: 🦠handler initialized');
    final dataApi = DataApiDog(
        client, appAuth, cacheManager, prefs, errorHandler, semCache);
    pp('$mm .... DataApiDog: 🦠dataApiDog initialized');
    final listApi =
        ListApiDog(client, appAuth, prefs, errorHandler, zipHandler, semCache);
    pp('$mm .... ListApiDog: 🦠listApiDog initialized');
    //
    pp('$mm ..... 🦠🦠🦠🦠🦠registerLazySingletons ...');

    GetIt.instance.registerLazySingleton<KasieThemeManager>(() => KasieThemeManager(prefs));
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... KasieThemeManager');

    GetIt.instance.registerLazySingleton<RouteUpdateListener>(() => RouteUpdateListener());
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... RouteUpdateListener');

    GetIt.instance.registerLazySingleton<DeviceLocationBloc>(() => DeviceLocationBloc());
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... DeviceLocationBloc');

    GetIt.instance.registerLazySingleton<SemCache>(() => semCache);

    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... SemCache');

    GetIt.instance.registerLazySingleton<ZipHandler>(() => zipHandler);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... ZipHandler');

    GetIt.instance.registerLazySingleton<RouteDistanceCalculator>(
        () => RouteDistanceCalculator(prefs, listApi, dataApi));
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... RouteDistanceCalculator');

    GetIt.instance.registerLazySingleton<CloudStorageBloc>(
        () => CloudStorageBloc(dataApi, prefs));
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... CloudStorageBloc');

    GetIt.instance.registerLazySingleton<TheGreatGeofencer>(
        () => TheGreatGeofencer(dataApi, listApi, prefs));
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... TheGreatGeofencer');

    GetIt.instance.registerLazySingleton<KasieThemeManager>(() => KasieThemeManager(prefs));
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... ThemeBloc');

    GetIt.instance.registerLazySingleton<ListApiDog>(() => listApi);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... ListApiDog');

    GetIt.instance.registerLazySingleton<DataApiDog>(() => dataApi);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... DataApiDog');

    GetIt.instance.registerLazySingleton<CacheManager>(() => cacheManager);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... CacheManager');

    GetIt.instance.registerLazySingleton<Prefs>(() => prefs);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... Prefs');

    GetIt.instance.registerLazySingleton<AppAuth>(() => appAuth);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... AppAuth');

    GetIt.instance.registerLazySingleton<ErrorHandler>(() => errorHandler);
    pp('$mm 🦠🦠🦠🦠🦠registerLazySingletons ... ErrorHandler');


    pp('\n\n$mm   🍎🍎🍎 13 Service singletons registered! .... 🍎🍎🍎\n');
  }
}
