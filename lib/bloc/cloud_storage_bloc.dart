import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/utils/kasie_exception.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realm/realm.dart';

import '../utils/device_location_bloc.dart';
import '../utils/functions.dart';

final CloudStorageBloc cloudStorageBloc = CloudStorageBloc();
const photoStorageName = 'kasieTransiePhotos';
const videoStorageName = 'kasieTransieVideos';

class CloudStorageBloc {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  Random rand = Random(DateTime.now().millisecondsSinceEpoch);
  static const mm = '☕️☕️☕️☕️☕️☕️ CloudStorageBloc: 💚💚 ';

  final StreamController<lib.VehiclePhoto> _photoStreamController =
      StreamController.broadcast();
  final StreamController<lib.VehicleVideo> _videoStreamController =
      StreamController.broadcast();

  final StreamController<String> _errorStreamController =
      StreamController.broadcast();

  Stream<lib.VehiclePhoto> get photoStream => _photoStreamController.stream;
  Stream<lib.VehicleVideo> get videoStream => _videoStreamController.stream;

  Stream<String> get errorStream => _errorStreamController.stream;

  Future<int> uploadPhoto(
      {required lib.Vehicle car,
      required File file,
      required File thumbnailFile}) async {
    pp('\n\n\n$mm️ uploadPhoto ☕️☕️☕️☕️☕️☕️☕️️ ... ${car.vehicleReg}');

    pp('\n$mm adding photo data to the database ...o');
    try {
      pp('$mm adding photo ..... 😡😡 😡😡');
      final user = await prefs.getUser();

      final urls = await _doTheUpload(
          file: file,
          thumbnailFile: thumbnailFile,
          vehicleId: car.vehicleId!,
          isVideo: false);
      final loc = await locationBloc.getLocation();
      final position = lib.Position(
          type: 'Point',
          coordinates: [loc.longitude, loc.latitude],
          latitude: loc.latitude,
          longitude: loc.longitude);

      var vehiclePhoto = lib.VehiclePhoto(
        ObjectId(),
        vehiclePhotoId: Uuid.v4().toString(),
        vehicleId: car.vehicleId,
        vehicleReg: car.vehicleReg,
        userName: user!.name,
        userId: user.name,
        url: urls.$1,
        thumbNailUrl: urls.$2,
        created: DateTime.now().toUtc().toIso8601String(),
        associationId: user!.associationId,
        position: position,
      );

      await dataApiDog.addVehiclePhoto(vehiclePhoto);
      return uploadFinished;
    } catch (e) {
      pp('\n\n$mm 👿👿👿👿 Photo write to database failed, We may have a database problem: 🔴🔴🔴 $e');
      return uploadError;
    }
  }

  Future<int> uploadVideo(
      {required lib.Vehicle car,
      required File file,
      required File thumbnailFile}) async {
    pp('\n\n\n$mm️ uploadVideo ☕️☕️☕️☕️☕️☕️☕️️ ... ${car.vehicleReg}');

    pp('\n$mm adding video data to the database ...o');
    try {
      pp('$mm adding video ..... 😡😡 😡😡');
      final user = await prefs.getUser();

      final urls = await _doTheUpload(
          file: file,
          thumbnailFile: thumbnailFile,
          vehicleId: car.vehicleId!,
          isVideo: true);
      final loc = await locationBloc.getLocation();
      final position = lib.Position(
          type: 'Point',
          coordinates: [loc.longitude, loc.latitude],
          latitude: loc.latitude,
          longitude: loc.longitude);

      var vehicleVideo = lib.VehicleVideo(
        ObjectId(),
        vehicleVideoId: Uuid.v4().toString(),
        vehicleId: car.vehicleId,
        vehicleReg: car.vehicleReg,
        userName: user!.name,
        userId: user.name,
        url: urls.$1,
        thumbNailUrl: urls.$2,
        created: DateTime.now().toUtc().toIso8601String(),
        associationId: user.associationId,
        position: position,
      );

      await dataApiDog.addVehicleVideo(vehicleVideo);
      return uploadFinished;
    } catch (e) {
      pp('\n\n$mm 👿👿👿👿 Video write to database failed, We may have a database problem: 🔴🔴🔴 $e');
      return uploadError;
    }
  }

  Future<(String, String)> _doTheUpload(
      {required File file,
      required File thumbnailFile,
      required String vehicleId,
      required bool isVideo}) async {
    pp('$mm️ uploadPhoto ☕️☕️☕️☕️☕️☕️☕️ file path: \n${file.path}');
    //upload main file
    late UploadTask uploadTask;
    late TaskSnapshot taskSnapshot;
    var type = 'jpg';
    if (isVideo) {
      type = 'mp4';
    }
    final suffix = '${vehicleId}__${DateTime.now().millisecondsSinceEpoch}.jpg';

    var fileName = 'photo_$suffix';
    var firebaseStorageRef =
        FirebaseStorage.instance.ref().child(photoStorageName).child(fileName);
    uploadTask = firebaseStorageRef.putFile(file);
    _reportProgress(uploadTask);
    taskSnapshot = await uploadTask.whenComplete(() {});
    final url = await taskSnapshot.ref.getDownloadURL();
    pp('$mm file url is available, meaning that upload is complete: \n$url');
    _printSnapshot(taskSnapshot);
    // upload thumbnail here
    final thumbName = 'thumbnail_$suffix';
    final firebaseStorageRef2 =
        FirebaseStorage.instance.ref().child(photoStorageName).child(thumbName);

    final thumbUploadTask = firebaseStorageRef2.putFile(thumbnailFile);
    final thumbTaskSnapshot = await thumbUploadTask.whenComplete(() {});
    final thumbUrl = await thumbTaskSnapshot.ref.getDownloadURL();
    pp('$mm thumbnail file url is available, meaning that upload is complete: \n$thumbUrl');
    _printSnapshot(thumbTaskSnapshot);

    return (url, thumbUrl);
  }

  void _printSnapshot(TaskSnapshot taskSnapshot) {
    var totalByteCount = taskSnapshot.totalBytes;
    var bytesTransferred = taskSnapshot.bytesTransferred;
    var bt = '${(bytesTransferred / 1024).toStringAsFixed(2)} KB';
    var tot = '${(totalByteCount / 1024).toStringAsFixed(2)} KB';
    pp('$mm uploadTask: 💚💚 '
        'photo or video upload complete '
        ' 🧩 $bt of $tot 🧩 transferred.'
        ' date: ${DateTime.now().toIso8601String()}\n');
  }

  void _reportProgress(UploadTask uploadTask) {
    uploadTask.snapshotEvents.listen((event) {
      var totalByteCount = event.totalBytes;
      var bytesTransferred = event.bytesTransferred;
      var bt = '${(bytesTransferred / 1024).toStringAsFixed(2)} KB';
      var tot = '${(totalByteCount / 1024).toStringAsFixed(2)} KB';
      pp('️$mm _reportProgress:  💚 progress ******* 🧩 $bt KB of $tot KB 🧩 transferred');
      // listener.onFileProgress(event.totalBytes, event.bytesTransferred);
    });
  }

  void thumbnailProgress(UploadTask uploadTask) {
    uploadTask.snapshotEvents.listen((event) {
      var totalByteCount = event.totalBytes;
      var bytesTransferred = event.bytesTransferred;
      var bt = '${(bytesTransferred / 1024).toStringAsFixed(2)} KB';
      var tot = '${(totalByteCount / 1024).toStringAsFixed(2)} KB';
      pp('$mm️ .uploadThumbnail:  🥦 progress ******* 🍓 $bt KB of $tot KB 🍓 transferred');
    });
  }

  static const xz = '🌿🌿🌿🌿🌿🌿🌿 CloudStorageBloc: ';
  Future<File> downloadFile(String mUrl) async {
    pp('$xz : downloadFile: 😡😡😡 $mUrl ....');

    try {
      final http.Response response =
          await http.get(Uri.parse(mUrl)).catchError((e) {
        pp('😡😡😡 Download failed: 😡😡😡 $e');
        throw Exception('😡😡😡 Download failed: $e');
      });

      pp('$xz : downloadFile: OK?? 💜💜💜💜'
          '  statusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Directory directory = await getApplicationDocumentsDirectory();
        var type = 'jpg';
        if (mUrl.contains('mp4')) {
          type = 'mp4';
        }
        final File mFile = File(
            '${directory.path}/download${DateTime.now().millisecondsSinceEpoch}.$type');
        pp('$xz : downloadFile: 💜  .... new file: ${mFile.path}');
        mFile.writeAsBytesSync(response.bodyBytes);
        var len = await mFile.length();
        pp('$xz : downloadFile: 💜  .... file downloaded length: 😡 '
            '${(len / 1024).toStringAsFixed(1)} KB - path: ${mFile.path}');
        return mFile;
      } else {
        pp('$xz : downloadFile: Download failed: 😡😡😡 statusCode ${response.statusCode} 😡 ${response.body} 😡');
        throw Exception('Download failed: statusCode: ${response.statusCode}');
      }
    } on SocketException {
      pp('$xz No Internet connection, really means that server cannot be reached 😑');
      throw KasieException(
          message: 'No Internet connection',
          url: mUrl,
          translationKey: 'networkProblem',
          errorType: KasieException.socketException);
    } on HttpException {
      pp("$xz HttpException occurred 😱");
      throw KasieException(
          message: 'Server not around',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.httpException);
    } on FormatException {
      pp("$xz Bad response format 👎");
      throw KasieException(
          message: 'Bad response format',
          url: mUrl,
          translationKey: 'serverProblem',
          errorType: KasieException.formatException);
    } on TimeoutException {
      pp("$xz GET Request has timed out in $timeOutInSeconds seconds 👎");
      throw KasieException(
          message: 'Request timed out',
          url: mUrl,
          translationKey: 'networkProblem',
          errorType: KasieException.timeoutException);
    }
  }

  static const timeOutInSeconds = 120;
  // ignore: missing_return
  Future<int> deleteFolder(String folderName) async {
    pp('.deleteFolder ######## deleting $folderName');
    var task = _firebaseStorage.ref().child(folderName).delete();
    await task.then((f) {
      pp('.deleteFolder $folderName deleted from FirebaseStorage');
      return 0;
    }).catchError((e) {
      pp('.deleteFolder ERROR $e');
      return 1;
    });
    return 0;
  }

  // ignore: missing_return
  Future<int> deleteFile(String folderName, String name) async {
    pp('.deleteFile ######## deleting $folderName : $name');
    var task = _firebaseStorage.ref().child(folderName).child(name).delete();
    task.then((f) {
      pp('.deleteFile $folderName : $name deleted from FirebaseStorage');
      return 0;
    }).catchError((e) {
      pp('.deleteFile ERROR $e');
      return 1;
    });
    return 0;
  }

  CloudStorageBloc() {
    pp('🍇 🍇 🍇 🍇 🍇 StorageBloc constructor 🍇 🍇 🍇 🍇 🍇');
  }
}

const uploadBusy = 201;
const uploadFinished = 200;
const uploadError = 500;
