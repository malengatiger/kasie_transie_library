
import 'package:kasie_transie_library/utils/functions.dart';

import 'emojis.dart';

final BaseInitializer baseInitializer = BaseInitializer();
class BaseInitializer {
  static const mm = '🐼🐼🐼🐼 BaseInitializer 🐼';

  Future initialize() async {
    // Set up Firebase Crashlytics
    // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    // pp('$mm ... FirebaseCrashlytics initialized! ${E.leaf}');
    // FlutterError.onError = (errorDetails) {
    //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    // };
    // // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    // PlatformDispatcher.instance.onError = (error, stack) {
    //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    //   return true;
    // };

    pp('$mm ... FirebaseCrashlytics error recorder initialized! '
        '${E.leaf}${E.leaf}${E.leaf}');

  }
}
