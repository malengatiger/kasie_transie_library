import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

class RouteAssignmentList {
  List<RouteAssignment> assignments = [];

  RouteAssignmentList(
      {
      required this.assignments});

  RouteAssignmentList.fromJson(Map data) {

    List va = data['assignments'];
    for (var value in va) {
      assignments.add(buildRouteAssignment(value));
    }
  }
  Map<String, dynamic> toJson() {
    List asses = [];
    for (var value in assignments) {
      asses.add(value.toJson());
    }
    final map = {
      'assignments': asses,
    };
    return map;
  }
}
