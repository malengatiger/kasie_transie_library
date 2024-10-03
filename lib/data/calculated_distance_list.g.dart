// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculated_distance_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculatedDistanceList _$CalculatedDistanceListFromJson(
        Map<String, dynamic> json) =>
    CalculatedDistanceList(
      (json['calculatedDistances'] as List<dynamic>)
          .map((e) => CalculatedDistance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CalculatedDistanceListToJson(
        CalculatedDistanceList instance) =>
    <String, dynamic>{
      'calculatedDistances': instance.calculatedDistances,
    };
