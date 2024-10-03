
import 'package:json_annotation/json_annotation.dart';

import 'data_schemas.dart';
part 'calculated_distance_list.g.dart';

@JsonSerializable()
class CalculatedDistanceList {
  List<CalculatedDistance> calculatedDistances = [];

  CalculatedDistanceList(this.calculatedDistances);

  factory CalculatedDistanceList.fromJson(Map<String, dynamic> json) =>
      _$CalculatedDistanceListFromJson(json);

  Map<String, dynamic> toJson() => _$CalculatedDistanceListToJson(this);
}
