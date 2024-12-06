import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'functions.dart';

class Uint8Converter {
  //  Utilities for working with Uint8List

// 1. Uint8List to String and back (using Base64 encoding)
  static String uint8ListToString(Uint8List data) {
    return base64Encode(data);
  }

  static Uint8List stringToUint8List(String string) {
    return base64Decode(string);
  }

// 2. Uint8List to File and back  (using temporary files - Mobile Only)
  static Future<File> uint8ListToFile(Uint8List data, String filename) async {
    // Get a temporary directory.  This will not work for Flutter Web
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = '${tempDir.path}/$filename'; // Create unique filename
    final file = File(tempFilePath);
    await file.writeAsBytes(data);
    return file;
  }


  static Future<Uint8List?> fileToUint8List(File file) async {
    try {
      return await file.readAsBytes();
    } catch (e) {
      // Handle any file read errors
      pp('Error reading file: $e');
      return null; // Or throw an exception if you prefer
    }
  }

}
