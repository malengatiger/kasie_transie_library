import 'package:json_annotation/json_annotation.dart';

part 'kasie_error.g.dart';

@JsonSerializable(explicitToJson: true)
class KasieError {
  String? _partitionKey;
  String? _id;
 
  int? statusCode;
  String? message;
  String? date;
  String? request;

  KasieError(this.statusCode, this.message, this.date, this.request);
  factory KasieError.fromJson(Map<String, dynamic> json) => _$KasieErrorFromJson(json);
  Map<String, dynamic> toJson() => _$KasieErrorToJson(this);
}
