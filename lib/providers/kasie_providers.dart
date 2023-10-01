import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riv;
import 'package:kasie_transie_library/bloc/list_api_dog.dart';

import '../data/schemas.dart';
import '../utils/functions.dart';

const bb = '🌀🌀🌀🌀🌀🌀RiverPod Provider 🌀🌀🌀';
//
final countryProvider = riv.FutureProvider<List<Country>>((ref) async {
  final res = await listApiDog.getCountries();
  pp('$bb countryProvider did the job: ${res.length} countries found.');
  return res;
});
//
// final countryCitiesProvider = riv.FutureProvider.family<List<City>, String>((ref,
//     countryId) async {
//   // final res = await listApiDog.getCountryCities(countryId);
//   // pp('$bb countryCitiesProvider did the job: ${res
//   //     .length} country cities found.');
//   // return res;
// });
//
final nearbyCitiesProvider = riv.FutureProvider.family<
    List<City>,
    LocationFinderParameter>((ref, cityFinderParam) async {
  final res = await listApiDog.findCitiesByLocation(cityFinderParam);
  pp('$bb nearbyCitiesProvider did the job: ${res
      .length} country cities found.');
  return res;
});
//
// final routesProvider = riv.FutureProvider.family<List<Route>,
//     AssociationParameter>((ref, associationParameter) async {
//   final res = await listApiDog.getRoutes(associationParameter);
//   pp('$bb routesProvider did the job: ${res.length} routes found.');
//   for (var r in res) {
//     pp('$bb routesProvider route: ❤️❤️ ${r.name}');
//   }
//   return res;
// });
//
// final routePointProvider = riv.FutureProvider.family<List<RoutePoint>, String>((ref,
//     routeId) async {
//   final res = await listApiDog.getRoutePoints(routeId, false);
//   pp('$bb routePointProvider did the job: ${res.length} routePoints found.');
//   return res;
// });
//
final routeLandmarkProvider = riv.FutureProvider.family<List<RouteLandmark>, String>((ref,
    routeId) async {
  final res = await listApiDog.getRouteLandmarks(routeId, false);
  pp('$bb landmarkProvider did the job: ${res.length} routeLandmarks found.');
  return res;
});

//
final usersProvider = riv.FutureProvider.family<List<User>, String>((ref,
    associationId) async {
  final res = await listApiDog.getAssociationUsers(associationId, false);
  pp('$bb usersProvider did the job: ${res.length} users found.');
  return res;
});

final statesProvider = riv.FutureProvider.family<List<StateProvince>, String>((ref,
    countryId) async {
  final res = await listApiDog.getCountryStates(countryId);
  pp('$bb statesProvider did the job: ${res.length} states/provinces found.');
  return res;
});

final vehicleProvider = riv.FutureProvider.family<List<Vehicle>, String>((ref,
    associationId) async {
  final res = await listApiDog.getAssociationVehicles(associationId,false);
  pp('$bb vehicleProvider did the job: ${res.length} cars found.');
  return res;
});

///Helper class for Providers
class AssociationParameter extends Equatable {
  final String associationId;
  final bool refresh;

  const AssociationParameter(this.associationId, this.refresh);

  @override
  List<Object?> get props => [associationId, refresh];
}

///Helper class for location based queries
class LocationFinderParameter {
  String? associationId;
  late int limit;
  late double latitude, longitude, radiusInKM;


  LocationFinderParameter({
    this.associationId, required this.latitude,
    required this.limit,
    required this.longitude, required this.radiusInKM});
}
