import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';

import '../data/schemas.dart';
import '../utils/functions.dart';

const bb = '🌀🌀🌀🌀🌀🌀RiverPod Provider Country 🌀🌀🌀';
//
final countryProvider = FutureProvider<List<Country>>((ref) async {
  final res = await listApiDog.getCountries();
  pp('$bb countryProvider did the job: ${res.length} countries found.');
  return res;
});
//
final countryCitiesProvider = FutureProvider.family<List<City>, String >((ref, countryId) async {
  final res = await listApiDog.getCountryCities(countryId);
  pp('$bb countryCitiesProvider did the job: ${res.length} country cities found.');
  return res;
});
//
final routesProvider = FutureProvider.family<List<Route>, String >((ref, associationId) async {
  final res = await listApiDog.getRoutes(associationId);
  pp('$bb routesProvider did the job: ${res.length} routes found.');
  return res;
});
//
final routePointProvider = FutureProvider.family<List<RoutePoint>, String >((ref, routeId) async {
  final res = await listApiDog.getRoutePoints(routeId);
  pp('$bb routePointProvider did the job: ${res.length} routePoints found.');
  return res;
});
//
final usersProvider = FutureProvider.family<List<User>, String >((ref, associationId) async {
  final res = await listApiDog.getAssociationUsers(associationId);
  pp('$bb usersProvider did the job: ${res.length} users found.');
  return res;
});

final vehicleProvider = FutureProvider.family<List<Vehicle>, String >((ref, associationId) async {
  final res = await listApiDog.getAssociationVehicles(associationId);
  pp('$bb vehicleProvider did the job: ${res.length} cars found.');
  return res;
});
