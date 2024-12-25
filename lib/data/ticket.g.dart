// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket(
      associationId: json['associationId'] as String?,
      userId: json['userId'] as String?,
      associationName: json['associationName'] as String?,
      ticketId: json['ticketId'] as String?,
      value: (json['value'] as num?)?.toDouble(),
      ticketRoutes: (json['ticketRoutes'] as List<dynamic>?)
          ?.map((e) => TicketRoute.fromJson(e as Map<String, dynamic>))
          .toList(),
      numberOfTrips: (json['numberOfTrips'] as num?)?.toInt(),
      created: json['created'] as String?,
      qrCodeUrl: json['qrCodeUrl'] as String?,
      validOnAllRoutes: json['validOnAllRoutes'] as bool?,
      ticketType: $enumDecodeNullable(_$TicketTypeEnumMap, json['ticketType']),
    );

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'userId': instance.userId,
      'ticketId': instance.ticketId,
      'value': instance.value,
      'numberOfTrips': instance.numberOfTrips,
      'ticketType': _$TicketTypeEnumMap[instance.ticketType],
      'ticketRoutes': instance.ticketRoutes?.map((e) => e.toJson()).toList(),
      'created': instance.created,
      'qrCodeUrl': instance.qrCodeUrl,
      'validOnAllRoutes': instance.validOnAllRoutes,
    };

const _$TicketTypeEnumMap = {
  TicketType.oneTrip: 'oneTrip',
  TicketType.daily: 'daily',
  TicketType.weekly: 'weekly',
  TicketType.monthly: 'monthly',
  TicketType.annual: 'annual',
};

CommuterTicket _$CommuterTicketFromJson(Map<String, dynamic> json) =>
    CommuterTicket(
      associationId: json['associationId'] as String?,
      userId: json['userId'] as String?,
      associationName: json['associationName'] as String?,
      ticketId: json['ticketId'] as String?,
      commuterId: json['commuterId'] as String?,
      commuterEmail: json['commuterEmail'] as String?,
      commuterCellphone: json['commuterCellphone'] as String?,
      commuterTicketId: json['commuterTicketId'] as String?,
      value: (json['value'] as num?)?.toDouble(),
      qrCodeUrl: json['qrCodeUrl'] as String?,
      validFromDate: json['validFromDate'] as String?,
      numberOfTrips: (json['numberOfTrips'] as num?)?.toInt(),
      validToDate: json['validToDate'] as String?,
      ticketRoutes: (json['ticketRoutes'] as List<dynamic>)
          .map((e) => TicketRoute.fromJson(e as Map<String, dynamic>))
          .toList(),
      ticketType: $enumDecodeNullable(_$TicketTypeEnumMap, json['ticketType']),
    );

Map<String, dynamic> _$CommuterTicketToJson(CommuterTicket instance) =>
    <String, dynamic>{
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'userId': instance.userId,
      'commuterTicketId': instance.commuterTicketId,
      'ticketId': instance.ticketId,
      'commuterId': instance.commuterId,
      'commuterEmail': instance.commuterEmail,
      'qrCodeUrl': instance.qrCodeUrl,
      'commuterCellphone': instance.commuterCellphone,
      'value': instance.value,
      'numberOfTrips': instance.numberOfTrips,
      'validFromDate': instance.validFromDate,
      'validToDate': instance.validToDate,
      'ticketType': _$TicketTypeEnumMap[instance.ticketType],
      'ticketRoutes': instance.ticketRoutes.map((e) => e.toJson()).toList(),
    };

CommuterTicketPunched _$CommuterTicketPunchedFromJson(
        Map<String, dynamic> json) =>
    CommuterTicketPunched(
      json['ticketId'] as String?,
      json['commuterId'] as String?,
      json['date'] as String?,
      json['userId'] as String?,
      json['associationId'] as String?,
    );

Map<String, dynamic> _$CommuterTicketPunchedToJson(
        CommuterTicketPunched instance) =>
    <String, dynamic>{
      'ticketId': instance.ticketId,
      'commuterId': instance.commuterId,
      'date': instance.date,
      'userId': instance.userId,
      'associationId': instance.associationId,
    };

TicketRoute _$TicketRouteFromJson(Map<String, dynamic> json) => TicketRoute(
      routeName: json['routeName'] as String?,
      routeId: json['routeId'] as String?,
      startCityName: json['startCityName'] as String?,
      endCityName: json['endCityName'] as String?,
    );

Map<String, dynamic> _$TicketRouteToJson(TicketRoute instance) =>
    <String, dynamic>{
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'startCityName': instance.startCityName,
      'endCityName': instance.endCityName,
    };
