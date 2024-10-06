import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/cloud_storage_bloc.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/bloc/the_great_geofencer.dart';
import 'package:kasie_transie_library/bloc/theme_bloc.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
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
  static const mm = '🅿️ 🅿️ 🅿️ 🅿️ RegisterServices  🅿️ 🅿️';
  static String dbPath = 'kasie.db';
  static DatabaseFactory dbFactory = databaseFactoryWeb;

  static Future<void> register() async {
    pp('\n\n$mm  initialize service singletons with GetIt .... 🍎🍎🍎');

    final http.Client client = http.Client();
    final AppAuth appAuth = AppAuth(FirebaseAuth.instance);
    final CacheManager cacheManager = CacheManager();
    final Prefs prefs = Prefs(await SharedPreferences.getInstance());
    final ErrorHandler errorHandler = ErrorHandler(DeviceLocationBloc(), prefs);
    final Database db= await dbFactory.openDatabase(dbPath);
    pp('$mm .... dbFactory.openDatabase: 🦠database initialized: ${db.path}');

    final SemCache semCache = SemCache(db);
    pp('$mm .... SemCache: 🦠cache initialized');

    final ZipHandler zipHandler = ZipHandler(appAuth, semCache);
    pp('$mm .... ZipHandler: 🦠handler initialized');

    final dataApi =
        DataApiDog(client, appAuth, cacheManager, prefs, errorHandler, semCache);
    pp('$mm .... DataApiDog: 🦠dataApiDog initialized');

    final listApi =
        ListApiDog(client, appAuth, prefs, errorHandler, zipHandler, semCache);
    //
    pp('$mm .... SemCachee: 🦠registerLazySingletons ...');

    GetIt.instance.registerLazySingleton<SemCache>(
            () => semCache);
    GetIt.instance.registerLazySingleton<ZipHandler>(
            () => zipHandler);
    GetIt.instance.registerLazySingleton<RouteDistanceCalculator>(
        () => RouteDistanceCalculator(prefs, listApi, dataApi));

    GetIt.instance.registerLazySingleton<CloudStorageBloc>(
            () => CloudStorageBloc(dataApi, prefs));

    GetIt.instance.registerLazySingleton<TheGreatGeofencer>(
        () => TheGreatGeofencer(dataApi, listApi, prefs));

    GetIt.instance.registerLazySingleton<ThemeBloc>(() => ThemeBloc(prefs));

    GetIt.instance.registerLazySingleton<ListApiDog>(() => listApi);

    GetIt.instance.registerLazySingleton<DataApiDog>(() => dataApi);

    GetIt.instance.registerLazySingleton<CacheManager>(() => cacheManager);

    GetIt.instance.registerLazySingleton<Prefs>(() => prefs);

    GetIt.instance.registerLazySingleton<AppAuth>(() => appAuth);

    GetIt.instance.registerLazySingleton<ErrorHandler>(() => errorHandler);

    pp('$mm  11 Service singletons registered! .... 🍎🍎🍎\n');
  }
}
