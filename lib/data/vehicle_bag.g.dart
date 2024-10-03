// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_bag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleBag _$VehicleBagFromJson(Map<String, dynamic> json) => VehicleBag(
      vehicleId: json['vehicleId'] as String,
      created: json['created'] as String,
      arrivals: (json['arrivals'] as List<dynamic>)
          .map((e) => VehicleArrival.fromJson(e as Map<String, dynamic>))
          .toList(),
      departures: (json['departures'] as List<dynamic>)
          .map((e) => VehicleDeparture.fromJson(e as Map<String, dynamic>))
          .toList(),
      dispatchRecords: (json['dispatchRecords'] as List<dynamic>)
          .map((e) => DispatchRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      passengerCounts: (json['passengerCounts'] as List<dynamic>)
          .map((e) =>
              AmbassadorPassengerCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      heartbeats: (json['heartbeats'] as List<dynamic>)
          .map((e) => VehicleHeartbeat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VehicleBagToJson(VehicleBag instance) =>
    <String, dynamic>{
      'vehicleId': instance.vehicleId,
      'created': instance.created,
      'arrivals': instance.arrivals,
      'dispatchRecords': instance.dispatchRecords,
      'heartbeats': instance.heartbeats,
      'departures': instance.departures,
      'passengerCounts': instance.passengerCounts,
    };
