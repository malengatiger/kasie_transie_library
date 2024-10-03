// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kasie_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KasieError _$KasieErrorFromJson(Map<String, dynamic> json) => KasieError(
      (json['statusCode'] as num?)?.toInt(),
      json['message'] as String?,
      json['date'] as String?,
      json['request'] as String?,
    );

Map<String, dynamic> _$KasieErrorToJson(KasieError instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'message': instance.message,
      'date': instance.date,
      'request': instance.request,
    };
