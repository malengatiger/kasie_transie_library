import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/data/route_bag.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/isolates/heartbeat_isolate.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:universal_io/io.dart';
import 'functions.dart';

final ZipHandler zipHandler = ZipHandler();

class ZipHandler {
  static const xz = '🍐🍐🍐🍐 ZipHandler : ';

  Future<RouteBag?> getRouteBag(
      {required String associationId}) async {
    pp('$xz _getRouteBag: 🔆🔆🔆 get zipped data ...');

    final mUrl = '${KasieEnvironment.getUrl()}getAssociationRouteZippedFile?associationId=&';
    var start = DateTime.now();
    late RouteBag routeBag;
    final token = await appAuth.getAuthToken();
    if (token == null) {
      return null;
    }
    http.Response response = await httpGet(mUrl, token);

    pp('$xz _getRouteBag: 🔆🔆🔆 get zipped data, response: ${response.contentLength} bytes ...');

    File zipFile =
        File('zip${DateTime.now().millisecondsSinceEpoch}.zip');
    zipFile.writeAsBytesSync(response.bodyBytes);
    pp('$xz _getRouteBag: 🔆🔆🔆 handle file inside zip: ${await zipFile.length()} bytes');

    //create zip archive
    final inputStream = InputFileStream(zipFile.path);
    final archive = ZipDecoder().decodeBuffer(inputStream);

    pp('$xz _getRouteBag: 🔆🔆🔆 handle file inside zip archive: ${archive.files.length} files');

    for (var file in archive.files) {
      if (file.isFile) {
        var fileName = file.name;
        pp('$xz _getRouteBag: file from inside archive ... ${file.size} bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
        var outFile = File(fileName);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
        pp('$xz _getRouteBag: file after decompress ... ${await outFile.length()} bytes  🍎 path: ${outFile.path} 🍎');

        if (outFile.existsSync()) {
          var m = outFile.readAsStringSync(encoding: utf8);
          var mJson = json.decode(m);
          routeBag = RouteBag.fromJson(mJson);
          pp('$xz _getRouteBag 🍎🍎🍎🍎 bag has been filled!');
          var end = DateTime.now();
          var ms = end.difference(start).inSeconds;
          pp('$xz _getRouteBag 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎\n\n');
        } else {
          pp('$xz ERROR: could not find file');
        }
      }
    }
    return routeBag;
  }
}
