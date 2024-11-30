// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExampleFile _$ExampleFileFromJson(Map<String, dynamic> json) => ExampleFile(
      json['type'] as String?,
      json['fileName'] as String?,
      json['downloadUrl'] as String?,
    );

Map<String, dynamic> _$ExampleFileToJson(ExampleFile instance) =>
    <String, dynamic>{
      'type': instance.type,
      'fileName': instance.fileName,
      'downloadUrl': instance.downloadUrl,
    };
