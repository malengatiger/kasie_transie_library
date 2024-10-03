// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_pair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutePair _$RoutePairFromJson(Map<String, dynamic> json) => RoutePair(
      routeId1: json['routeId1'] as String?,
      routeId2: json['routeId2'] as String?,
      routeName1: json['routeName1'] as String?,
      routeName2: json['routeName2'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
      updated: json['updated'] as String?,
      routePairId: json['routePairId'] as String?,
      associationName: json['associationName'] as String?,
    );

Map<String, dynamic> _$RoutePairToJson(RoutePair instance) => <String, dynamic>{
      'routeId1': instance.routeId1,
      'routeId2': instance.routeId2,
      'routeName1': instance.routeName1,
      'routePairId': instance.routePairId,
      'routeName2': instance.routeName2,
      'created': instance.created,
      'updated': instance.updated,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
    };
