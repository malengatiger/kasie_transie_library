
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

class RouteDistanceEstimation {
  String? _id, routeId, routeName, nearestLandmarkName, nearestLandmarkId;
  List<DynamicDistance>? dynamicDistances;
  double? distanceToNearestLandmark;
  String? created;
  Vehicle? vehicle;

  RouteDistanceEstimation(
      {this.routeId,
      this.routeName,
      this.dynamicDistances,
      this.nearestLandmarkId,
      this.nearestLandmarkName,
      this.created,
      this.vehicle,
      this.distanceToNearestLandmark}) {}

  RouteDistanceEstimation.fromJson(Map data) {
    _id = data['_id'];
    routeId = data['routeId'];
    routeName = data['routeName'];
    created = data['created'];
    nearestLandmarkName = data['nearestLandmarkName'];
    nearestLandmarkId = data['nearestLandmarkId'];
    distanceToNearestLandmark = data['distanceToNearestLandmark'];
    if (data['vehicle'] != null) {
      vehicle = buildVehicle(data['vehicle']);
    }
    dynamicDistances = [];
    if (data['dynamicDistances'] != null) {
      List mx = data['dynamicDistances'];
      for (var dd in mx) {
        dynamicDistances!.add(DynamicDistance.fromJson(dd));
      }
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['_id'] = _id;
    map['routeId'] = routeId;
    map['routeName'] = routeName;
    map['nearestLandmarkName'] = nearestLandmarkName;
    map['nearestLandmarkId'] = nearestLandmarkId;
    map['distanceToNearestLandmark'] = distanceToNearestLandmark;
    List mList = [];
    if (dynamicDistances != null) {
      for (var dd in dynamicDistances!) {
        mList.add(dd.toJson());
      }
    }
    if (vehicle != null) {
      map['vehicle'] = vehicle!.toJson();
    }
    map['dynamicDistances'] = mList;
    map['created'] = created;

    return map;
  }

  printString() {
    var sb = StringBuffer();
    sb.write(
        '🍎🍎  distanceToNearestLandmark : $distanceToNearestLandmark'
            ' metres : 🍏 $nearestLandmarkName  🍀🍀 ROUTE: $routeName 🍀🍀');
    if (dynamicDistances!.isEmpty) {
      sb.write(
          '\n🌼🌼 The vehicle or user is at the end of the route: 🌼 $nearestLandmarkName');
    }
    pp(sb.toString());
    dynamicDistances!.forEach((dd) {
      dd.printString();
    });
//    print('🌼 🌼 🌼 🌼 🌼 🌼  End of Estimation\n');
  }
}

class DynamicDistance {
  double? distanceInMetres, distanceInKM;
  String? landmarkName, landmarkId, date, routeName;

  DynamicDistance(
      {this.distanceInMetres,
      this.distanceInKM,
      this.landmarkName,
      this.landmarkId,
      this.routeName,
      this.date});

  printString() {
    var sb = StringBuffer();
    sb.write('🍎 🍎 DynamicDistance: 🐸 $distanceInKM km to  🍏 $landmarkName \t on route: $routeName');
    pp(sb.toString());
  }

  DynamicDistance.fromJson(Map data) {
    distanceInMetres = data['distanceInMetres'];
    distanceInKM = data['distanceInKM'];
    date = data['date'];
    landmarkName = data['landmarkName'];
    landmarkId = data['landmarkId'];
    routeName = data['routeName'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['distanceInMetres'] = distanceInMetres;
    map['distanceInKM'] = distanceInKM;
    map['landmarkName'] = landmarkName;
    map['landmarkId'] = landmarkId;
    map['date'] = date;
    map['routeName'] = routeName;

    return map;
  }
}
