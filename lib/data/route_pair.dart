import 'package:json_annotation/json_annotation.dart';
part 'route_pair.g.dart';

@JsonSerializable()

class RoutePair {
  String? routeId1, routeId2, routeName1, routePairId;
  String? routeName2, created, updated;
  String? associationId, associationName;

  RoutePair(
      {required this.routeId1,
      required this.routeId2,
      required this.routeName1,
      required this.routeName2,
      required this.created,
      required this.associationId,
      this.updated,
        required this.routePairId,
      required this.associationName});

  factory RoutePair.fromJson(Map<String, dynamic> json) =>
      _$RoutePairFromJson(json);

  Map<String, dynamic> toJson() => _$RoutePairToJson(this);
}
