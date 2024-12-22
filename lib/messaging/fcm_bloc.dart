import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart' as fb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/messaging/local_notif.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/zip_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/data_api_dog.dart';
import '../bloc/list_api_dog.dart';
import '../data/constants.dart';
import '../data/data_schemas.dart';
import '../utils/error_handler.dart';
import '../utils/functions.dart';
import '../utils/kasie_exception.dart';
import '../utils/prefs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FCMService fcmBloc = FCMService(fb.FirebaseMessaging.instance);
String? appName;

class FCMService {
  final fb.FirebaseMessaging firebaseMessaging;
  final mm = '🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎 FCMService: 🔵🔵 ';
  late DeviceLocationBloc locationBloc;

  FCMService(this.firebaseMessaging) {
    // initialize();
  }

  lib.User? user;
  lib.Vehicle? car;
  lib.Association? ass;
  bool demoFlag = false;
  //
  late ListApiDog listApiDog;
  late Prefs prefs;
  late DataApiDog dataApiDog;
  late ErrorHandler errorHandler;

  Future initialize() async {
    pp('\n\n$mm ... FirebaseMessaging initialize starting ... ');
     listApiDog = GetIt.instance<ListApiDog>();
     prefs = GetIt.instance<Prefs>();
     dataApiDog = GetIt.instance<DataApiDog>();
     errorHandler = GetIt.instance<ErrorHandler>();
     locationBloc = GetIt.instance<DeviceLocationBloc>();

    user = prefs.getUser();
    car = prefs.getCar();
    fb.NotificationSettings notificationSettings =
        await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    pp('$mm FCM : User granted permission?, authorizationStatus: ${notificationSettings.authorizationStatus}');

    firebaseMessaging.setAutoInitEnabled(true);
    firebaseMessaging.onTokenRefresh.listen((newToken) {
      pp("$mm listener onTokenRefresh: 🍎🍎🍎 update user: token: $newToken ... 🍎🍎");
    });
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          defaultPresentSound: true,
            );

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);

    FlutterLocalNotificationsPlugin().initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    fb.FirebaseMessaging.onMessage.listen((fb.RemoteMessage message) {
      processFCMMessage(message, getMessageType(message));
    });

    fb.FirebaseMessaging.onBackgroundMessage(
        kasieFirebaseMessagingBackgroundHandler);

    fb.FirebaseMessaging.onMessageOpenedApp.listen((fb.RemoteMessage message) {
      pp('$mm onMessageOpenedApp:  $red A new onMessageOpenedApp event was published! ${message.data}');
    });

    LocalNotificationService.initialize();

    pp("\n\n$mm FCM : FIREBASE MESSAGING initialization done! "
        "- ${E.nice} ${E.nice} ${E.nice} "
        " apps will subscribe to topics in a bit! ...........................");
  }

  static const red = '🍎🍎';
  var newMM = '🍎🍎🍎🍎🍎🍎🍎🍎 FCMBloc: 🌀🌀🌀🌀';

  Future subscribeWebApp() async {
    // These registration tokens come from the client FCM SDKs.
    const registrationTokens = [
      'YOUR_REGISTRATION_TOKEN_1',
      // ...
      'YOUR_REGISTRATION_TOKEN_n'
    ];

  }

  Future<void> subscribeForBackendMonitor(String app) async {
    appName = app;
    if (!newMM.contains(app)) {
      newMM = '$newMM$app 🔷🔷';
    }
    await firebaseMessaging.subscribeToTopic('kasieError');
    pp('$newMM ..... FCM: subscribed to topic kasieError');
    //
    await firebaseMessaging.subscribeToTopic('appError');
    pp('$newMM ..... FCM: subscribed to topic appError');
  }

  Future<void> subscribeForDemoDriver(String app) async {
    String? associationId;
    appName = app;
    newMM = '$newMM$app 🔷🔷';
    ass = prefs.getAssociation();
    demoFlag = prefs.getDemoFlag();
    if (ass != null) {
      associationId = ass!.associationId!;
    } else {
      return;
    }
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.commuterRequest}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.commuterRequest}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.heartbeat}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.heartbeat}$associationId');
//
    await firebaseMessaging
        .subscribeToTopic('${Constants.dispatchRecord}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.dispatchRecord}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.passengerCount}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.passengerCount}$associationId');

    await firebaseMessaging
        .subscribeToTopic('${Constants.vehicleArrival}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.vehicleArrival}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.vehicleDeparture}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.vehicleDeparture}$associationId');
    //
    pp('$newMM .............................................'
        ' FCM: subscribed to all ${E.pear} 5 (five) DemoDriver FCM topics\n\n');
  }

  Future<void> subscribeForCar(String app) async {
    String? associationId;
    appName = app;
    newMM = '$newMM$app 🔷🔷';
    car = prefs.getCar();
    demoFlag = prefs.getDemoFlag();
    if (car != null) {
      associationId = car!.associationId!;
    } else {
      return;
    }

    await firebaseMessaging
        .subscribeToTopic('${Constants.routeUpdateRequest}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.routeUpdateRequest}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.locationRequest}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.locationRequest}$associationId');

    pp('$newMM .............................................'
        ' FCM: subscribed to all ${E.pear} Car FCM topics\n\n');
  }

  Future<void> subscribeForOwnerMarshalOfficialAmbassador(String app) async {
    String? associationId;
    appName = app;
    newMM = '$newMM$app 🔷🔷';
    user = prefs.getUser();
    demoFlag = prefs.getDemoFlag();
    if (user != null) {
      associationId = user!.associationId!;
    } else {
      return;
    }
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.heartbeat}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.heartbeat}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.dispatchRecord}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.dispatchRecord}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.passengerCount}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.passengerCount}$associationId');

    await firebaseMessaging
        .subscribeToTopic('${Constants.vehicleArrival}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.vehicleArrival}$associationId');

    await firebaseMessaging
        .subscribeToTopic('${Constants.locationResponse}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.locationResponse}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.vehicleDeparture}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.vehicleDeparture}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.routeUpdateRequest}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.routeUpdateRequest}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.vehicleChanges}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.vehicleChanges}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.vehicleDeparture}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.vehicleDeparture}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.userGeofenceEvent}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.userGeofenceEvent}$associationId');
    //
    pp('$newMM ........................................'
        ' FCM: subscribed to all ${E.pear} 9 OwnerMarshalOfficialAmbassador FCM topics\n\n');
  }

  Future<void> subscribeForCommuter(String app) async {
    String? associationId;
    appName = app;
    newMM = '$newMM$app 🔷🔷';
    user = prefs.getUser();
    final association = prefs.getAssociation();
    if (association != null) {
      associationId = association.associationId!;
    }
    demoFlag = prefs.getDemoFlag();
    if (user != null) {
      associationId = user!.associationId!;
    }

    if (associationId == null) {
      pp('$newMM ... association is null. ${E.redDot}${E.redDot}${E.redDot}'
          ' cannot subscribe');
      return;
    }
    await firebaseMessaging
        .subscribeToTopic('${Constants.routeUpdateRequest}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.routeUpdateRequest}$associationId');
    //

    pp('$newMM ........................................'
        ' FCM: subscribed to all ${E.pear} 1 RouteBuilder FCM topics\n\n');
  }
  Future<void> subscribeForRouteBuilder(String app) async {
    String? associationId;
    appName = app;
    newMM = '$newMM$app 🔷🔷';
    user = prefs.getUser();
    final association = prefs.getAssociation();
    if (association != null) {
      associationId = association.associationId!;
    }
    demoFlag = prefs.getDemoFlag();
    if (user != null) {
      associationId = user!.associationId!;
    }

    if (associationId == null) {
      pp('$newMM ... association is null. ${E.redDot}${E.redDot}${E.redDot}'
          ' cannot subscribe');
      return;
    }
    await firebaseMessaging
        .subscribeToTopic('${Constants.routeUpdateRequest}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.routeUpdateRequest}$associationId');
    //

    pp('$newMM ........................................'
        ' FCM: subscribed to all ${E.pear} 1 RouteBuilder FCM topics\n\n');
  }

  Future<void> subscribeToTopics(String app) async {
    appName = app;
    newMM = '$newMM$app 🔷🔷';
    user = prefs.getUser();
    car = prefs.getCar();
    demoFlag = prefs.getDemoFlag();

    String? associationId;
    if (user != null) {
      associationId = user!.associationId!;
    }
    if (car != null) {
      associationId = car!.associationId!;
    }
    if (ass != null) {
      associationId = ass!.associationId!;
    }

    if (associationId == null) {
      return;
    }

    //todo - cut up subscriptions for each user type (or app)

    pp("\n\n$newMM subscribeToTopics: $red start to subscribe to all KasieTransie FCM topics ... ");

    await firebaseMessaging
        .subscribeToTopic('${Constants.vehicleChanges}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.vehicleChanges}$associationId');

    await firebaseMessaging
        .subscribeToTopic('${Constants.routeUpdateRequest}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.routeUpdateRequest}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.vehicleArrival}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.vehicleArrival}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.vehicleDeparture}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.vehicleDeparture}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.dispatchRecord}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.dispatchRecord}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.passengerCount}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.passengerCount}$associationId');

    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.locationResponse}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.locationResponse}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.locationRequest}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.locationRequest}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.userGeofenceEvent}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.userGeofenceEvent}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.vehicleMediaRequest}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.vehicleMediaRequest}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.commuterRequest}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.commuterRequest}$associationId');
    //
    await firebaseMessaging
        .subscribeToTopic('${Constants.heartbeat}$associationId');
    pp('$newMM ..... FCM: subscribed to ${Constants.heartbeat}$associationId');

    pp('$newMM ..... FCM: subscribed to all ${E.pear} 12 (twelve) KasieTransie FCM topics\n\n');
    //
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    pp("$newMM onDidReceiveLocalNotification: $red processing message title: $title body: $body ");
  }


  Future<void> processFCMMessage(fb.RemoteMessage message, String type) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    myName = packageInfo.appName;
    if (!newMM.contains(myName!)) {
      newMM = '$newMM $myName :';
    }

    // final map = message.data['data'];
    final data1 = message.data;
    var type = data1['type'];
    final data = jsonDecode(data1['data']);
    pp("$newMM processFCMMessage: $red message received in "
        "foreground: ${E.leaf}${E.leaf} type: $type ");

    switch (type) {
      case Constants.vehicleChanges:
        _vehicleChangesStreamController.sink.add(data as String);
        break;

      case Constants.vehicleArrival:
        _processVehicleArrival(VehicleArrival.fromJson(data));
        break;

      case Constants.vehicleDeparture:
        _processVehicleDeparture(VehicleDeparture.fromJson(data));
        break;

      case Constants.dispatchRecord:
        final kk = DispatchRecord.fromJson(data);
        _processDispatchRecord(kk);
        break;

      case Constants.passengerCount:
        final kk = AmbassadorPassengerCount.fromJson(data);
        _processPassengerCount(kk);
        break;

      case Constants.heartbeat:
        final kk = VehicleHeartbeat.fromJson(data);
        _processHeartbeat(kk);
        break;

      case Constants.commuterRequest:
        final kk = CommuterRequest.fromJson(data);
        _processCommuterRequest(kk);
        break;

      case Constants.commuterResponse:
        final kk = CommuterResponse.fromJson(data);
        _processCommuterResponse(kk);
        break;

      case Constants.locationRequest:
        final locReq = LocationRequest.fromJson(data);
        _processLocationRequest(locReq);
        break;

      case Constants.locationResponse:
        final resp = LocationResponse.fromJson(data);
        _processLocationResponse(resp);
        break;

      case Constants.userGeofenceEvent:
        _userGeofenceStreamController.sink.add(UserGeofenceEvent.fromJson(data));
        break;

      case Constants.vehicleMediaRequest:
        final req = VehicleMediaRequest.fromJson(data);
        _processMediaRequest(req);
        break;

      case Constants.routeUpdateRequest:
        final req = RouteUpdateRequest.fromJson(data);
        _processRouteUpdate(req);
        break;
      case Constants.appError:
        _appErrorStreamController.sink.add(data);
        break;
      case Constants.kasieError:
        _kasieErrorStreamController.sink.add(data);
        break;

      default:
        pp('$newMM ... SWITCH statement fell all the way through: type: $type ... ');
        break;
    }
  }

  void _processVehicleDeparture(lib.VehicleDeparture departure) {
    pp('$newMM _processVehicleDeparture ... ${departure.vehicleReg}');

    if (demoFlag) {
      _vehicleDepartureStreamController.sink.add(departure);
      return;
    }
    if (user != null) {
      if (user!.userId == departure.ownerId ||
          user!.userType == 'ASSOCIATION_OFFICIAL') {
        _vehicleDepartureStreamController.sink.add(departure);
      }
    }
    if (car != null) {
      if (car!.vehicleId == departure.vehicleId) {
        _vehicleDepartureStreamController.sink.add(departure);
      }
    }
  }

  void _processVehicleArrival(lib.VehicleArrival arrival) {
    pp('$newMM _processVehicleArrival ... ${arrival.vehicleReg}');

    if (demoFlag) {
      _vehicleArrivalStreamController.sink.add(arrival);
      return;
    }
    if (user != null) {
      if (user!.userId == arrival.ownerId ||
          user!.userType == 'ASSOCIATION_OFFICIAL') {
        _vehicleArrivalStreamController.sink.add(arrival);
      }
    }
    if (car != null) {
      if (car!.vehicleId == arrival.vehicleId) {
        _vehicleArrivalStreamController.sink.add(arrival);
      }
    }
  }

  void _processDispatchRecord(lib.DispatchRecord dispatchRecord) {
    pp('$newMM _processDispatchRecord ... ${dispatchRecord.vehicleReg}');

    if (demoFlag) {
      _dispatchStreamController.sink.add(dispatchRecord);
      return;
    }
    if (user != null) {
      if (user!.userId == dispatchRecord.marshalId ||
          user!.userId == dispatchRecord.ownerId ||
          user!.userType == 'ASSOCIATION_OFFICIAL') {
        _dispatchStreamController.sink.add(dispatchRecord);
      }
    }
    if (car != null) {
      if (car!.vehicleId == dispatchRecord.vehicleId) {
        _dispatchStreamController.sink.add(dispatchRecord);
      }
    }
  }

  void _processRouteUpdate(lib.RouteUpdateRequest req) async {
    pp('$newMM _processRouteUpdate ... ${req.routeName}');
    var routesIsolate = GetIt.instance<ZipHandler>();
    await routesIsolate.refreshRoute(routeId: req.routeId!);
    _routeUpdateRequestStreamController.sink.add(req);
  }

  void _processLocationResponse(lib.LocationResponse resp) async {
    pp('$newMM _processLocationResponse ... ${resp.vehicleReg}');

    //myPrettyJsonPrint(resp.toJson());
    if (user == null) {
      return;
    }
    if (user!.userId == resp.userId) {
      _locationResponseStreamController.sink.add(resp);
    }
  }

  void _processMediaRequest(lib.VehicleMediaRequest req) async {
    pp('$newMM _processMediaRequest ... ${req.vehicleReg}');

    if (user != null) {
      if (user!.userId == req.userId) {
        pp('\n$newMM ... IGNORE ... this is my own request ....');
      } else {
        pp('\n\n$newMM ... ACCEPT ... refreshing assoc requests ${E.blueDot} ...');
        final startDate = DateTime.now()
            .toUtc()
            .subtract(const Duration(hours: 4))
            .toIso8601String();
        await listApiDog.getAssociationVehicleMediaRequests(
            req.associationId!, startDate, true);
        _vehicleMediaRequestStreamController.sink.add(req);
      }
    }
    if (car != null) {
      if (car!.vehicleId == req.vehicleId) {
        pp('\n\n$newMM ... ACCEPT ... this request is for me! ${E.blueDot} '
            'what now, Boss? ...');
        _vehicleMediaRequestStreamController.sink.add(req);
      }
    }
  }

  void _processPassengerCount(lib.AmbassadorPassengerCount passengerCount) {
    pp('$newMM _processPassengerCount ... ${passengerCount.vehicleReg}');

    if (demoFlag) {
      _passengerCountStreamController.sink.add(passengerCount);
      return;
    }
    if (car != null) {
      if (car!.vehicleId == passengerCount.vehicleId) {
        _passengerCountStreamController.sink.add(passengerCount);
      }
    }
    pp('$mm _processPassengerCount ... ${E.redDot} check ownerId : ${passengerCount.userId} - userId: ${user!.userId}');
    if (user!.userId == passengerCount.ownerId) {
      _passengerCountStreamController.sink.add(passengerCount);
      pp('$mm _processPassengerCount: _passengerCountStreamController '
          'has a new AmbassadorPassengerCount: ');
      // myPrettyJsonPrint(passengerCount.toJson());
    }
    if (user!.userType == 'ASSOCIATION_OFFICIAL') {
      _passengerCountStreamController.sink.add(passengerCount);
      return;
    }
  }

  void _processCommuterRequest(lib.CommuterRequest commuterRequest) {
    pp('$newMM _processCommuterRequest ... ${commuterRequest.routeName}');

    if (demoFlag) {
      _commuterRequestStreamController.sink.add(commuterRequest);
      return;
    }
    if (user!.userType == Constants.ASSOCIATION_OFFICIAL ||
        user!.userType == Constants.AMBASSADOR ||
        user!.userType == Constants.MARSHAL) {
      _commuterRequestStreamController.sink.add(commuterRequest);
      return;
    }
  }
  void _processCommuterResponse(lib.CommuterResponse commuterResponse) {
    pp('$newMM _processCommuterResponse ... ${commuterResponse.routeName}');

    if (demoFlag) {
      // _commuterRequestStreamController.sink.add(commuterRequest);
      return;
    }
    _commuterResponseStreamController.sink.add(commuterResponse);

  }

  void _processHeartbeat(lib.VehicleHeartbeat heartbeat) {
    pp('$newMM _processHeartbeat ... ${heartbeat.vehicleReg} - owner: ${heartbeat.ownerName}');

    if (demoFlag) {
      _heartbeatStreamController.sink.add(heartbeat);
      return;
    }
    if (user != null) {
      if (user!.userType == Constants.ASSOCIATION_OFFICIAL ||
          user!.userType == Constants.AMBASSADOR ||
          user!.userType == Constants.MARSHAL ||
          demoFlag) {
        _heartbeatStreamController.sink.add(heartbeat);
        return;
      }
    }
    if (car != null) {
      if (car!.vehicleId! == heartbeat.vehicleId) {
        _heartbeatStreamController.sink.add(heartbeat);
      }
    }
  }

  void _processLocationRequest(lib.LocationRequest request) async {
    pp('$newMM checking if vehicle location request is for me ...');
    final car = prefs.getCar();
    if (car == null) {
      pp('$newMM location request is NOT for me. ${E.redDot}${E.redDot}${E.redDot} ');
      return;
    }
    if (request.vehicleId == car.vehicleId) {
      pp('$newMM location request is for me! ... must respond!!');
      final loc = await locationBloc.getLocation();
      final resp = lib.LocationResponse(

        associationId: car.associationId,
        created: DateTime.now().toUtc().toIso8601String(),
        userId: request.userId,
        userName: request.userName,
        vehicleId: car.vehicleId,
        vehicleReg: car.vehicleReg,
        position: lib.Position(
          type: 'Point',
          coordinates: [loc.longitude, loc.latitude],
          latitude: loc.latitude,
          longitude: loc.longitude,
        ),
      );
      try {
        pp('$newMM sending location response! ${E.blueDot}');
        final result = await dataApiDog.addLocationResponse(resp);
        pp('$newMM location response successfully sent! ${E.leaf} ');
        // myPrettyJsonPrint(result.toJson());
      } catch (e) {
        pp(e);
      }
    } else {
      pp('$newMM ... nice try, but this location request is definitely not for me. ${E.blueDot}');
    }
  }

  void refreshRoute(String routeId) async {
    final bag = await listApiDog.refreshRoute(routeId);
    pp('\n\n$newMM bag has arrived in fcmBloc. Seems like everything is OK, Boss! '
        'route refreshed: ${E.nice}${E.nice} ${bag.route!.name} ${E.nice}\n');
  }

  void onDidReceiveNotificationResponse(NotificationResponse details) {
    pp("$newMM onDidReceiveNotificationResponse: $red details: ${details.payload} ");
  }

  final StreamController<String> _routeChangesStreamController =
      StreamController.broadcast();

  Stream<String> get routeChangesStream => _routeChangesStreamController.stream;

  final StreamController<String> _vehicleChangesStreamController =
      StreamController.broadcast();

  Stream<String> get vehicleChangesStream =>
      _vehicleChangesStreamController.stream;

  final StreamController<lib.VehicleDeparture>
      _vehicleDepartureStreamController = StreamController.broadcast();

  Stream<lib.VehicleDeparture> get vehicleDepartureStream =>
      _vehicleDepartureStreamController.stream;

  final StreamController<lib.VehicleArrival> _vehicleArrivalStreamController =
      StreamController.broadcast();

  Stream<lib.VehicleArrival> get vehicleArrivalStream =>
      _vehicleArrivalStreamController.stream;

  final StreamController<lib.DispatchRecord> _dispatchStreamController =
      StreamController.broadcast();

  Stream<lib.DispatchRecord> get dispatchStream =>
      _dispatchStreamController.stream;

  final StreamController<lib.UserGeofenceEvent> _userGeofenceStreamController =
      StreamController.broadcast();

  Stream<lib.UserGeofenceEvent> get userGeofenceStream =>
      _userGeofenceStreamController.stream;

  final StreamController<lib.VehicleMediaRequest>
      _vehicleMediaRequestStreamController = StreamController.broadcast();
  final StreamController<lib.RouteUpdateRequest>
      _routeUpdateRequestStreamController = StreamController.broadcast();

  final StreamController<lib.CommuterRequest> _commuterRequestStreamController =
      StreamController.broadcast();

  Stream<lib.CommuterRequest> get commuterRequestStreamStream =>
      _commuterRequestStreamController.stream;

  final StreamController<lib.CommuterResponse> _commuterResponseStreamController =
  StreamController.broadcast();

  Stream<lib.CommuterResponse> get commuterResponseStreamStream =>
      _commuterResponseStreamController.stream;


  addCommuterRequest(CommuterRequest request) {
    _commuterRequestStreamController.sink.add(request);
  }
  final StreamController<lib.VehicleHeartbeat> _heartbeatStreamController =
      StreamController.broadcast();

  Stream<lib.VehicleHeartbeat> get heartbeatStreamStream =>
      _heartbeatStreamController.stream;

  Stream<lib.RouteUpdateRequest> get routeUpdateRequestStream =>
      _routeUpdateRequestStreamController.stream;

  Stream<lib.VehicleMediaRequest> get vehicleMediaRequestStream =>
      _vehicleMediaRequestStreamController.stream;

  final StreamController<lib.LocationRequest> _locationRequestStreamController =
      StreamController.broadcast();

  Stream<lib.LocationRequest> get locationRequestStream =>
      _locationRequestStreamController.stream;

  final StreamController<lib.LocationResponse>
      _locationResponseStreamController = StreamController.broadcast();

  Stream<lib.LocationResponse> get locationResponseStream =>
      _locationResponseStreamController.stream;

  final StreamController<lib.AmbassadorPassengerCount>
      _passengerCountStreamController = StreamController.broadcast();

  Stream<lib.AmbassadorPassengerCount> get passengerCountStream =>
      _passengerCountStreamController.stream;

  final StreamController<Map<String, dynamic>> _appErrorStreamController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get appErrorStream =>
      _appErrorStreamController.stream;

  final StreamController<Map<String, dynamic>> _kasieErrorStreamController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get kasieErrorStream =>
      _kasieErrorStreamController.stream;
}

///Handling FCM messages in the background
///
String? myName;
var mxx = '💙💙💙💙💙💙FCM Background Processing:  💙💙';

@pragma('vm:entry-point')
Future kasieFirebaseMessagingBackgroundHandler(
    fb.RemoteMessage message) async {
  // await Firebase.initializeApp();
  pp("\n\n$mxx 🍎🍎🍎🍎handle message in background 🍎🍎🍎🍎 ....");

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  myName = packageInfo.appName;
  if (!mxx.contains(myName!)) {
    mxx = '$mxx $myName :';
  }

  final data = message.data;
  final type = getMessageType(message);

  pp("$mxx 🍎🍎🍎🍎handle message in background! NO-OP except for locationRequest! 🍎🍎🍎🍎type: $type");

  try {
    switch (type) {
      case Constants.locationRequest:
        final locReq = LocationRequest.fromJson(data);
        handleLocationRequest(locReq);
        break;
      // case Constants.locationResponse:
      //   final r = buildLocationResponse(data);
      //   handleLocationResponse(r);
      //   break;
      // case Constants.dispatchRecord:
      //   final dispatch = buildDispatchRecord(data);
      //   handleDispatch(dispatch);
      //   break;
      // case Constants.passengerCount:
      //   final count = buildAmbassadorPassengerCount(data);
      //   handlePassengerCount(count);
      //   break;
      // case Constants.heartbeat:
      //   final h = buildVehicleHeartbeat(data);
      //   handleHeartbeat(h);
      //   break;
      // case Constants.vehicleArrival:
      //   final a = buildVehicleArrival(data);
      //   handleVehicleArrival(a);
      //   break;
      // case Constants.vehicleDeparture:
      //   final d = buildVehicleDeparture(data);
      //   handleVehicleDeparture(d);
      //   break;
      // case Constants.routeUpdateRequest:
      //   final d = buildRouteUpdateRequest(data);
      //   routesIsolate.refreshRoute(d.routeId!);
      //   break;
    }
  } catch (e, s) {
    pp('${E.redDot}${E.redDot}${E.redDot}${E.redDot}${E.redDot}${E.redDot}'
        '${E.redDot}${E.redDot} stackTrace: $s');
    pp('$e $s');
  }
}

///message handlers
void handleLocationResponse(lib.LocationResponse response) async {
  pp('$mxx ... handleLocationResponse in background ...');
  final user = await getUserInBackground();

  if (user != null) {
    if (user.userType == Constants.OWNER) {
      if (user.userId == response.userId) {
        //cacheLocationResponse(response);
      }
    }

    if (user.userType == Constants.ASSOCIATION_OFFICIAL) {
      //cacheLocationResponse(response);
    }
  }
}

void handleHeartbeat(lib.VehicleHeartbeat heartbeat) async {
  pp('$mxx ... handleHeartbeat in background ...');

  final user = await getUserInBackground();

  if (user != null) {
    if (user.userType == Constants.OWNER) {
      if (user.userId == heartbeat.ownerId) {
        //cacheHeartbeat(heartbeat);
      }
    }

    if (user.userType == Constants.ASSOCIATION_OFFICIAL) {
      //cacheHeartbeat(heartbeat);
    }
  }
}

void handlePassengerCount(lib.AmbassadorPassengerCount passengerCount) async {
  pp('$mxx ... handlePassengerCount in background ...');

  final user = await getUserInBackground();

  if (user != null) {
    if (user.userType == Constants.OWNER) {
      if (user.userId == passengerCount.ownerId) {
        //cachePassengerCount(passengerCount);
      }
    }

    if (user.userType == Constants.ASSOCIATION_OFFICIAL) {
      //cachePassengerCount(passengerCount);
    }
  }
}

void handleDispatch(lib.DispatchRecord dispatchRecord) async {
  pp('$mxx ... handleDispatch in background ...');

  final user = await getUserInBackground();

  if (user != null) {
    if (user.userType == Constants.OWNER) {
      if (user.userId == dispatchRecord.ownerId) {
        //cacheDispatchRecord(dispatchRecord);
      }
    }

    if (user.userType == Constants.ASSOCIATION_OFFICIAL) {
      //cacheDispatchRecord(dispatchRecord);
    }
  }
}

void handleVehicleDeparture(lib.VehicleDeparture departure) async {
  pp('$mxx ... handleVehicleDeparture in background ...');

  final user = await getUserInBackground();

  if (user != null) {
    if (user.userType == Constants.OWNER) {
      if (user.userId == departure.ownerId) {
        //cacheVehicleDeparture(departure);
      }
    }

    if (user.userType == Constants.ASSOCIATION_OFFICIAL) {
      //cacheVehicleDeparture(departure);
    }
  }
}

void handleVehicleArrival(lib.VehicleArrival arrival) async {
  pp('$mxx ... handleVehicleArrival in background ...');

  final user = await getUserInBackground();

  if (user != null) {
    if (user.userType == Constants.OWNER) {
      if (user.userId == arrival.ownerId) {
        //cacheVehicleArrival(arrival);
      }
    }

    if (user.userType == Constants.ASSOCIATION_OFFICIAL) {
      //cacheVehicleArrival(arrival);
    }
  }
}

// void cacheLocationResponse(lib.LocationResponse object) {
//   listApiDog.realm.write(() {
//     listApiDog.realm.add<lib.LocationResponse>(object);
//   });
// }
//
// void cachePassengerCount(lib.AmbassadorPassengerCount object) {
//   listApiDog.realm.write(() {
//     listApiDog.realm.add<lib.AmbassadorPassengerCount>(object);
//   });
// }
//
// void cacheHeartbeat(lib.VehicleHeartbeat object) {
//   listApiDog.realm.write(() {
//     listApiDog.realm.add<lib.VehicleHeartbeat>(object);
//   });
// }
//
// void cacheVehicleArrival(lib.VehicleArrival object) {
//   listApiDog.realm.write(() {
//     listApiDog.realm.add<lib.VehicleArrival>(object);
//   });
// }
//
// void cacheVehicleDeparture(lib.VehicleDeparture object) {
//   listApiDog.realm.write(() {
//     listApiDog.realm.add<lib.VehicleDeparture>(object);
//   });
// }
//
// void cacheDispatchRecord(lib.DispatchRecord object) {
//   listApiDog.realm.write(() {
//     listApiDog.realm.add<lib.DispatchRecord>(object);
//   });
// }

Future<lib.User?> getUserInBackground() async {
  lib.User? user;
  final prefs1 = await SharedPreferences.getInstance();
  prefs1.reload(); // The magic line
  var string = prefs1.getString('user');
  if (string == null) {
    pp('\n\n$mxx ... ${E.redDot}${E.redDot}${E.redDot} user is null in background ... \n\n');
    return null;
  }
  var jx = json.decode(string);
  user = User.fromJson(jx);
  pp('$mxx ... this user is responding while in background');
  //myPrettyJsonPrint(user.toJson());

  return user;
}

Future<lib.Vehicle?> getCarInBackground() async {
  lib.Vehicle? car;
  final prefs1 = await SharedPreferences.getInstance();
  prefs1.reload(); // The magic line
  var string = prefs1.getString('car');
  if (string == null) {
    pp('\n\n$mxx ... ${E.redDot}${E.redDot}${E.redDot} car is null in background ... \n\n');
    return null;
  }
  var jx = json.decode(string);
  car = Vehicle.fromJson(jx);
  pp('$mxx ... this car is responding while in background');
  //myPrettyJsonPrint(car.toJson());

  return car;
}

void handleLocationRequest(lib.LocationRequest request) async {
  pp('$mxx ... handleLocationRequest in background ...');

  lib.Vehicle? car = await getCarInBackground();
  if (car == null) {
    return;
  }

  if (car.vehicleId == request.vehicleId) {
    pp('\n\n$mxx ... this request is for me .... ${E.blueDot} gotta respond!');
    respondToLocationRequest(request: request, token: 'myToken', car: car);
  }
}

void respondToLocationRequest(
    {required lib.LocationRequest request,
    required String token,
    required lib.Vehicle car}) async {
  DeviceLocationBloc locationBloc = GetIt.instance<DeviceLocationBloc>();
  final loc = await locationBloc.getLocation();
  pp('$mxx .. location in background: $loc');
  final resp = lib.LocationResponse(
    associationId: car.associationId,
    created: DateTime.now().toUtc().toIso8601String(),
    userId: request.userId,
    userName: request.userName,
    vehicleId: car.vehicleId,
    vehicleReg: car.vehicleReg,
    position: lib.Position(
      type: 'Point',
      coordinates: [loc.longitude, loc.latitude],
      latitude: loc.latitude,
      longitude: loc.longitude,
    ),
  );
  try {
    pp('$mxx sending background location response! ${E.blueDot}');
    final result = await _sendLocationResponse(resp, token);
    pp('$mxx background location response successfully sent! ${E.leaf} ');
    //myPrettyJsonPrint(result);
  } catch (e) {
    pp(e);
  }
}

Future _sendLocationResponse(lib.LocationResponse resp, String fcmToken) async {
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final urlPrefix = KasieEnvironment.getUrl();
  final mUrl = '${urlPrefix}addLocationResponse';
  pp('$mxx _sendLocationResponse: 🔆🔆🔆 ...... calling : 💙 $mUrl  💙');
  ErrorHandler errorHandler = GetIt.instance<ErrorHandler>();
  String? mBag;
  mBag = json.encode(resp.toJson());

  var start = DateTime.now();
  headers['Authorization'] = 'Bearer $fcmToken';
  final client = http.Client();
  try {
    var resp = await client
        .post(
          Uri.parse(mUrl),
          body: mBag,
          headers: headers,
        )
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode == 200) {
      pp('$mxx  _sendLocationResponse RESPONSE: 💙💙 statusCode: 👌👌👌 ${resp.statusCode} 👌👌👌 💙 for $mUrl');
    } else {
      pp('$mxx  👿👿👿_sendLocationResponse: 🔆 statusCode: 👿👿👿 ${resp.statusCode} 🔆🔆🔆 for $mUrl');
      pp(resp.body);
      throw KasieException(
          message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.socketException);
    }
    var end = DateTime.now();
    pp('$mxx  _sendLocationResponse: 🔆 elapsed time: ${end.difference(start).inSeconds} seconds 🔆');
    try {
      var mJson = json.decode(resp.body);
      return mJson;
    } catch (e) {
      pp("$mxx 👿👿👿👿👿👿👿 json.decode failed, returning response body");
      return resp.body;
    }
  } on SocketException {
    pp('$mxx  SocketException: really means that server cannot be reached 😑');
    final gex = KasieException(
        message: 'Server not available',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.socketException);

    errorHandler.handleError(exception: gex);
    throw gex;
  } on HttpException {
    pp("$mxx  HttpException occurred 😱");
    final gex = KasieException(
        message: 'Server not available',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.httpException);
    errorHandler.handleError(exception: gex);
    throw gex;
  } on FormatException {
    pp("$mxx  Bad response format 👎");
    final gex = KasieException(
        message: 'Bad response format',
        url: mUrl,
        translationKey: 'serverProblem',
        errorType: KasieException.formatException);
    errorHandler.handleError(exception: gex);
    throw gex;
  } on TimeoutException {
    pp("$mxx  No Internet connection. Request has timed out in 30 seconds 👎");
    final gex = KasieException(
        message: 'Request timed out. No Internet connection',
        url: mUrl,
        translationKey: 'networkProblem',
        errorType: KasieException.timeoutException);
    errorHandler.handleError(exception: gex);
    throw gex;
  }
}

//
String getMessageType(fb.RemoteMessage message) {
  //myPrettyJsonPrint(message.data);
  final data = message.data;
  var type = data['type'];
  pp("$mxx onMessage: ${E.pear} ${E.pear}${E.pear} $type - FCM message has arrived!  ... ${E.pear}${E.pear} ");
  if (type != null) {
    return type;
  }
  pp("$mxx onMessage: unknown message has arrived!  ...");
  return 'unknown';
}
