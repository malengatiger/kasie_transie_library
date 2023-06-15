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

  RoutePair.fromJson(Map data) {
    routeId1 = data['routeId1'];
    routeId2 = data['routeId2'];
    routeName1 = data['routeName1'];
    routeName2 = data['routeName2'];
    routePairId = data['routePairId'];

    associationId = data['associationId'];
    associationName = data['associationName'];
    created = data['created'];
    updated = data['updated'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'routeId1': routeId1,
        'routeId2': routeId2,
    'routePairId': routePairId,
        'routeName1': routeName1,
        'routeName2': routeName2,
        'created': created,
        'updated': updated,
        'associationId': associationId,
        'associationName': associationName,
      };
}
