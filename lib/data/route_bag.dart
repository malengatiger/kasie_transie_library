

import 'package:kasie_transie_library/data/schemas.dart';

class RouteBag {
  RoutePoint? routePoint;
  String? routeName, landmarkId;

  RouteBag({this.routePoint, this.routeName, this.landmarkId});

  RouteBag.fromJson(Map data) {
    routeName = data['routeName'];
    landmarkId = data['landmarkId'];
    if (data['routePoint'] != null) {
      routePoint = RoutePoint(
        latitude: data['routePoint']['latitude'],
        longitude: data['routePoint']['longitude'],
        created: data['routePoint']['created'],
        heading: data['routePoint']['heading'],
        index: data['routePoint']['index'],
        landmarkId: data['routePoint']['landmarkId'],
        landmarkName: data['routePoint']['landmarkName'],
        routeId: data['routePoint']['routeId'],
        position: Position(
          type: 'Point',
          latitude: data['routePoint']['position']['latitude'],
          longitude: data['routePoint']['position']['longitude'],
          coordinates: [
            data['routePoint']['position']['longitude'],
            data['routePoint']['position']['latitude'],
          ]
        )
      );
    }
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'routeName': routeName,
        'landmarkId': landmarkId,
        'routePoint': routePoint == null ? null : routePoint!.toJson(),
      };
}
