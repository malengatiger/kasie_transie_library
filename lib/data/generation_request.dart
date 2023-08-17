import 'dart:convert';

import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

class GenerationRequest {
  String? routeId;
  String? startDate;
  List<String> vehicleIds = [];
  int? intervalInSeconds;


  GenerationRequest(
      this.routeId, this.startDate, this.vehicleIds, this.intervalInSeconds);

  GenerationRequest.fromJson(Map data) {
    routeId = data['routeId'];
    startDate = data['startDate'];
    intervalInSeconds = data['intervalInSeconds'];

    List rlList = data['vehicleIds'];
    for (var value in rlList) {
      vehicleIds.add(value);
    }
  }
  Map<String, dynamic> toJson() {
    final map =  <String, dynamic>{};
    map['routeId'] = routeId;
    map['startDate'] = startDate;
    map['intervalInSeconds'] = intervalInSeconds;
    map['vehicleIds'] = vehicleIds;

    return map;
  }
}

