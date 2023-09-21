import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/cache_manager.dart';
import 'package:kasie_transie_library/bloc/cloud_storage_bloc.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/bloc/the_great_geofencer.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:realm/realm.dart';
import 'package:http/http.dart' as http;
import '../utils/error_handler.dart';
import '../utils/prefs.dart';

final locator = GetIt.instance;

class LocatorInitializer {
  static const mm = ' ❤️❤️❤️❤️ LocatorInitializer: ❤️❤️: ';

  void setup() {
    //
    locator.registerLazySingleton<Prefs>(() => Prefs());

    locator.registerLazySingleton<AppAuth>(() => AppAuth(FirebaseAuth.instance));

    locator.registerLazySingleton<TheGreatGeofencer>(() => TheGreatGeofencer());

    locator.registerLazySingleton<CacheManager>(() => CacheManager());

    locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

    locator.registerLazySingleton<DeviceLocationBloc>(() => DeviceLocationBloc());

    locator.registerLazySingleton<http.Client>(() => http.Client());

    locator.registerLazySingleton<Realm>(() => Realm(config));

    locator.registerLazySingleton<ErrorHandler>(() =>
        ErrorHandler(locator.get<DeviceLocationBloc>(), locator.get<Prefs>()));

    locator.registerLazySingleton<CloudStorageBloc>(() => CloudStorageBloc());


    locator.registerLazySingleton<DataApiDog>(() => DataApiDog(
        locator.get<http.Client>(),
        locator.get<AppAuth>(),
        locator.get<CacheManager>(),
        locator.get<Prefs>(),
        locator.get<ErrorHandler>()));

    locator.registerLazySingleton<ListApiDog>(() => ListApiDog(
        locator.get<http.Client>(),
        locator.get<AppAuth>(),
        locator.get<CacheManager>(),
        locator.get<Prefs>(),
        locator.get<ErrorHandler>(),
        locator.get<Realm>()));

    pp('$mm ... LazySingletons registered ................');
  }
}
