import 'dart:convert';
import 'dart:io';

import 'package:fast_csv/csv_converter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/bloc/cloud_storage_bloc.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/uint_conveter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;
import 'package:universal_io/io.dart' as io;

import 'package:http/http.dart' as http;

import 'dart:typed_data';
import 'dart:ui' as ui;

class QRBucket {
  late String bucketFileName, qrCodeBytes, qrCodeUrl;
  QRBucket(
      {required this.bucketFileName,
      required this.qrCodeBytes,
      required this.qrCodeUrl});
}

class QRGenerationService {
  static const mm = '🔵🔵🔵🔵 QRGenerationService 🔵🔵';
  final CloudStorageBloc csb;
  QRGenerationService(this.csb);

  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  Future<QRBucket?> generateAndUploadQrCodeWithLogo({
    required Map<String, dynamic> data,
    required String? associationId,
    double? height,
    double? width,
  }) async {
    var dataToGenerate = jsonEncode(data);
    pp('$mm generateQrCodeWithLogo: 🌶🌶🌶 dataToGenerate: $dataToGenerate');
    // PlatformFile logoFile = await _getLogo();
    // final logoImage = await decodeImageFromList(logoFile.bytes!);

    final qrPainter = QrPainter(
      data: dataToGenerate,
      version: QrVersions.auto,
      // embeddedImage: logoImage,
      dataModuleStyle: const QrDataModuleStyle(
        color: Colors.black,
        dataModuleShape: QrDataModuleShape.square,
      ),
    );

    var imageSize = Size(width ?? 520, height ?? 520);
    final image = await qrPainter.toImage(imageSize.shortestSide);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var fileBytes = byteData!.buffer.asUint8List();
    pp('$mm generateQrCodeWithLogo: 🌶🌶🌶 fileBytes: ${fileBytes.length}');
    // var uu = await csb.uploadQRCodeBytes(fileBytes, associationName: associationId);
    //
    // pp('$mm generateQrCodeWithLogo: 🌶🌶🌶 uu: $uu');

    var appAuth = GetIt.instance<AppAuth>();
    var url = KasieEnvironment.getUrl();

    var mUrl = '${url}vehicle/uploadQRFile';
    if (associationId != null) {
      mUrl += '?associationId=$associationId';
    }
    pp('$mm generateQrCodeWithLogo: 🌶🌶🌶 mUrl: $mUrl');

    var token = await appAuth.getAuthToken();
    if (token == null) {
      throw Exception('Missing auth token');
    }

    headers['Authorization'] = 'Bearer $token';
    var request = http.MultipartRequest('POST', Uri.parse(mUrl));
    try {
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: 'qrFile${DateTime.now().millisecondsSinceEpoch}.png',
        ));
      } else {
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = '${tempDir.path}/qrFile${DateTime.now().millisecondsSinceEpoch}.png';
        File file = File(tempPath);
        await file.writeAsBytes(fileBytes); // Write the bytes to the file
        pp('$mm  adding file path: ${file.path}');
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }
    } catch (e, s) {
      pp('$mm ERROR adding file to request: $e $s');
      rethrow;
    }
    pp('$mm about to request.send files: ${request.files.length}');

    request.headers['Authorization'] = 'Bearer $token';
    var response = await request.send();
    pp('$mm response statusCode: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final responseString = await response.stream.bytesToString();
        // Attempt to parse JSON only if the response is not empty
        if (responseString.isNotEmpty) {
          var mJson = jsonDecode(responseString);
          pp('$mm responseString: $mJson');
          return QRBucket(
              bucketFileName: mJson['fileName'],
              qrCodeBytes: Uint8Converter.uint8ListToString(fileBytes),
              qrCodeUrl: mJson['url']);
        } else {
          pp('$mm responseString is empty.');
          throw Exception(
              'responseString is empty'); // Or a suitable default/error URL
        }
      } catch (e) {
        pp('$mm Error parsing JSON response: $e');
        pp('$mm Returning default URL after JSON parsing error.');
        rethrow; // Or a default/error URL
      }
    } else {
      pp('$mm We have a bad status code: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception('Bad status code');

    }
  }

  Future<PlatformFile> _getLogo() async {
    Uint8List bytes = await getAssetBytes('assets/images/k1.png');
    if (kIsWeb) {
      return PlatformFile(
        name: 'logo.png', // Provide a name
        size: bytes.length,
        bytes: bytes,
      );
    } else {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/logo.png');
      await file.writeAsBytes(bytes);
      pp('$mm _getLogo: 🌶🌶🌶 fileBytes: ${await file.length()} bytes');
      return PlatformFile(
          name: 'logo.png', size: await file.length(), path: file.path);
    }
  }

// ... existing getAssetBytes function ...

  Future<Uint8List> getAssetBytes(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    Uint8List bytes = data.buffer.asUint8List();
    pp('$mm getAssetBytes for logo: 🌶🌶🌶 image fileBytes: ${bytes.length} bytes');

    return bytes;
  }
}

List<Vehicle> getVehiclesFromCsv(
    {required String csv,
    required String countryId,
    required String associationId,
    required String associationName}) {
  List<Vehicle> cars = [];
  List<List<dynamic>> mCars = convertCsv(csv);
  pp('🥏🥏🥏 mCars: $mCars');

  // Skip the header row (index 0)
  for (int i = 1; i < mCars.length; i++) {
    var row = mCars[i];
    pp('🥏🥏🥏 row: $row');

    // Assuming your CSV structure is: owner, cell, reg, model, make, year, capacity
    var owner = row[0].toString(); // Convert to String
    var cell = row[1].toString();
    var reg = row[2].toString();
    var model = row[3].toString();
    var make = row[4].toString();
    var year = row[5].toString();
    var capacity = row[6].toString();

    pp("🌶🌶🌶 owner: $owner reg: $reg make: $make model: $model year: $year cap: $capacity");

    var car = Vehicle(
      countryId: countryId,
      vehicleReg: reg,
      make: make,
      model: model,
      year: year,
      passengerCapacity: int.tryParse(capacity) ?? 0,
      cellphone: cell,
      associationId: associationId,
      associationName: associationName,
      ownerName: owner,
      vehicleId: const Uuid().v4(), fcmToken: 'NAY',
    );
    cars.add(car);
  }

  pp('🥦🥦🥦 vehicles from file: 🍎 ${cars.length} cars');
  return cars;
}

List<User> getUsersFromCsv(
    {required String csv,
    required String countryId,
    required String associationId,
    required String associationName}) {
  List<User> users = [];
  List<List<dynamic>> mUsers = convertCsv(csv);
  // Skip the header row (index 0)
  for (int i = 1; i < mUsers.length; i++) {
    var row = mUsers[i];
    var userType = row[0].toString(); // Convert to String
    var firstName = row[1].toString();
    var lastName = row[2].toString();
    var email = row[3].toString();
    var cellphone = row[4].toString();

    pp("🌶🌶🌶 userType: $userType firstName: $firstName lastName: $lastName email: $email cellphone: $cellphone");

    var user = User(
        userType: userType,
        firstName: firstName,
        lastName: lastName,
        countryId: countryId,
        associationId: associationId,
        associationName: associationName,
        email: email,
        cellphone: cellphone);
    users.add(user);
  }
  pp('🥦🥦🥦 users from csv file: 🍎 ${users.length} users');

  return users;
}

List<List<String>> convertCsv(String csv) {
  final result = CsvConverter().convert(csv);
  for (var i = 1; i < result.length; i++) {
    final row = result[i];
    pp('🍎🍎🍎 csv row #$i: $row 🍎');
  }

  return result;
}
