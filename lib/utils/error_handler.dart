import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/utils/kasie_exception.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:realm/realm.dart';

import '../bloc/cache_manager.dart';
import '../data/schemas.dart';
import 'device_location_bloc.dart';
import 'emojis.dart';
import 'functions.dart';

final ErrorHandler errorHandler = ErrorHandler(locationBloc, prefs);

class ErrorHandler {
  static const mm = '👿👿👿👿👿👿👿ErrorHandler: 👿👿';

  final DeviceLocationBloc locationBloc;
  final Prefs prefs;

  ErrorHandler(
    this.locationBloc,
    this.prefs,
  );

  Future sendErrors() async {
    final m = await cacheManager.getAppErrors();
    pp('${E.leaf2}${E.leaf2}${E.leaf2}${E.leaf2} '
        'ErrorHandler: sendErrors: AppErrors in cache; ${m.length} errors, sending ...');
    if (m.isNotEmpty) {
      final errors = AppErrors(m);
      await dataApiDog.addAppErrors(errors);
      await cacheManager.deleteAppErrors();
      final x = await cacheManager.getAppErrors();
      pp('${E.leaf2}${E.leaf2}${E.leaf2}${E.leaf2} '
          'ErrorHandler: sendErrors: AppError sent to backend; cache has ${x.length} app errors');
    }
  }

  Future handleError({required KasieException exception}) async {
    pp('$mm handleError, will save the error in cache until it can be downloaded: ... $exception');

    var deviceData = <String, dynamic>{};
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    String? deviceType;
    Position? errorPosition;
    try {
      final err = jsonEncode(exception);
      final dd = jsonDecode(err);

      FirebaseCrashlytics.instance
          .recordError(dd, null, reason: exception.getErrorType());

      final loc = await locationBloc.getLocation();
      pp('$mm ... location ok? $loc');
      errorPosition = Position(
          coordinates: [loc.longitude, loc.latitude!],
          type: 'Point',
          latitude: loc.latitude,
          longitude: loc.latitude);
    } catch (e) {
      pp(e);
    }
    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        if (Platform.isAndroid) {
          deviceData =
              _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
          deviceType = 'Android';
        } else if (Platform.isIOS) {
          deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
          deviceType = 'iOS';
        } else if (Platform.isLinux) {
          deviceData = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
        } else if (Platform.isMacOS) {
          deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
        }
      }
      pp('$mm ...... setting up AppError: ${exception.toString()}}');
      final user = await prefs.getUser();
      final car = await prefs.getCar();
      final ae = AppError(
        ObjectId(),
        appErrorId: Uuid.v4().toString(),
        errorMessage: exception.toString(),
        model: deviceData['model'],
        created: DateTime.now().toUtc().toIso8601String(),
        userId: user == null ? null : user!.userId,
        userName: user?.name,
        errorPosition: errorPosition,
        versionCodeName: deviceData['versionCodeName'],
        manufacturer: deviceData['manufacturer'],
        brand: deviceData['brand'],
        associationId: user?.associationId,
        uploadedDate: null,
        baseOS: deviceData['baseOS'],
        deviceType: deviceType,
        userUrl: user?.thumbnailUrl,
        vehicleId: car?.vehicleId,
        vehicleReg: car?.vehicleReg,
        iosSystemName: deviceData['systemName'],
        iosName: deviceData['iosName'],
      );

      await cacheManager.saveAppError(ae);
      final m = await cacheManager.getAppErrors();
      pp('$mm AppError saved in cache; cache has ${m.length} app errors');
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': describeEnum(data.browserName),
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'displaySizeInches':
          ((build.displayMetrics.sizeInches * 10).roundToDouble() / 10),
      'displayWidthPixels': build.displayMetrics.widthPx,
      'displayWidthInches': build.displayMetrics.widthInches,
      'displayHeightPixels': build.displayMetrics.heightPx,
      'displayHeightInches': build.displayMetrics.heightInches,
      'displayXDpi': build.displayMetrics.xDpi,
      'displayYDpi': build.displayMetrics.yDpi,
      'serialNumber': build.serialNumber,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
}

class AppErrors {
  List<AppError> appErrorList = [];
  AppErrors(this.appErrorList);

  Map<String, dynamic> toJson() {
    final list = [];
    for (var err in appErrorList) {
      list.add(err.toJson());
    }
    Map<String, dynamic> map = {
      'appErrorList': list,
    };
    return map;
  }
}
