import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

part 'ticket.g.dart';

@JsonSerializable(explicitToJson: true)
class Ticket {
  String? associationId, associationName, userId;
  String? ticketId;
  double? value;
  int? numberOfTrips;
  TicketType? ticketType;
  List<TicketRoute>? ticketRoutes = [];
  String? created, qrCodeUrl, bucketFileName;
  String? qrCodeBytes;
  bool? validOnAllRoutes = false;

  Ticket(
      {required this.associationId,
      required this.userId,
      required this.associationName,
      this.ticketId,
      required this.value,
      required this.ticketRoutes,
      this.numberOfTrips,
      this.created,
      this.bucketFileName,
      this.qrCodeUrl,
      this.qrCodeBytes,
      this.validOnAllRoutes,
      required this.ticketType});

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);

  Map<String, dynamic> toJson() => _$TicketToJson(this);
}

//
@JsonSerializable(explicitToJson: true)
class CommuterTicket {
  String? associationId, associationName, userId;
  String? commuterTicketId,
      ticketId,
      commuterId,
      commuterEmail,
      commuterCellphone;
  double? value;
  int? numberOfTrips;
  String? validFromDate, validToDate, bucketFileName;
  String? qrCodeBytes;

  TicketType? ticketType;
  List<TicketRoute> ticketRoutes = [];

  CommuterTicket(
      this.associationId,
      this.userId,
      this.associationName,
      this.ticketId,
      this.commuterId,
      this.commuterEmail,
      this.commuterCellphone,
      this.commuterTicketId,
      this.value,
      this.qrCodeBytes,
      this.bucketFileName,
      this.validFromDate,
      this.numberOfTrips,
      this.validToDate,
      this.ticketRoutes,
      this.ticketType);

  factory CommuterTicket.fromJson(Map<String, dynamic> json) =>
      _$CommuterTicketFromJson(json);

  Map<String, dynamic> toJson() => _$CommuterTicketToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CommuterTicketPunched {
  String? ticketId, commuterId, date, userId, associationId;

  CommuterTicketPunched(this.ticketId, this.commuterId, this.date, this.userId,
      this.associationId);

  factory CommuterTicketPunched.fromJson(Map<String, dynamic> json) =>
      _$CommuterTicketPunchedFromJson(json);

  Map<String, dynamic> toJson() => _$CommuterTicketPunchedToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TicketRoute {
  String? routeId, routeName, startCityName, endCityName;

  TicketRoute(
      {required this.routeName,
      required this.routeId,
      required this.startCityName,
      required this.endCityName});

  factory TicketRoute.fromJson(Map<String, dynamic> json) =>
      _$TicketRouteFromJson(json);

  Map<String, dynamic> toJson() => _$TicketRouteToJson(this);
}

enum TicketType {
  oneTrip,
  daily,
  weekly,
  monthly,
  annual;
}
