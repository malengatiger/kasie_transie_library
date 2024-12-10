import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/vehicle_list.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/kasie_exception.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_io/io.dart' as io;
import 'package:universal_io/io.dart';

import '../data/calculated_distance_list.dart';
import '../data/data_schemas.dart';
import '../data/generation_request.dart';
import '../data/route_assignment_list.dart';
import '../data/route_point_list.dart';
import '../data/ticket.dart';
import '../utils/emojis.dart';
import '../utils/error_handler.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';
import 'app_auth.dart';
import 'cache_manager.dart';
import 'list_api_dog.dart';

class DataApiDog {
  static const mm = '🌎🌎🌎🌎🌎🌎 DataApiDog: 🌎🌎';

  final StreamController<RouteLandmark> _routeLandmarkController =
      StreamController.broadcast();

  Stream<RouteLandmark> get routeLandmarkStream =>
      _routeLandmarkController.stream;

  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  Map<String, String> zipHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/zip',
  };

  late String url;
  static const timeOutInSeconds = 360;
  String? token;
  final http.Client client;
  final AppAuth appAuth;
  final CacheManager cacheManager;
  final Prefs prefs;
  final ErrorHandler errorHandler;
  final SemCache semCache;

  DataApiDog(this.client, this.appAuth, this.cacheManager, this.prefs,
      this.errorHandler, this.semCache) {
    url = KasieEnvironment.getUrl();
    // getAuthToken();
  }

  Future<String?> getAuthToken() async {
    pp('$mm getAuthToken: ...... Getting Firebase token ......');
    try {
      var m = await appAuth.getAuthToken();
      if (m == null) {
        pp('$mm Unable to get Firebase token');
        return null;
      } else {
        pp('$mm Firebase token retrieved OK ✅ ');
        return m;
      }
    } catch (e, s) {
      pp('$mm $e $s');
      rethrow;
    }
  }

  Future uploadProfilePicture(
      {required File file, required File thumb, required String userId}) async {
    pp('\n\n$mm ............ uploadProfilePicture: 🌿 userId: $userId');

    var url = KasieEnvironment.getUrl();
    var mUrl = '${url}storage/uploadUserProfilePicture?userId=$userId';

    token = await getAuthToken();
    if (token == null) {
      throw Exception('Missing auth token');
    }

    headers['Authorization'] = 'Bearer $token';

    var request = http.MultipartRequest('POST', Uri.parse(mUrl));

    if (kIsWeb) {
      // For web, use fromBytes and avoid file system operations
      final imageFileBytes = await _readFileBytes(file);
      final thumbFileBytes = await _readFileBytes(thumb);
      request.files.add(
        http.MultipartFile.fromBytes(
          'imageFile',
          imageFileBytes,
          filename: file.path.split('/').last, // Use path for filename
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'thumbFile',
          thumbFileBytes,
          filename: thumb.path.split('/').last, // Use path for filename
        ),
      );
    } else {
      // For mobile/desktop, use fromPath
      request.files
          .add(await http.MultipartFile.fromPath('imageFile', file.path));
      request.files
          .add(await http.MultipartFile.fromPath('thumbFile', thumb.path));
    }

    pp('$mm File upload starting .....: $mUrl');

    request.headers['Authorization'] = 'Bearer $token';
    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      pp('$mm File uploaded successfully! 🥬🥬🥬🥬🥬');
      final responseBody = await response.stream.bytesToString();
      return responseBody;
    } else {
      pp('$mm 😈😈File upload failed with status code: 😈${response.statusCode} 😈 ${response.reasonPhrase}');
    }

    throw Exception('User Profile File upload failed');
  }

  Future<String?> uploadQRCodeFile(
      {required Uint8List imageBytes, required String associationId}) async {
    pp('\n\n$mm ............ uploadQRCodeFile: 🌿 associationId: $associationId');

    var url = KasieEnvironment.getUrl();
    var mUrl = '${url}storage/uploadQRCodeFile?associationId=$associationId';

    token = await getAuthToken();
    if (token == null) {
      throw Exception('Missing auth token');
    }

    headers['Authorization'] = 'Bearer $token';

    var request = http.MultipartRequest('POST', Uri.parse(mUrl));

    request.files.add(
      http.MultipartFile.fromBytes(
        'imageFile',
        imageBytes,
        filename: 'qrcode_$associationId.png', // Use path for filename
      ),
    );

    request.headers['Authorization'] = 'Bearer $token';
    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      pp('$mm 🥬🥬 QRCode File uploaded successfully! 🥬🥬🥬🥬🥬');
      final responseBody = await response.stream.bytesToString();
      return responseBody;
    } else {
      pp('\n\n$mm 😈😈😈😈😈😈File upload failed with status code: 😈${response.statusCode} 😈 ${response.stream.first.toString()} 😈😈');
    }

    throw Exception('QRCode File upload failed');
  }

  Future<AddCarsResponse?> importVehiclesFromCSV(
      PlatformFile file, String associationId) async {
    pp('$mm importVehiclesFromCSV: 🌿 associationId: $associationId');

    var url = KasieEnvironment.getUrl();
    var mUrl =
        '${url}vehicle/importVehiclesFromCSV?associationId=$associationId';

    token = await getAuthToken();
    if (token == null) {
      throw Exception('Missing auth token');
    }

    headers['Authorization'] = 'Bearer $token';

    var request = http.MultipartRequest('POST', Uri.parse(mUrl));
    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
      ));
    } else {
      // For mobile/desktop, use fromPath
      request.files.add(await http.MultipartFile.fromPath('file', file.path!));
    }
    if (kIsWeb) {
      // For web, read bytes as string
      final fileContents = utf8.decode(file.bytes!);
      pp('$mm 🌿🌿🌿🌿File contents:\n$fileContents 🌿');
    } else {
      // For mobile/desktop, read file from path
      final fileContents = await io.File(file.path!).readAsString();
      pp('$mm 🌿🌿🌿🌿 File contents:\n$fileContents File');
    }
    request.headers['Authorization'] = 'Bearer $token';
    var response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      pp('$mm File uploaded successfully! 🥬🥬🥬🥬🥬');
      final responseBody = await response.stream.bytesToString();
      final mJson = jsonDecode(responseBody);
      var result = AddCarsResponse.fromJson(mJson);
      for (var c in result.cars) {
        pp('$mm car added: ${c.vehicleReg}');
      }
      for (var c in result.errors) {
        pp('$mm car fucked up: ${c.vehicleReg}');
      }
      return result;
    } else {
      pp('$mm 😈😈File upload failed with status code: 😈${response.statusCode} 😈 ${response.reasonPhrase}');
    }
    throw Exception('Vehicles File upload failed');
  }

  Future<AddUsersResponse?> importUsersFromCSV(
      PlatformFile file, String associationId) async {
    pp('$mm importUsersFromCSV: 🌿 associationId: $associationId');

    var url = KasieEnvironment.getUrl();
    var mUrl = '${url}user/importUsersFromCSV?associationId=$associationId';
    var request = http.MultipartRequest('POST', Uri.parse(mUrl));
    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
      ));
    } else {
      // For mobile/desktop, use fromPath
      request.files.add(await http.MultipartFile.fromPath('file', file.path!));
    }
    if (kIsWeb) {
      // For web, read bytes as string
      final fileContents = utf8.decode(file.bytes!);
      pp('$mm 🌿🌿🌿🌿File contents:\n$fileContents 🌿');
    } else {
      // For mobile/desktop, read file from path
      final fileContents = await io.File(file.path!).readAsString();
      pp('$mm 🌿🌿🌿🌿 File contents:\n$fileContents File');
    }
    token = await getAuthToken();
    if (token == null) {
      throw Exception('Missing auth token');
    }
    request.headers['Authorization'] = 'Bearer $token';

    var response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      pp('$mm File uploaded successfully! 🥬🥬🥬🥬🥬');
      final responseBody = await response.stream.bytesToString();
      final mJson = jsonDecode(responseBody);
      var result = AddUsersResponse.fromJson(mJson);
      for (var c in result.users) {
        pp('$mm user added: ${c.firstName} ${c.lastName} - ${c.userType}');
      }
      for (var c in result.errors) {
        pp('$mm user fucked up: ${c.firstName} ${c.lastName} - ${c.userType}');
      }
      return result;
    } else {
      pp('$mm 😈😈File upload failed with status code: 😈${response.statusCode} 😈 ${response.reasonPhrase}');
    }
    throw Exception('Users File upload failed');
  }

  Future<VehiclePhoto> importVehicleProfile(
      {required PlatformFile file,
      required PlatformFile thumb,
      required String vehicleId,
      required double latitude,
      required double longitude}) async {
    pp('$mm importVehicleProfile: 🌿........... userId: $vehicleId');

    var url = KasieEnvironment.getUrl();
    var mUrl =
        '${url}storage/uploadVehiclePhoto?vehicleId=$vehicleId&latitude=$latitude&longitude=$longitude';
    var request = http.MultipartRequest('POST', Uri.parse(mUrl));
    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
        'imageFile',
        file.bytes!,
        filename: file.name,
      ));
      request.files.add(http.MultipartFile.fromBytes(
        'thumbFile',
        thumb.bytes!,
        filename: thumb.name,
      ));
    } else {
      // For mobile/desktop, use fromPath
      request.files
          .add(await http.MultipartFile.fromPath('imageFile', file.path!));
      request.files
          .add(await http.MultipartFile.fromPath('thumbFile', thumb.path!));
    }

    token = await getAuthToken();
    if (token == null) {
      throw Exception('Missing auth token');
    }
    request.headers['Authorization'] = 'Bearer $token';
    var response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      pp('\n\n$mm Yebo! Vehicle photo file uploaded successfully! 🥬🥬🥬🥬🥬\n');
      final responseBody = await response.stream.bytesToString();
      final mJson = jsonDecode(responseBody);
      var result = VehiclePhoto.fromJson(mJson);
      return result;
    } else {
      pp('$mm 😈😈File upload failed with status code: 😈${response.statusCode} 😈 ${response.reasonPhrase}');
    }
    throw Exception('Vehicle photo file upload failed');
  }

  Future<User> importUserProfile(
      {required PlatformFile file,
      required PlatformFile thumb,
      required String userId}) async {
    pp('$mm importUserProfile: 🌿 userId: $userId');

    var url = KasieEnvironment.getUrl();
    var mUrl = '${url}storage/uploadUserProfilePicture?userId=$userId';
    var request = http.MultipartRequest('POST', Uri.parse(mUrl));
    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
        'imageFile',
        file.bytes!,
        filename: file.name,
      ));
      request.files.add(http.MultipartFile.fromBytes(
        'thumbFile',
        thumb.bytes!,
        filename: thumb.name,
      ));
    } else {
      // For mobile/desktop, use fromPath
      request.files
          .add(await http.MultipartFile.fromPath('imageFile', file.path!));
      request.files
          .add(await http.MultipartFile.fromPath('thumbFile', thumb.path!));
    }

    token = await getAuthToken();
    if (token == null) {
      throw Exception('Missing auth token');
    }
    request.headers['Authorization'] = 'Bearer $token';

    var response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      pp('\n\n$mm File uploaded successfully! 🥬🥬🥬🥬🥬\n');
      final responseBody = await response.stream.bytesToString();
      final mJson = jsonDecode(responseBody);
      var result = User.fromJson(mJson);
      return result;
    } else {
      pp('$mm 😈😈File upload failed with status code: 😈${response.statusCode} 😈 ${response.reasonPhrase}');
    }
    throw Exception('Users File upload failed');
  }

  Future<Uint8List> _readFileBytes(io.File file) async {
    final reader = html.FileReader();
    final blob = html.Blob([await file.readAsBytes()]);
    reader.readAsArrayBuffer(blob);
    await reader.onLoadEnd.first;
    var res = reader.result as Uint8List;
    pp('$mm _readFileBytes: ... bytes from file: ${res.length}');
    return res;
  }

  Future<List<RouteAssignment>> addRouteAssignments(
      RouteAssignmentList assignments) async {
    final bag = assignments.toJson();
    final cmd = '${url}addRouteAssignments';
    List res = await _callPost(cmd, bag);
    var list = <RouteAssignment>[];
    for (var value in res) {
      final lr = RouteAssignment.fromJson(value);
      list.add(lr);
    }

    pp('$mm RouteAssignments added to database and cached on realm: ${list.length}');
    return list;
  }

  Future<CommuterRequest> addCommuterRequest(CommuterRequest request) async {
    final bag = request.toJson();
    final cmd = '${url}addCommuterRequest';
    final res = await _callPost(cmd, bag);
    final lr = CommuterRequest.fromJson(res);

    pp('$mm CommuterRequest added to database: $res');
    return lr;
  }

  Future addVehicleTelemetry(VehicleTelemetry telemetry) async {
    final bag = telemetry.toJson();
    final cmd = '${url}vehicle/addVehicleTelemetry';
    final res = await _callPost(cmd, bag);
    final lr = VehicleTelemetry.fromJson(res);

    pp('$mm VehicleTelemetry added to database: $res');
    return lr;
  }

  Future<LocationRequest> addLocationRequest(LocationRequest request) async {
    final bag = request.toJson();
    final cmd = '${url}addLocationRequest';
    final res = await _callPost(cmd, bag);
    final lr = LocationRequest.fromJson(res);
    pp('$mm LocationRequest added to database: $res');
    return lr;
  }

  Future<LocationResponse> addLocationResponse(
      LocationResponse response) async {
    final bag = response.toJson();
    final cmd = '${url}addLocationResponse';
    final res = await _callPost(cmd, bag);
    pp('$mm LocationResponse added to database: $res');
    final lr = LocationResponse.fromJson(res);
    return lr;
  }

  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    pp('$mm a......... adding vehicle: ${vehicle.toJson()}');
    final bag = vehicle.toJson();
    final cmd = '${url}vehicle/addVehicle';

    final res = await _callPost(cmd, bag);
    var car = Vehicle.fromJson(res);

    ListApiDog dog = GetIt.instance<ListApiDog>();
    var photos = await dog.getVehiclePhotos(vehicle, true);
    var videos = await dog.getVehicleVideos(vehicle, true);
    car.photos = photos;
    car.videos = videos;

    semCache.saveVehicles([car]);
    pp('$mm vehicle added or updated on Atlas database and local cache : 🥬 🥬 🥬 '
        ' \n${car.toJson()}');
    return car;
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    final bag = vehicle.toJson();
    final cmd = '${url}vehicle/updateVehicle';

    final res = await _callPost(cmd, bag);

    ListApiDog dog = GetIt.instance<ListApiDog>();
    var photos = await dog.getVehiclePhotos(vehicle, true);
    var videos = await dog.getVehicleVideos(vehicle, true);
    vehicle.photos = photos;
    vehicle.videos = videos;

    semCache.saveVehicles([vehicle]);
    pp('$mm vehicle added or updated on Atlas database and local cache : 🥬 🥬 🥬 '
        ' \n${vehicle.toJson()}');
    return res;
  }

  Future<User> addUser(User user) async {
    final bag = user.toJson();
    final cmd = '${url}user/addUser';
    final res = await _callPost(cmd, bag);
    // semCache.saveUsers([user]);
    pp('$mm user added to database: 🥬 🥬 $res');
    return User.fromJson(res);
  }

  Future<User> addOwner(User user) async {
    final bag = user.toJson();
    final cmd = '${url}user/createOwner';
    final res = await _callPost(cmd, bag);
    // semCache.saveUsers([user]);
    pp('$mm owner added to database: 🥬 🥬 $res');
    return User.fromJson(res);
  }

  Future addUserGeofenceEvent(UserGeofenceEvent event) async {
    final bag = event.toJson();
    final cmd = '${url}addUserGeofenceEvent';
    final res = await _callPost(cmd, bag);
    pp('$mm UserGeofenceEvent added to database: $res');
  }

  Future addDispatchRecord(DispatchRecord dispatchRecord) async {
    try {
      final bag = dispatchRecord.toJson();
      final cmd = '${url}dispatch/addDispatchRecord';
      final res = await _callPost(cmd, bag);
      final r = DispatchRecord.fromJson(res);

      pp('$mm DispatchRecord added to database: ${r.toJson()}');
      return r;
    } catch (e) {
      await cacheManager.saveDispatchRecord(dispatchRecord);
      pp(e);
    }
  }

  Future addVehicleArrival(VehicleArrival event) async {
    final bag = event.toJson();
    final cmd = '${url}addVehicleArrival';
    final res = await _callPost(cmd, bag);
    pp('$mm VehicleArrival added to database');
  }

  Future addVehicleDeparture(VehicleDeparture event) async {
    final bag = event.toJson();
    final cmd = '${url}addVehicleDeparture';
    final res = await _callPost(cmd, bag);
    pp('$mm VehicleDeparture added to database');
  }

  Future addVehicleHeartbeat(VehicleHeartbeat event) async {
    final bag = event.toJson();
    final cmd = '${url}addVehicleHeartbeat';
    final res = await _callPost(cmd, bag);
    pp('$mm .......... VehicleHeartbeat added to database');
  }

  Future sendRouteUpdateMessage(RouteUpdateRequest req) async {
    final cmd = '${url}routes/addRouteUpdateRequest';
    final res = await _callPost(cmd, req.toJson());
    pp('$mm .......... Route Update Message sent: $res, response 0 means GOOD!');
  }

  Future<Landmark> addLandmark(Landmark landmark) async {
    pp('$mm landmark to BE added to database ...');
    final bag = landmark.toJson();
    final cmd = '${url}addBasicLandmark';
    final res = await _callPost(cmd, bag);
    pp('$mm landmark added to database ...');
    myPrettyJsonPrint(res);
    final m = Landmark.fromJson(res);
    return m;
  }

  Future addRoutePoints(
      RoutePointList routePointList, String associationId) async {
    pp('$mm ... adding routePoints to database ...${routePointList.routePoints.length}');
    final cmd = '${url}routes/addRoutePoints';
    var res = await _callPost(cmd, routePointList.toJson());
    pp('$mm routePoints added to MongoDB Atlas database: $res');

    var routeId = routePointList.routePoints[0].routeId;
    await semCache.saveRoutePoints(
        routePoints: routePointList.routePoints,
        associationId: associationId,
        routeId: routeId!);
    return res as int;
  }

  Future<List<CalculatedDistance>> addCalculatedDistances(
      CalculatedDistanceList calculatedDistanceList) async {
    pp('$mm ... adding CalculatedDistances to database ...');

    final cmd = '${url}routes/addCalculatedDistances';
    List res = await _callPost(cmd, calculatedDistanceList.toJson());
    pp('$mm CalculatedDistances added to database: ${res.length}');
    final items = <CalculatedDistance>[];
    for (var cd in res) {
      items.add(CalculatedDistance.fromJson(cd));
    }

    pp('$mm calc distances cached: ${items.length}');
    return items;
  }

  Future<Route> addRoute(Route route) async {
    pp('$mm add route to database ... ${route.name}');
    myPrettyJsonPrint(route.toJson());

    final bag = route.toJson();
    final cmd = '${url}routes/addRoute';
    try {
      final res = await _callPost(cmd, bag);
      pp('$mm Raw response: $res');
      if (res == null) {}
      final newRoute = Route.fromJson(res);

      pp('$mm new route added to database ...  💙 💙 💙 check!');
      pp('$mm add new route to cache ...  💙 💙 💙 check!');
      var list = await semCache.saveRoute(route: newRoute);

      var dog = GetIt.instance<ListApiDog>();
      pp('$mm putting routes on stream ... $list routes');
      dog.putRouteInStream(list);

      return route;
    } catch (e, s) {
      pp("WTF? - $e - \n$s");
      rethrow;
    }
  }

  Future<Ticket> addTicket(Ticket ticket) async {
    pp('$mm add ticket to database ...');

    final bag = ticket.toJson();
    final cmd = '${url}ticket/addTicket';
    try {
      final res = await _callPost(cmd, bag);
      final newTicket = Ticket.fromJson(res);
      pp('$mm new ticket added to database ...  💙 💙 💙 check! ticketId');
      myPrettyJsonPrint(newTicket.toJson());
      return newTicket;
    } catch (e, s) {
      pp("$mm WTF? - $e - \n$s");
      throw Exception('Failed to add ticket to database.\n$e');
    }
  }

  Future addAppError(AppError error) async {
    final bag = error.toJson();
    final cmd = '${url}addAppError';
    final res = await _callPost(cmd, bag);
    pp('$mm AppError added to database ...');
    myPrettyJsonPrint(res);

    return 0;
  }

  Future addAppErrors(AppErrors errors) async {
    final bag = errors.toJson();
    final cmd = '${url}addAppErrors';
    List res = await _callPost(cmd, bag);
    pp('$mm AppErrors added to database ... ${res.length} errors');

    return 0;
  }

  Future<Commuter> addCommuter(Commuter commuter) async {
    final bag = commuter.toJson();
    final cmd = '${url}addCommuter';
    final res = await _callPost(cmd, bag);
    pp('$mm Commuter added to database ...');
    myPrettyJsonPrint(res);

    final r = Commuter.fromJson(res);
    prefs.saveCommuter(r);
    return r;
  }

  Future<User> updateUser(User user) async {
    pp('$mm .................................'
        'user to be updated on mongo database ${E.redDot} '
        'check that user is passed ...');

    myPrettyJsonPrint(user.toJson());
    final cmd = '${url}updateUser';
    final res = await _callPost(cmd, user.toJson());
    pp('$mm user updated on mongo database ... ${E.redDot} '
        'check if password present');
    myPrettyJsonPrint(res);
    final r = User.fromJson(res);

    return r;
  }

  Future<City> addCity(City city) async {
    final bag = city.toJson();
    final cmd = '${url}city/addCity';
    final res = await _callPost(cmd, bag);
    pp('$mm City added to database ...');
    myPrettyJsonPrint(res);
    final r = City.fromJson(res);
    await semCache.saveCities([r]);
    return r;
  }

  Future<Route> updateRouteColor(
      {required String routeId, required String color}) async {
    final cmd = '${url}routes/updateRouteColor?routeId=$routeId&color=$color';
    var res = await _sendHttpGET(cmd);
    final route = Route.fromJson(res);

    pp('$mm route with updated color cached ... ${route.name} - color: ${route.color}');
    myPrettyJsonPrint(route.toJson());
    return route;
  }

  void addRouteLandmarkToStream(RouteLandmark route) async {
    _routeLandmarkController.sink.add(route);
  }

  Future<RouteLandmark> addRouteLandmark(
      RouteLandmark route, String associationId) async {
    final bag = route.toJson();
    final cmd = '${url}routes/addRouteLandmark';
    final res = await _callPost(cmd, bag);
    pp('$mm RouteLandmark added to database ...');
    myPrettyJsonPrint(res);
    final r = RouteLandmark.fromJson(res);

    semCache.saveRouteLandmarks(
        routeId: route.routeId!, associationId: associationId, landmarks: [r]);
    _routeLandmarkController.sink.add(r);
    return r;
  }

  Future<List<RouteLandmark>> updateAssociationRouteLandmarks(
      String associationId) async {
    final cmd =
        '${url}updateAssociationRouteLandmarks?associationId=$associationId';
    List res = await _sendHttpGET(cmd);
    var list = <RouteLandmark>[];
    for (var mJson in res) {
      list.add(RouteLandmark.fromJson(mJson));
    }

    pp('$mm Association RouteLandmarks: ${list.length} updated and cached ${E.leaf}${E.leaf}');
    return list;
  }

  Future<List<RouteLandmark>> updateRouteLandmarks(String routeId) async {
    final cmd = '${url}updateRouteLandmarks?routeId=$routeId';
    List res = await _sendHttpGET(cmd);
    var list = <RouteLandmark>[];
    for (var mJson in res) {
      list.add(RouteLandmark.fromJson(mJson));
    }

    pp('$mm Route Landmarks ${list.length} updated and cached ${E.leaf}${E.leaf}');
    return list;
  }

  Future<RouteCity?> addRouteCity(RouteCity routeCity) async {
    final bag = routeCity.toJson();
    final cmd = '${url}routes/addRouteCity';
    try {
      final res = await _callPost(cmd, bag);
      final r = RouteCity.fromJson(res);
      pp('$mm ... route city added, 🔵 ${r.routeName} 🔵 ${r.cityName}');

      return r;
    } catch (e) {
      pp('$mm error writing route city, probable dup key error; ignoring!');
      rethrow;
    }
  }

  Future deleteRoutePointList(RoutePointList routePoints) async {
    pp('$mm deleteRoutePointList :  ... ${routePoints.routePoints.length}');

    final mUrl = '${url}routes/deleteRoutePointList';
    final res = await _callPost(mUrl, routePoints.toJson());
    pp('$mm deleteRoutePointList happened ... $res');

    return res;
  }

  Future deleteAllRoutePoints(String routeId) async {
    final cmd = '${url}routes/deleteRoutePoints?routeId=$routeId';
    final res = await _sendHttpGET(cmd);
    pp('$mm deleteAllRoutePoints happened ... $res');

    return res;
  }

  Future deleteLandmark(String landmarkId) async {
    final cmd = '${url}deleteLandmark?landmarkId=$landmarkId';
    final res = await _sendHttpGET(cmd);
    pp('$mm deleteLandmark happened ...');

    try {
      //listApiDog.removeRoutePoint(routePointId);
      pp('$mm deleteRoutePoint for Realm happened ...');
    } catch (e) {
      pp(e);
    }

    return res;
  }

  Future deleteRouteLandmark(String routeLandmarkId) async {
    final cmd =
        '${url}routes/deleteRouteLandmark?routeLandmarkId=$routeLandmarkId';

    try {
      List res = await _sendHttpGET(cmd);
      List<RouteLandmark> list = [];
      for (var json in res) {
        list.add(RouteLandmark.fromJson(json));
      }
      pp('$mm deleteRouteLandmark happened ... leftover marks: ${list.length}');

      return list;
    } catch (e) {
      pp(e);
      throw Exception('Delete Route Landmark failed:\n$e');
    }
  }

  Future<RegistrationBag> registerAssociation(Association association) async {
    final bag = association.toJson();
    final cmd = '${url}association/registerAssociation';

    final res = await _callPost(cmd, bag);
    RegistrationBag rBag = RegistrationBag.fromJson(res);
    prefs.saveAssociation(rBag.association!);
    prefs.saveUser(rBag.adminUser!);
    await semCache.saveRegistrationBag(rBag);
    pp('$mm association registered! added to cache: 🍎${rBag.association!.toJson()}');
    pp('$mm administrator registered! added to cache: 🍎${rBag.adminUser!.toJson()}');
    return rBag;
  }

  Future<SettingsModel> addSettings(SettingsModel settings) async {
    final bag = settings.toJson();
    final cmd = '${url}addSettingsModel';

    final res = await _callPost(cmd, bag);
    final r = SettingsModel.fromJson(res);

    pp('$mm settings added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<VehiclePhoto> addVehiclePhoto(VehiclePhoto vehiclePhoto) async {
    final bag = vehiclePhoto.toJson();
    final cmd = '${url}vehicle/addVehiclePhoto';

    final res = await _callPost(cmd, bag);
    final r = VehiclePhoto.fromJson(res);

    pp('$mm VehiclePhoto added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<UserPhoto> addUserPhoto(UserPhoto userPhoto) async {
    final bag = userPhoto.toJson();
    final cmd = '${url}user/addUserPhoto';

    final res = await _callPost(cmd, bag);
    final r = UserPhoto.fromJson(res);

    pp('$mm UserPhoto added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<VehicleMediaRequest> addVehicleMediaRequest(
      VehicleMediaRequest vehicleMediaRequest) async {
    final bag = vehicleMediaRequest.toJson();
    final cmd = '${url}addVehicleMediaRequest';

    final res = await _callPost(cmd, bag);
    final r = VehicleMediaRequest.fromJson(res);
    pp('$mm VehicleMediaRequest added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<RouteUpdateRequest> addRouteUpdateRequest(
      RouteUpdateRequest routeUpdateRequest) async {
    final bag = routeUpdateRequest.toJson();
    final cmd = '${url}addRouteUpdateRequest';

    final res = await _callPost(cmd, bag);
    final r = RouteUpdateRequest.fromJson(res);

    pp('$mm RouteUpdateRequest added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<VehicleVideo> addVehicleVideo(VehicleVideo vehicleVideo) async {
    final bag = vehicleVideo.toJson();
    final cmd = '${url}addVehicleVideo';

    final res = await _callPost(cmd, bag);
    final r = VehicleVideo.fromJson(res);
    pp('$mm vehicleVideo added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<AmbassadorCheckIn> addAmbassadorCheckIn(
      AmbassadorCheckIn checkIn) async {
    final bag = checkIn.toJson();
    final cmd = '${url}addAmbassadorCheckIn';

    final res = await _callPost(cmd, bag);
    final r = AmbassadorCheckIn.fromJson(res);

    pp('$mm AmbassadorCheckIn added to database ...');
    myPrettyJsonPrint(res);

    return r;
  }

  Future<AmbassadorPassengerCount> addAmbassadorPassengerCount(
      AmbassadorPassengerCount count) async {
    final bag = count.toJson();
    final cmd = '${url}addAmbassadorPassengerCount';

    try {
      final res = await _callPost(cmd, bag);
      final r = AmbassadorPassengerCount.fromJson(res);
      pp('$mm AmbassadorPassengerCount added to database ...');
      myPrettyJsonPrint(res);
      return r;
    } catch (e) {
      pp(e);
      cacheManager.saveAmbassadorPassengerCount(count);
    }
    return count;
  }

//
  Future<List<DispatchRecord>> generateDispatchRecords(
      String associationId, int numberOfCars, int intervalInSeconds) async {
    final cmd = '${url}generateDispatchRecords?associationId=$associationId'
        '&numberOfCars=$numberOfCars&intervalInSeconds=$intervalInSeconds';
    List res = await _sendHttpGET(cmd);
    var list = <DispatchRecord>[];
    for (var mJson in res) {
      list.add(DispatchRecord.fromJson(mJson));
    }

    pp('$mm DispatchRecords: ${list.length}  cached ${E.leaf}${E.leaf}');
    return list;
  }

//
  Future generateRouteDispatchRecords(GenerationRequest request) async {
    final cmd = '${url}generateRouteDispatchRecords';
    final res = await _callPost(cmd, request.toJson());

    pp('\n\n$mm generateRouteDispatchRecords: Demo Vehicles: ${request.vehicleIds.length}  $res ${E.leaf}${E.leaf}');

    return res;
  }

  //
  Future<List<Vehicle>> generateRouteDispatchRecordsForCars(
      {required VehicleList vehicleList}) async {
    final cmd = '${url}generateRouteDispatchRecordsForCars';
    List res = await _callPost(cmd, vehicleList.toJson());
    var list = <Vehicle>[];
    for (var value in res) {
      list.add(Vehicle.fromJson(value));
    }
    pp('\n\n$mm generateRouteDispatchRecordsForCars sent: cars: ${list.length}  ${E.leaf}${E.leaf}');

    return list;
  }

//
  Future<List<CommuterRequest>> generateCommuterRequests(String associationId,
      int numberOfCommuters, int intervalInSeconds) async {
    final cmd = '${url}generateCommuterRequests?associationId=$associationId'
        '&numberOfCommuters=$numberOfCommuters&intervalInSeconds=$intervalInSeconds';
    List res = await _sendHttpGET(cmd);
    var list = <CommuterRequest>[];
    for (var mJson in res) {
      list.add(CommuterRequest.fromJson(mJson));
    }

    pp('$mm CommuterRequests: ${list.length}  cached ${E.leaf}${E.leaf}');
    return list;
  }

  Future generateRouteCommuterRequests(String routeId) async {
    final cmd = '${url}generateRouteCommuterRequests?routeId=$routeId';
    final res = await _sendHttpGET(cmd);
    pp('$mm CommuterRequests: $res ${E.leaf}${E.leaf}');
    return res;
  }

  Future<List<AmbassadorPassengerCount>> generateAmbassadorPassengerCounts(
      String associationId, int numberOfCars, int intervalInSeconds) async {
    final cmd =
        '${url}generateAmbassadorPassengerCounts?associationId=$associationId'
        '&numberOfCars=$numberOfCars&intervalInSeconds=$intervalInSeconds';
    List res = await _sendHttpGET(cmd);
    var list = <AmbassadorPassengerCount>[];
    for (var mJson in res) {
      list.add(AmbassadorPassengerCount.fromJson(mJson));
    }

    pp('$mm AmbassadorPassengerCounts: ${list.length}  cached ${E.leaf}${E.leaf}');
    return list;
  }

  Future<List<AmbassadorPassengerCount>> generateRoutePassengerCounts(
      String routeId, int numberOfCars, int intervalInSeconds) async {
    final cmd = '${url}generateRoutePassengerCounts?routeId=$routeId'
        '&numberOfCars=$numberOfCars&intervalInSeconds=$intervalInSeconds';
    List res = await _sendHttpGET(cmd);
    var list = <AmbassadorPassengerCount>[];
    for (var mJson in res) {
      list.add(AmbassadorPassengerCount.fromJson(mJson));
    }
    pp('$mm AmbassadorPassengerCounts: ${list.length}  cached ${E.leaf}${E.leaf}');
    return list;
  }

  Future generateRouteHeartbeats(GenerationRequest request) async {
    final cmd = '${url}generateRouteHeartbeats';
    final bag = request.toJson();
    final res = await _callPost(cmd, bag);

    pp('$mm VehicleHeartbeats: $res  ${E.leaf}${E.leaf}');
    return res;
  }

  static const dev = '👿👿👿';

  Future _callPost(String mUrl, dynamic bag) async {
    pp('$mm  ......... _callWebAPIPost calling: $mUrl');

    String? mBag;
    mBag = json.encode(bag);
    const maxRetries = 3;
    var retryCount = 0;
    var waitTime = const Duration(seconds: 2);
    var start = DateTime.now();
    token ??= await getAuthToken();
    if (token == null) {
      throw Exception('token not found');
    }
    headers['Authorization'] = 'Bearer $token';
    while (retryCount < maxRetries) {
      try {
        var resp = await client
            .post(
              Uri.parse(mUrl),
              body: mBag,
              headers: headers,
            )
            .timeout(const Duration(seconds: timeOutInSeconds));
        pp('$mm  _callWebAPIPost RESPONSE: 👌👌👌 statusCode: ${resp.statusCode} 👌👌👌 for $mUrl');

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          try {
            var mJson = json.decode(resp.body);
            return mJson;
          } catch (e) {
            pp("$mm $dev  $dev  json.decode failed, returning response body");
            return resp.body;
          }
        } else {
          if (resp.statusCode == 401 || resp.statusCode == 403) {
            pp('$mm  $dev  _callWebAPIPost: 🔆 statusCode:  ${resp.statusCode} $dev for $mUrl');
            pp('$mm metadata: ${resp.body}');
            pp('$mm  $dev  _callWebAPIPost: 🔆 Firebase ID token may have expired, trying to refresh ... 🔴🔴🔴🔴🔴🔴 ');
            token = await getAuthToken();

            pp('$mm Throwing my toys!!! : 💙 statusCode: ${resp.statusCode} $dev  ');
            final gex = KasieException(
                message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
                url: mUrl,
                translationKey: 'serverProblem',
                errorType: KasieException.socketException);
            errorHandler.handleError(exception: gex);
            throw Exception('The status is BAD, Boss!');
          } else {
            if (resp.statusCode == 400 || resp.statusCode == 500) {
              final gex = KasieException(
                  message: 'Bad status code: ${resp.statusCode} - ${resp.body}, please try again',
                  url: mUrl,
                  translationKey: 'serverProblem',
                  errorType: KasieException.socketException);
              errorHandler.handleError(exception: gex);
              throw Exception('The status is BAD, Boss!');
            }
          }
        }
        var end = DateTime.now();
        pp('$mm  _callWebAPIPost: 🔆 elapsed time: ${end.difference(start).inSeconds} seconds 🔆 $mUrl');
      } on io.SocketException catch (e) {
        pp('$mm  SocketException: really means that server cannot be reached 😑');
        final gex = KasieException(
            message: 'Server not available: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.socketException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on io.HttpException catch (e) {
        pp("$mm  HttpException occurred 😱");
        final gex = KasieException(
            message: 'Server not available: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.httpException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on http.ClientException catch (e) {
        pp("$mm   http.ClientException  occurred 😱");
        final gex = KasieException(
            message: 'ClientException: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.httpException);
        errorHandler.handleError(exception: gex);
        retryCount++;
        if (retryCount < maxRetries) {
          // Calculate the exponential backoff wait time
          waitTime *= 2;
          await Future.delayed(waitTime);
        }
      } on FormatException catch (e) {
        pp("$mm  Bad response format 👎");
        final gex = KasieException(
            message: 'Bad response format: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.formatException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on TimeoutException catch (e) {
        pp("$mm  No Internet connection. Request has timed out in $timeOutInSeconds seconds 👎");
        final gex = KasieException(
            message: 'Request timed out. No Internet connection: $e',
            url: mUrl,
            translationKey: 'networkProblem',
            errorType: KasieException.timeoutException);
        errorHandler.handleError(exception: gex);
        throw gex;
      }
    }
  }

  Future _sendHttpGET(String mUrl) async {
    pp('$mm _sendHttpGET: 🔆 🔆 🔆 calling : 💙 $mUrl  💙');
    var start = DateTime.now();
    const maxRetries = 3;
    var retryCount = 0;
    var waitTime = const Duration(seconds: 2);
    var token = await appAuth.getAuthToken();
    if (token != null) {
      pp('$mm _sendHttpGET: 😡😡😡 Firebase Auth Token: 💙️ Token is GOOD! 💙 ');
    } else {
      pp('$mm Firebase token missing ${E.redDot}${E.redDot}${E.redDot}${E.redDot}');
      final gex = KasieException(
          message: 'Firebase Authentication token missing',
          url: mUrl,
          translationKey: 'networkProblem',
          errorType: KasieException.timeoutException);
      errorHandler.handleError(exception: gex);
      throw gex;
    }
    headers['Authorization'] = 'Bearer $token';
    while (retryCount < maxRetries) {
      try {
        var resp = await client
            .get(
              Uri.parse(mUrl),
              headers: headers,
            )
            .timeout(const Duration(seconds: timeOutInSeconds));
        pp('$mm http GET call RESPONSE: .... : 💙 statusCode: 👌👌👌 ${resp.statusCode} 👌👌👌 💙 for $mUrl');
        var end = DateTime.now();
        pp('$mm http GET call: 🔆 elapsed time for http: ${end.difference(start).inSeconds} seconds 🔆 \n\n');

        if (resp.body.contains('not found')) {
          return false;
        }

        if (resp.statusCode == 403) {
          var msg =
              '😡 😡 status code: ${resp.statusCode}, Request Forbidden 🥪 🥙 🌮  😡 ${resp.body}';
          pp(msg);
          final gex = KasieException(
              message: 'Forbidden call',
              url: mUrl,
              translationKey: 'serverProblem',
              errorType: KasieException.httpException);
          errorHandler.handleError(exception: gex);
          throw gex;
        }

        if (resp.statusCode != 200) {
          var msg =
              '😡 😡 The response is not 200; it is ${resp.statusCode}, NOT GOOD, throwing up !! 🥪 🥙 🌮  😡 ${resp.body}';
          pp(msg);
          final gex = KasieException(
              message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
              url: mUrl,
              translationKey: 'serverProblem',
              errorType: KasieException.socketException);
          errorHandler.handleError(exception: gex);
          throw gex;
        }
        var mJson = json.decode(resp.body);
        return mJson;
      } on io.SocketException catch (e) {
        pp('$mm  SocketException: really means that server cannot be reached 😑');
        final gex = KasieException(
            message: 'Server not available: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.socketException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on io.HttpException catch (e) {
        pp("$mm  HttpException occurred 😱");
        final gex = KasieException(
            message: 'Server not available: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.httpException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on http.ClientException catch (e) {
        pp("$mm   http.ClientException  occurred 😱");
        final gex = KasieException(
            message: 'ClientException: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.httpException);
        errorHandler.handleError(exception: gex);
        retryCount++;
        if (retryCount < maxRetries) {
          // Calculate the exponential backoff wait time
          waitTime *= 2;
          await Future.delayed(waitTime);
        }
      } on FormatException catch (e) {
        pp("$mm  Bad response format 👎");
        final gex = KasieException(
            message: 'Bad response format: $e',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.formatException);
        errorHandler.handleError(exception: gex);
        throw gex;
      } on TimeoutException catch (e) {
        pp("$mm  No Internet connection. Request has timed out in $timeOutInSeconds seconds 👎");
        final gex = KasieException(
            message: 'Request timed out. No Internet connection: $e',
            url: mUrl,
            translationKey: 'networkProblem',
            errorType: KasieException.timeoutException);
        errorHandler.handleError(exception: gex);
        throw gex;
      }
    }
  }
}
