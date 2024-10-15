// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket(
      json['associationId'] as String?,
      json['userId'] as String?,
      json['associationName'] as String?,
      json['ticketId'] as String?,
      (json['value'] as num?)?.toDouble(),
      json['validFromDate'] as String?,
      json['validToDate'] as String?,
      (json['ticketRoutes'] as List<dynamic>)
          .map((e) => TicketRoute.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['numberOfTrips'] as num?)?.toInt(),
      $enumDecodeNullable(_$TicketTypeEnumMap, json['ticketType']),
    );

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'userId': instance.userId,
      'ticketId': instance.ticketId,
      'value': instance.value,
      'validFromDate': instance.validFromDate,
      'validToDate': instance.validToDate,
      'numberOfTrips': instance.numberOfTrips,
      'ticketType': _$TicketTypeEnumMap[instance.ticketType],
      'ticketRoutes': instance.ticketRoutes.map((e) => e.toJson()).toList(),
    };

const _$TicketTypeEnumMap = {
  TicketType.daily: 'daily',
  TicketType.weekly: 'weekly',
  TicketType.monthly: 'monthly',
  TicketType.annual: 'annual',
};

CommuterTicket _$CommuterTicketFromJson(Map<String, dynamic> json) =>
    CommuterTicket(
      json['associationId'] as String?,
      json['userId'] as String?,
      json['associationName'] as String?,
      json['ticketId'] as String?,
      json['commuterId'] as String?,
      json['commuterEmail'] as String?,
      json['commuterCellphone'] as String?,
      json['commuterTicketId'] as String?,
      (json['value'] as num?)?.toDouble(),
      json['validFrom'] as String?,
      (json['numberOfTrips'] as num?)?.toInt(),
      json['validTo'] as String?,
      (json['ticketRoutes'] as List<dynamic>)
          .map((e) => TicketRoute.fromJson(e as Map<String, dynamic>))
          .toList(),
      $enumDecodeNullable(_$TicketTypeEnumMap, json['ticketType']),
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
      'commuterCellphone': instance.commuterCellphone,
      'value': instance.value,
      'validFrom': instance.validFrom,
      'validTo': instance.validTo,
      'numberOfTrips': instance.numberOfTrips,
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
      json['routeId'] as String?,
      json['routeName'] as String?,
      json['startCityName'] as String?,
      json['endCityName'] as String?,
    );

Map<String, dynamic> _$TicketRouteToJson(TicketRoute instance) =>
    <String, dynamic>{
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'startCityName': instance.startCityName,
      'endCityName': instance.endCityName,
    };
