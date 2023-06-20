// import 'package:kasie_transie_library/bloc/list_api_dog.dart';
// import 'package:proximity_hash/proximity_hash.dart';
//
// import '../data/schemas.dart';
// import '../utils/functions.dart';
//
// final GeoHashUtil geoHashUtil = GeoHashUtil();
//
// class GeoHashUtil {
//   static const mm = '☕️☕️☕️☕️☕️ GeoHashUtil: ☕️☕️';
//
//   List<City> cities = <City>[];
//
//   Future<List<City>> findCities(
//       {required String countryId,
//       required double latitude,
//       required double longitude,
//       required double radiusInKM}) async {
//     final start = DateTime.now();
//     pp('$mm ... finding cities via geohashes ... latitude: $latitude '
//         'longitude: $longitude radiusInKM: $radiusInKM');
//     if (cities.isEmpty) {
//       cities = await listApiDog.getCountryCities(countryId);
//     }
//     final end = DateTime.now();
//     pp('$mm ... finding cities via geohashes done, elapsed time : '
//         '${end.difference(start).inSeconds} seconds...');
//
//     final list = <City>[];
//     //get geohashes within radius
//     List<String> proximityGeohashes =
//         createGeohashes(latitude, longitude, radiusInKM * 1000, 6);
//     pp('$mm ... number of geohashes created : ${proximityGeohashes.length}');
//     pp('$mm ... number of cities from db : ${cities.length}');
//
//     for (var c in cities) {
//       var hash = convertToGeohash(0.0, 0.0, c.position!.coordinates.first,
//           c.position!.coordinates.last, 3);
//       if (proximityGeohashes.contains(hash)) {
//         list.add(c);
//         pp('$mm The coordinates $latitude,$longitude are within ${radiusInKM * 1000} meters of '
//             '${c.position!.coordinates.first}, ${c.position!.coordinates.last}');
//       }
//     }
//     final end2 = DateTime.now();
//
//     pp('$mm ... finding cities via geohashes ... '
//         '${list.length} cities found within $radiusInKM km. elapsed time : ${end.difference(start).inSeconds} seconds...');
//
//     return list;
//   }
// }
