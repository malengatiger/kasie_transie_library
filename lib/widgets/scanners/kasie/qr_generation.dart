import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import '../../../utils/functions.dart';

class QRGeneration {
  static Future<Uint8List> generateQrCodeWithImage({
    required Map<String, dynamic> data,
    required File logoFile,
    double? height,
    double? width,
  }) async {
    var dataToGenerate = jsonEncode(data);

    final logoImage = await decodeImageFromList(logoFile.readAsBytesSync());

    final qrPainter = QrPainter(
      data: dataToGenerate,
      version: QrVersions.auto,
      embeddedImage: logoImage,
      dataModuleStyle: const QrDataModuleStyle(
        color: Colors.black,
        dataModuleShape: QrDataModuleShape.square,
      ),
    );

    var imageSize = Size(width ?? 200, height ?? 200);
    final image = await qrPainter.toImage(imageSize.shortestSide);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var fileBytes = byteData!.buffer.asUint8List();

    pp('🌶🌶🌶 generateQrCodeWithImage: 🌶🌶🌶 image fileBytes: ${fileBytes.length} bytes');

    return fileBytes;
  }

  static Future<Uint8List> generateQrCode(
      {required Map<String, dynamic> data, double? height, double? width}) async {
    var dataToGenerate = jsonEncode(data);
    final qrPainter = QrPainter(
      data: dataToGenerate,
      version: QrVersions.auto,
      dataModuleStyle: const QrDataModuleStyle(
        color: Colors.black,
        dataModuleShape: QrDataModuleShape.square,
      ),
    );

    var imageSize = Size(width ?? 200, height ?? 200);
    final image = await qrPainter.toImage(imageSize.shortestSide);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var fileBytes = byteData!.buffer.asUint8List();

    pp('generateQrCode: 🌶🌶🌶 image fileBytes: ${fileBytes.length} bytes');

    return fileBytes;
  }

}
//
