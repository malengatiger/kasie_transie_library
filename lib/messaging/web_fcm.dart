import 'dart:async';

import 'package:firebase_messaging_platform_interface/src/remote_message.dart';
import 'package:firebase_messaging_web/firebase_messaging_web.dart'  as msg;
import 'package:kasie_transie_library/data/data_schemas.dart';

import '../data/commuter_cash_check_in.dart';
import '../data/commuter_cash_payment.dart';
import '../data/constants.dart';
import '../data/rank_fee_cash_check_in.dart';
import '../data/rank_fee_cash_payment.dart';
import '../utils/functions.dart';
class FirebaseMessagingService {
  final mm = '🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎 FirebaseMessagingService: 🔵🔵 ';


  FirebaseMessagingService() {
    initialize();
  }

  subscribeToTopics(String associationId) async {
    var web = msg.FirebaseMessagingWeb();
    await web.subscribeToTopic('$Constants.dispatchRecord$associationId');
    await web.subscribeToTopic('$Constants.commuterCashPayment$associationId');
    await web.subscribeToTopic('$Constants.trips$associationId');
    await web.subscribeToTopic('$Constants.vehicleArrival$associationId');
    await web.subscribeToTopic('$Constants.telemetry$associationId');
    await web.subscribeToTopic('$Constants.passengerCount$associationId');
    await web.subscribeToTopic('$Constants.commuterRequest$associationId');
    await web.subscribeToTopic('$Constants.commuterCashCheckIn$associationId');
    await web.subscribeToTopic('$Constants.rankFeeCashPayment$associationId');
    await web.subscribeToTopic('$Constants.rankFeeCashCheckIn$associationId');
    pp('$mm ... subscribeToTopics complete! ...');

  }
  initialize() async {
    pp('$mm ... initialize Firebase Messaging Web ...');

    var web = msg.FirebaseMessagingWeb();
    var token = web.getToken();
    pp('$mm ... token: $token');
    var notificationSettings = await web.requestPermission();

    if (await web.isSupported()) {
      pp('$mm ... we are supported, notificationSettings: ${notificationSettings.authorizationStatus.name}');
    }
    web.setAutoInitEnabled(false);
    pp('$mm ... app name: ${web.app.name}');
    web.registerBackgroundMessageHandler(handler);

}
  StreamController<DispatchRecord> dispatchController = StreamController.broadcast();
  Stream<DispatchRecord> get dispatchStream  => dispatchController.stream;

  StreamController<CommuterCashPayment> commuterCashPaymentController = StreamController.broadcast();
  Stream<CommuterCashPayment> get commuterCashStream  => commuterCashPaymentController.stream;

  StreamController<Trip> tripController = StreamController.broadcast();
  Stream<Trip> get tripStream  => tripController.stream;

  StreamController<VehicleArrival> vehicleArrivalController = StreamController.broadcast();
  Stream<VehicleArrival> get vehicleArrivalStream  => vehicleArrivalController.stream;

  StreamController<VehicleTelemetry> telemetryController = StreamController.broadcast();
  Stream<VehicleTelemetry> get telemetryStream  => telemetryController.stream;

  StreamController<AmbassadorPassengerCount> passengerCountController = StreamController.broadcast();
  Stream<AmbassadorPassengerCount> get passengerCountStream  => passengerCountController.stream;

  StreamController<CommuterRequest> commuterRequestController = StreamController.broadcast();
  Stream<CommuterRequest> get commuterRequestStream  => commuterRequestController.stream;

  StreamController<CommuterCashCheckIn> commuterCashCheckInController = StreamController.broadcast();
  Stream<CommuterCashCheckIn> get commuterCashCheckInStream  => commuterCashCheckInController.stream;

  StreamController<RankFeeCashPayment> rankFeeCashPaymentController = StreamController.broadcast();
  Stream<RankFeeCashPayment> get rankFeeCashPaymentStream  => rankFeeCashPaymentController.stream;

  StreamController<RankFeeCashCheckIn> rankFeeCashCheckInController = StreamController.broadcast();
  Stream<RankFeeCashCheckIn> get rankFeeCashCheckInStream  => rankFeeCashCheckInController.stream;

  Future<void> handler(RemoteMessage message) async {
    pp('\n\n$mm registerBackgroundMessageHandler message: $message');
    var type = message.data['type'];
    pp('\n\n$mm registerBackgroundMessageHandler type: $type');

    var data = message.data;

    switch (type) {
      case Constants.dispatchRecord:
        dispatchController.sink.add(DispatchRecord.fromJson(data));
        break;
      case Constants.commuterCashPayment:
        commuterCashPaymentController.sink.add(CommuterCashPayment.fromJson(data));
        break;
      case Constants.vehicleArrival:
        vehicleArrivalController.sink.add(VehicleArrival.fromJson(data));
        break;
      case Constants.telemetry:
        telemetryController.sink.add(VehicleTelemetry.fromJson(data));
        break;
      case Constants.passengerCount:
        passengerCountController.sink.add(AmbassadorPassengerCount.fromJson(data));
        break;
      case Constants.commuterRequest:
        commuterRequestController.sink.add(CommuterRequest.fromJson(data));
        break;
      case Constants.commuterCashCheckIn:
        commuterCashCheckInController.sink.add(CommuterCashCheckIn.fromJson(data));
        break;
      case Constants.rankFeeCashPayment:
        rankFeeCashPaymentController.sink.add(RankFeeCashPayment.fromJson(data));
        break;
      case Constants.rankFeeCashCheckIn:
        rankFeeCashCheckInController.sink.add(RankFeeCashCheckIn.fromJson(data));
        break;
      case Constants.trips:
        tripController.sink.add(Trip.fromJson(data));
        break;

    }
  }
  }
