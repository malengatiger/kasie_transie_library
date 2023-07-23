// import 'dart:async';
//
// import 'package:geolocator/geolocator.dart' as geo;
// import 'package:kasie_transie_library/bloc/list_api_dog.dart';
// import 'package:kasie_transie_library/data/schemas.dart' as lib;
// import 'package:kasie_transie_library/utils/device_location_bloc.dart';
//
// import 'distance.dart';
//
// final SingleRouteEstimator singleRouteEstimator = SingleRouteEstimator();
//
// class SingleRouteEstimator {
//   // var locationOptions =
//   //     geo.LocationOptions(accuracy: geo.LocationAccuracy.high, distanceFilter: 100);
//   final List<RouteDistanceEstimation> _estimations = [];
//   lib.Vehicle? _vehicle;
//   // List<VehicleRouteAssignment> _assignments = [];
//   geo.Position? _currentPosition;
//   lib.Route? route;
//   lib.RoutePoint? nearestRoutePoint;
//
//   final StreamController<List<RouteDistanceEstimation>> _estimationController =
//       StreamController.broadcast();
//   Stream<List<RouteDistanceEstimation>> get routeDistanceStream => _estimationController.stream;
//   final StreamController<List<String>> _errorController = StreamController.broadcast();
//
//   close() {
//     _estimationController.close();
//     _errorController.close();
//   }
//
//   bool isTest = false;
//   Future getTestPoint() async {
//     p('$mm SingleRouteEstimator:getTestPoint ............  getTestPoint ...');
//     var loc = await locationBloc.getLocation();
//     var routes = await LocalDBAPI.findNearestRoutes(
//         latitude: loc!.latitude, longitude: loc.longitude, radiusInKM: 1);
//     routes.sort((a, b) => a.name!.compareTo(b.name!));
//     routes.forEach((element) {
//       p('$mm SingleRouteEstimator:getTestPoint Route found: ${element.name}');
//     });
//     List<lib.RoutePoint> points = [];
//     if (routes.isNotEmpty) {
//       route = routes.elementAt(1);
//       route!.routePoints!.forEach((element) {
//         if (element.landmarkId != null) {
//           points.add(element);
//         }
//       });
//     }
//     p('$mm SingleRouteEstimator:getTestPoint: Route selected: ${route!.name}');
//     var index = 0;
//     points.forEach((element) {
//       p('$mm SingleRouteEstimator:getTestPoint: Landmark point: index: $index ${element.routeId} - ${element.landmarkName}');
//       index++;
//     });
//     if (points.isNotEmpty) {
//       nearestRoutePoint = points.last;
//       p('$mm SingleRouteEstimator:getTestPoint: nearest RoutePoint: ${nearestRoutePoint!.toJson()}');
//       return nearestRoutePoint;
//     } else {
//       nearestRoutePoint = null;
//     }
//
//     return nearestRoutePoint;
//   }
//
//   static const mm = '🍎🍎🍎🍎 SingleRouteEstimator 🍎: ';
//   bool? saveEstimation;
//
//   Future<RouteDistanceEstimation?> createEstimation(
//       {required lib.Route route,
//       thisIsATest = false,
//       required bool saveEstimation,
//       double? latitude,
//       double? longitude,
//       required lib.Vehicle vehicle}) async {
//     this.saveEstimation = saveEstimation;
//     this.route = route;
//     if (latitude == null) {
//       // p('$mm createEstimation: calling getCurrentPosition ...');
//       _currentPosition = await locationBloc.getLocation();
//     } else {
//       // p('$mm createEstimation: creating position: $latitude lng: $longitude ........');
//       _currentPosition = geo.Position(
//           longitude: longitude!,
//           latitude: latitude,
//           timestamp: DateTime.now(),
//           accuracy: 0.0,
//           altitude: 1200.0,
//           heading: 0.0,
//           speed: 0.0,
//           speedAccuracy: 0.0);
//     }
//
//     this.route = route;
//     // p('$mm 🔴 🔴 FIND Nearest route point ...');
//     List<RoutePointDistance> list = [];
//     final routePoints = await listApiDog.getRoutePoints(route.routeId!, false);
//     for (var routePoint in routePoints) {
//       var dist = locationBloc.getDistance(
//           latitude: _currentPosition!.latitude,
//           longitude: _currentPosition!.longitude,
//           toLatitude: routePoint.position!.coordinates[1],
//           toLongitude: routePoint.position!.coordinates[0]);
//       list.add(RoutePointDistance(dist, routePoint));
//     }
//     // p('$mm 🔴 🔴 SORT route points by distance from current position ...');
//     list.sort((a, b) => a.distance.compareTo(b.distance));
//     nearestRoutePoint = list.first.routePoint;
//     // p('$mm 🔴 🔴 Nearest route point found, 🔴 check index: ${nearestRoutePoint!.toJson()}');
//
//     var distanceEstimation = await _calculateDistancesAlongTheRoute();
//     if (distanceEstimation == null) {
//       return null;
//     }
//
//     distanceEstimation.vehicle = vehicle;
//
//     _estimations.add(distanceEstimation);
//     _estimationController.sink.add(_estimations);
//     p('$mm 🍏 🍏 🍏 🍏 🍏 🍏  ESTIMATION COMPLETED and added to stream for route:  😎 ${route.name} '
//         ' with  🧩 ${distanceEstimation.dynamicDistances!.length} dynamicDistances 🍏 🍏 🍏 ');
//     try {
//       if (distanceEstimation.dynamicDistances!.isNotEmpty) {
//         if (saveEstimation) {
//           // await DancerDataAPI.addRouteDistanceEstimation(estimation: distanceEstimation);
//           saveEstimation = false;
//         }
//       }
//     } catch (e) {
//       pp(e);
//       throw Exception('Estimation Error 🔴 $e 🔴');
//     }
//     return distanceEstimation;
//   }
//
//   Future<RouteDistanceEstimation?> _calculateDistancesAlongTheRoute() async {
//     final pointsThatAreLandmarks = await listApiDog.getRouteLandmarks(routeId, refresh);
//     if (nearestRoutePoint == null) {
//       p('$mm _calculateDistancesAlongTheRoute: 👿👿👿 : '
//           ' nearestRoutePoint is null - 👿👿👿 quitting! 👿👿👿');
//       return null;
//     }
//     var map = <String, RoutePoint>{};
//     route!.routePoints!.forEach((p) {
//       if (p.index! >= nearestRoutePoint!.index!) {
//         if (p.landmarkId != null) {
//           map[p.landmarkId!] = p;
//         }
//       }
//     });
//     pointsThatAreLandmarks = map.values.toList();
//     // p('$mm 😎😎 _calculateDistancesAlongTheRoute: 🔴 '
//     //     'pointsThatAreLandmarks: ${pointsThatAreLandmarks.length}');
//     // // pointsThatAreLandmarks.forEach((point) {
//     //   p('$mm Point that is a Landmark, past the nearest point (${nearestRoutePoint!.index}): 😎 index: ${point.index} - ${point.landmarkName} ');
//     // });
//
//     if (pointsThatAreLandmarks.isEmpty) {
//       p('\n\n$mm 😎😎 _calculateDistancesAlongTheRoute : '
//           ' No points found that are marked as Landmarks in route - 🔴 🔴 🔴 quitting!\n');
//       return null;
//     }
//     if (pointsThatAreLandmarks.length == 1) {
//       p('\n\n$mm 😎😎 _calculateDistancesAlongTheRoute : '
//           ' pointsThatAreLandmarks: ${pointsThatAreLandmarks.length} - 🔴 🔴 🔴 only one landmark left; quitting!\n');
//       return null;
//     }
//     // p('$mm 😎😎 _calculateDistancesAlongTheRoute: 🍏🍏 '
//     //     'Calculating distance from vehicle location to nearest landmark: 🍏 ${pointsThatAreLandmarks.first.landmarkName}');
//     // p('$mm _calculateDistancesAlongTheRoute: lat: ${_currentPosition!.latitude} lng: ${_currentPosition!.longitude} 😎😎😎 :');
//
//     double distanceBetweenNearestRoutePointAndNearestLandmarkOnRoute =
//         getDistanceBetweenNearestRoutePointAndNearestLandmarkOnRoute(
//             route: route!,
//             routePoint: nearestRoutePoint!,
//             landmarkRoutePoint: pointsThatAreLandmarks.first);
//
//     var distanceToRoute = 0.0;
//
//     distanceToRoute =  locationBloc.getDistance(
//         latitude: _currentPosition!.latitude,
//         longitude: _currentPosition!.longitude,
//         toLatitude: nearestRoutePoint!.position!.coordinates[1],
//         toLongitude: nearestRoutePoint!.position!.coordinates[0]);
//
//     var totalDistanceToNearestLandmark =
//         distanceBetweenNearestRoutePointAndNearestLandmarkOnRoute + distanceToRoute;
//
//     // p('$mm  🥦 🥦 🥦 totalDistanceToNearestLandmark: $totalDistanceToNearestLandmark metres');
//
//     RouteDistanceEstimation? estimation = await _getEstimation(
//         route: route!,
//         landmarkRoutePoint: pointsThatAreLandmarks.first,
//         distanceToNearestLandmark: totalDistanceToNearestLandmark);
//
//     return estimation;
//   }
//
//   static const nn = '🌼 🌼 🌼 SingleRouteEstimator: ';
//   List<CalculatedDistance> calcDistances = [];
//
//   Future<RouteDistanceEstimation?> _getEstimation({
//     required lib.Route route,
//     required RoutePoint? landmarkRoutePoint,
//     required double distanceToNearestLandmark,
//   }) async {
//     calcDistances = await RouteDistanceCalculator.calculate(route: route, save: false);
//
//     int indexToStartFrom = 0, index = 0;
//     bool found = false;
//     for (var cd in calcDistances) {
//       if (cd.fromLandmarkId == landmarkRoutePoint!.landmarkId) {
//         indexToStartFrom = index;
//         found = true;
//         break;
//       }
//       index++;
//     }
//     // p('$nn 🍎 _getEstimation: ${calcDistances.length} calculated distances; 🔶 indexToStartFrom: $indexToStartFrom ');
//     // p('$mm In calculated distances, 🔶 starting from ${calcDistances.elementAt(indexToStartFrom).toJson()}');
//     var filteredDistances = <CalculatedDistance>[];
//     List<DynamicDistance> dynamicDistances = [];
//     try {
//       for (var i = indexToStartFrom; i < calcDistances.length; i++) {
//         filteredDistances.add(calcDistances.elementAt(i));
//       }
//       if (filteredDistances.isEmpty) {
//         p('$nn 🍎 : route: ${route.name} 🌼 🌼 🌼'
//             'LOOKS like we are at the ass end of incoming route 🔶 🔶 🔶  use whole route ???? 🔶 ');
//         // dynamicDistances = await _buildDynamicDistancesBackward(
//         //     calcDistances, distanceToNearestLandmark, route);
//         return null;
//       } else {
//         dynamicDistances = await _buildDynamicDistancesForward(
//             filteredDistances, distanceToNearestLandmark, route);
//         // p('$nn 🍎 : after calling _buildDynamicDistancesForward, 🔶 dynamic distances: ${dynamicDistances.length} 🌼 🌼 🌼');
//       }
//     } catch (e) {
//       print(e);
//     }
//
//     if (dynamicDistances.isEmpty) {
//       p('$mm NO DYNAMIC DISTANCES calculated. Quitting ....');
//       return null;
//     }
//
//     // p('$mm ${dynamicDistances.length} DYNAMIC DISTANCES calculated.... still climbing the hill ...');
//     var dist = await locationBloc.getDistanceBetweenPositions(
//         latitudeFrom: _currentPosition!.latitude,
//         longitudeFrom: _currentPosition!.longitude,
//         latitudeTo: landmarkRoutePoint!.latitude!,
//         longitudeTo: landmarkRoutePoint.longitude!);
//
//     var estimation = RouteDistanceEstimation(
//         routeId: route.routeId,
//         routeName: route.name,
//         dynamicDistances: dynamicDistances,
//         vehicle: _vehicle,
//         nearestLandmarkId: landmarkRoutePoint.landmarkId,
//         nearestLandmarkName: landmarkRoutePoint.landmarkName,
//         created: DateTime.now().toUtc().toIso8601String(),
//         distanceToNearestLandmark: dist);
//
//     // p('\n\n$mm VEHICLE ROUTE DISTANCE ESTIMATION completed! '
//     //     '🌸 🌸 🌸 RouteDistanceEstimation for: ${estimation.routeName} - 🍏🍏 dynamic distances: ${dynamicDistances.length}\n');
//     // dynamicDistances.forEach((element) {
//     //   p('$mm Dynamic Distance: ${element.distanceInKM} km to ${element.landmarkName} ');
//     // });
//     // p('$mm VEHICLE ROUTE DISTANCE ESTIMATION completed! check dynamic distances ..\n\n ');
//     return estimation;
//   }
//
//   Future<List<DynamicDistance>> _buildDynamicDistancesForward(
//       List<CalculatedDistance> calculatedDistances,
//       double distanceToNearestLandmark,
//       lib.Route route) async {
//     var mIndex = 0;
//     double prevDist = 0.0;
//     List<DynamicDistance> dynamics = [];
//     for (var cd in calculatedDistances) {
//       if (mIndex == 0) {
//         var dist =
//             distanceToNearestLandmark + calculatedDistances.elementAt(mIndex).distanceInMetres!;
//         dynamics.add(DynamicDistance(
//             date: DateTime.now().toIso8601String(),
//             distanceInMetres: dist,
//             routeName: route.name,
//             distanceInKM: dist / 1000,
//             landmarkId: cd.toLandmarkId,
//             landmarkName: cd.toLandmark));
//         prevDist = dist;
//       } else {
//         var dist = prevDist + calculatedDistances.elementAt(mIndex).distanceInMetres!;
//         // p('_getEstimation: Calculated : 🍎 🍎 $dist metres to 🔆 ${cd.toLandmark}');
//         prevDist = dist;
//         dynamics.add(DynamicDistance(
//             date: DateTime.now().toIso8601String(),
//             distanceInMetres: dist,
//             distanceInKM: dist / 1000,
//             routeName: route.name,
//             landmarkId: cd.toLandmarkId,
//             landmarkName: cd.toLandmark));
//       }
//       mIndex++;
//     }
//     return dynamics;
//   }
//
//   Future<RoutePoint?> _findRoutePointNearestLocation() async {
//     assert(route != null);
//     assert(route!.routePoints!.isNotEmpty);
//
//     var routePoints = await LocalDBAPI.findNearestRoutePointsByLocation(
//         latitude: _currentPosition!.latitude,
//         longitude: _currentPosition!.longitude,
//         radiusInKM: 0.2);
//     p('Estimator : findRoutePointNearestLocation: 🔵 🔵 🔵 🔵 Route points ${routePoints.length} : 🔵 🔵 ${route!.name} 🔵 🔵 ');
//     if (routePoints.isNotEmpty) {
//       p('😎 😎 routePoint found, check index: ${routePoints.first.toJson()}');
//       return routePoints.first;
//     } else {
//       return null;
//     }
//   }
// }
//
// abstract class EstimatorListener {
//   onMultipleRoutesFound(List<lib.Route> routes);
// }
//
// double getDistanceBetweenNearestRoutePointAndNearestLandmarkOnRoute(
//     {required lib.Route route,
//     required RoutePoint routePoint,
//     required RoutePoint landmarkRoutePoint}) {
//   double distanceToNearestLandmark = 0.0;
//   ;
//   var pointsBetween = route.routePoints!.getRange(routePoint.index!, landmarkRoutePoint.index! + 1);
//   // p('😎 😎 Number of routePoints from nearest routePoint to landmark; for calculating distanceToNearestLandmark : ${pointsBetween.length}');
//
//   var locationBloc = LocationBloc();
//   RoutePoint? prevPoint;
//   pointsBetween.forEach((mRoutePoint) async {
//     if (prevPoint == null) {
//       //ignore
//     } else {
//       var distance = await locationBloc.getDistanceBetweenPositions(
//           latitudeFrom: prevPoint!.position!.coordinates![1]!,
//           longitudeFrom: prevPoint!.position!.coordinates![0]!,
//           latitudeTo: mRoutePoint.position!.coordinates![1]!,
//           longitudeTo: mRoutePoint.position!.coordinates![0]!);
//       distanceToNearestLandmark += distance;
//     }
//     prevPoint = mRoutePoint;
//   });
//
//   // p('🐥 🐥 Calculate distances from : 🍎 '
//   //     ' ${landmarkRoutePoint.landmarkName} to the rest of the route landmarks ....');
//   return distanceToNearestLandmark;
// }
//
// class RoutePointDistance {
//   final double distance;
//   final RoutePoint routePoint;
//
//   RoutePointDistance(this.distance, this.routePoint);
// }
