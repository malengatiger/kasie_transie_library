import 'package:json_annotation/json_annotation.dart';

part 'example_file.g.dart';

@JsonSerializable(explicitToJson: true)
class ExampleFile {

  String? type, fileName, downloadUrl;


  ExampleFile(this.type, this.fileName, this.downloadUrl);

  factory ExampleFile.fromJson(Map<String, dynamic> json) => _$ExampleFileFromJson(json);

  Map<String, dynamic> toJson() => _$ExampleFileToJson(this);
}
