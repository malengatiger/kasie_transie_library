// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'big_bag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BigBag _$BigBagFromJson(Map<String, dynamic> json) => BigBag(
      vehicleArrivals: (json['vehicleArrivals'] as List<dynamic>)
          .map((e) => VehicleArrival.fromJson(e as Map<String, dynamic>))
          .toList(),
      vehicleDepartures: (json['vehicleDepartures'] as List<dynamic>)
          .map((e) => VehicleDeparture.fromJson(e as Map<String, dynamic>))
          .toList(),
      dispatchRecords: (json['dispatchRecords'] as List<dynamic>)
          .map((e) => DispatchRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      passengerCounts: (json['passengerCounts'] as List<dynamic>)
          .map((e) =>
              AmbassadorPassengerCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      vehicleHeartbeats: (json['vehicleHeartbeats'] as List<dynamic>)
          .map((e) => VehicleHeartbeat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BigBagToJson(BigBag instance) => <String, dynamic>{
      'vehicleArrivals': instance.vehicleArrivals,
      'dispatchRecords': instance.dispatchRecords,
      'vehicleHeartbeats': instance.vehicleHeartbeats,
      'vehicleDepartures': instance.vehicleDepartures,
      'passengerCounts': instance.passengerCounts,
    };
