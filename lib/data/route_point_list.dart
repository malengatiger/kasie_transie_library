import 'package:kasie_transie_library/data/schemas.dart';

class RoutePointList {
  List<RoutePoint> routePoints = [];

  RoutePointList(this.routePoints);
  Map<String,dynamic> toJson() {
    List mList = [];
    for (var rp in routePoints) {
      mList.add(rp.toJson());
    }
    Map<String, dynamic> map = {
      'routePoints': mList,
    };
    return map;
  }
}
