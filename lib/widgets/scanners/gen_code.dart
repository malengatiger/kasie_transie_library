import 'dart:convert';

import 'package:fast_csv/csv_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

import '../../utils/functions.dart';

Future<Uint8List> generateQrCode(Map<String, dynamic> data) async {
  var dataToGenerate = jsonEncode(data);
  final qrPainter = QrPainter(
    data: dataToGenerate,
    version: QrVersions.auto,
    dataModuleStyle: const QrDataModuleStyle(
      color: Colors.black,
      dataModuleShape: QrDataModuleShape.square,
    ),
  );

  const imageSize = Size(200, 200);
  final image = await qrPainter.toImage(imageSize.shortestSide);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  var fileBytes = byteData!.buffer.asUint8List();
  pp('generateQrCode: 🌶🌶🌶 image fileBytes: ${fileBytes.length} bytes');

  return fileBytes;
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

    // Assuming your CSV structure is: owner, reg, model, make, year, capacity
    var owner = row[0].toString(); // Convert to String
    var reg = row[1].toString();
    var model = row[2].toString();
    var make = row[3].toString();
    var year = row[4].toString();
    var capacity = row[5].toString();

    pp("🌶🌶🌶 owner: $owner reg: $reg make: $make model: $model year: $year cap: $capacity");

    var car = Vehicle(
      countryId: countryId,
      vehicleReg: reg,
      make: make,
      model: model,
      year: year,
      passengerCapacity: int.tryParse(capacity) ?? 0,
      // Handle parsing errors
      associationId: associationId,
      associationName: associationName,
      ownerName: owner,
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
        password: 'pass${DateTime.now().millisecondsSinceEpoch}_${random.toString()}',
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
