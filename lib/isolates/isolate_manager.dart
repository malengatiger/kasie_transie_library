import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../utils/functions.dart';



// Message class for communication with the isolate
class ThumbnailRequest {
  final String filePath;
  final SendPort sendPort;

  ThumbnailRequest(this.filePath, this.sendPort);
}

// Isolate function to generate the thumbnail
Future<void> _thumbnailIsolate(ThumbnailRequest request) async {
  const mm = '☕️☕️☕️☕️☕️☕️ ThumbnailRequest: 💚💚 ';

  final String filePath = request.filePath;
  final SendPort sendPort = request.sendPort;
  final File mFile = File(filePath);

  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  final File tFile = File(
      '${appDocumentDirectory.path}/thumbnails${DateTime.now().millisecondsSinceEpoch}.jpg');


  final imageCommand = img.Command();
  imageCommand.decodeImageFile(mFile.path);
  imageCommand.copyResize(width: 100, height: 100);
  imageCommand.writeToFile(tFile.path);
  var cmdRes = await imageCommand.executeThread();


  // Send the generated thumbnail file back to the main isolate
  Isolate.exit(sendPort, tFile);



}


Future<File?> getThumbnail(File mFile) async {
  pp('🔆🔆🔆🔆🔆 ThumbnailRequest: getThumbnail in isolate : 💦💦...');

  final ReceivePort receivePort = ReceivePort();
  final ThumbnailRequest request = ThumbnailRequest(
      mFile.path, receivePort.sendPort);
  // Spawn a new isolate
  final Isolate isolate =
  await Isolate.spawn<ThumbnailRequest>(_thumbnailIsolate, request);

  // Receive the thumbnail from the isolate
  File? thumbnailFile = await receivePort.first;
  // Clean up the isolate and the port
  isolate.kill(priority: Isolate.immediate);
  receivePort.close();


  pp('🔆🔆🔆🔆🔆 ThumbnailRequest: getThumbnail: 💦💦 thumbnail: ${thumbnailFile?.lengthSync()} bytes');
  return thumbnailFile;
}
