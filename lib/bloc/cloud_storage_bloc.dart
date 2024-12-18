import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/kasie_exception.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:uuid/uuid.dart';
import '../utils/device_location_bloc.dart';
import '../utils/functions.dart';
import 'data_api_dog.dart';

// import 'package:firebase/firebase.dart' as fb;
const photoStorageName = 'kasieTransiePhotos';
const videoStorageName = 'kasieTransieVideos';

class CloudStorageBloc {
  final FirebaseStorage firebaseStorage;
  Random rand = Random(DateTime.now().millisecondsSinceEpoch);
  static const mm = '☕️☕️☕️☕️☕️☕️ CloudStorageBloc: 💚💚 ';

  final DataApiDog dataApiDog;
  final Prefs prefs;
  final DeviceLocationBloc locationBloc;
  CloudStorageBloc(
      {required this.dataApiDog,
      required this.prefs,
      required this.locationBloc,
      required this.firebaseStorage});

  final StreamController<lib.VehiclePhoto> _photoStreamController =
      StreamController.broadcast();
  final StreamController<lib.VehicleVideo> _videoStreamController =
      StreamController.broadcast();

  final StreamController<String> _errorStreamController =
      StreamController.broadcast();

  Stream<lib.VehiclePhoto> get photoStream => _photoStreamController.stream;
  Stream<lib.VehicleVideo> get videoStream => _videoStreamController.stream;

  Stream<String> get errorStream => _errorStreamController.stream;

  Future<String> uploadQRCodeBytes(Uint8List fileBytes,
      {required String associationName}) async {
    pp('$mm upload file .........');
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      pp('$mm User is not signed in!  Cannot upload.');
      throw Exception("User not signed in"); // Or handle appropriately
    } else {
      pp('\n$mm 🔵🔵🔵🔵 User is signed in! ${user.displayName} 🔵🔵🔵🔵');
      await user.getIdToken(true); // Force refresh of the token if needed
    }
    var ref = firebaseStorage.ref();
    pp('$mm upload bucket: ${ref.bucket}');
    pp('$mm upload fullPath: ${ref.fullPath}');
    pp('$mm upload storage: ${ref.storage.toString()}');

    final storageRef = firebaseStorage.ref().child(
        '/kasie-transie-3_data/$associationName/qrcodes/qr_${DateTime.now().toIso8601String()}.png');

    pp('$mm upload storageRef: ${storageRef.toString()}');
    final newMetadata = SettableMetadata(
      cacheControl: "public,max-age=300",
      contentType: "image/png",
      customMetadata: <String, String>{'public': 'true'},
    );
    pp('$mm storageRef name: 🍎 ${storageRef.name}');
    try {
      await storageRef.putData(fileBytes, newMetadata as SettableMetadata?);
      // var url = await getPublicDownloadUrl(storageRef.toString());
      // pp('$mm url: $url');
      return 'url';
    } catch (e, s) {
      pp('$mm 😈😈😈ERROR: 😈😈😈$e \n$s');
      throw Exception('File upload failed: $e');
    }
  }

  Future<String?> getPublicDownloadUrl(String bucketFileName) async {
    try {
      final storageRef = FirebaseStorage.instance.refFromURL(bucketFileName);
      pp('$mm getPublicDownloadUrl: storageRef: $storageRef');
      pp('$mm getPublicDownloadUrl: storageRef.bucket: ${storageRef.bucket}');
      pp('$mm getPublicDownloadUrl: storageRef.fullPath: ${storageRef.fullPath}');

      final downloadUrl = await storageRef.getDownloadURL();
      pp('$mm getPublicDownloadUrl: downloadUrl: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      pp('Error getting download URL: $e');
      return null; // Or throw an exception if you prefer
    }
  }

  Future<int> uploadUserPhoto(
      {required lib.User mUser,
      required File file,
      required File thumbnailFile}) async {
    pp('\n\n\n$mm️ uploadUserPhoto ☕️☕️☕️☕️☕️☕️☕️️ ... ${mUser.email}');

    pp('\n$mm adding photo data to the database ...');
    try {
      pp('$mm uploading photo ..... 😡😡 😡😡');

      final urls = await _doTheUpload(
          file: file,
          thumbnailFile: thumbnailFile,
          id: mUser.userId!,
          isVideo: false);

      pp('$mm adding photo ..... 😡😡 😡😡');

      var userPhoto = lib.UserPhoto(
          userPhotoId: 'userPhotoId',
          associationId: mUser.associationId,
          associationName: mUser.associationName,
          userName: '${mUser.firstName} ${mUser.lastName}',
          userId: mUser.userId,
          created: DateTime.now().toIso8601String(),
          thumbNailUrl: urls.$2,
          url: urls.$1);

      await dataApiDog.addUserPhoto(userPhoto);
      return uploadFinished;
    } catch (e) {
      pp('\n\n$mm 👿👿👿👿 Photo write to database failed, We may have a database problem: 🔴🔴🔴 $e');
      return uploadError;
    }
  }

  Future<int> uploadVehiclePhoto(
      {required lib.Vehicle car,
      required File file,
      required File thumbnailFile}) async {
    pp('\n\n\n$mm️ uploadVehiclePhoto ☕️☕️☕️☕️☕️☕️☕️️ ... ${car.vehicleReg}');
    pp('\n$mm adding photo data to the database ...o');
    try {
      pp('$mm adding photo ..... 😡😡 😡😡');
      final user = prefs.getUser();

      // dataApiDog.upl

      final urls = await _doTheUpload(
          file: file,
          thumbnailFile: thumbnailFile,
          id: car.vehicleId!,
          isVideo: false);
      final loc = await locationBloc.getLocation();
      final position = lib.Position(
          type: 'Point',
          coordinates: [loc.longitude, loc.latitude],
          latitude: loc.latitude,
          longitude: loc.longitude,
          geoHash: null);

      var vehiclePhoto = lib.VehiclePhoto(
        vehiclePhotoId: const Uuid().v4().toString(),
        vehicleId: car.vehicleId,
        vehicleReg: car.vehicleReg,
        userName: user!.name,
        userId: user.userId,
        url: urls.$1,
        thumbNailUrl: urls.$2,
        created: DateTime.now().toUtc().toIso8601String(),
        associationId: user.associationId,
        position: position,
      );

      pp('$mm vehiclePhoto to be sent to db: ${vehiclePhoto.toJson()}');
      await dataApiDog.addVehiclePhoto(vehiclePhoto);
      return uploadFinished;
    } catch (e) {
      pp('\n\n$mm 👿👿👿👿 Photo write to database failed, We may have a database problem: 🔴🔴🔴 $e');
      return uploadError;
    }
  }

  Future<String> uploadQRCode({
    required String id,
    required File file,
  }) async {
    pp('\n\n\n$mm️ uploadQRCode ☕️☕️☕️☕️☕️☕️☕️️ ... ${file.path}');

    pp('\n$mm adding qrcode to cloud ...o');
    try {
      final url = await _doFileUpload(file: file, id: id);

      pp('\n$mm  🌿🌿🌿 qrcode url: $url 🌿🌿🌿');

      return url;
    } catch (e) {
      pp('\n\n$mm 👿👿👿👿 qrcode upload failed: 🔴🔴🔴 $e');
      rethrow;
    }
  }

  Future<int> uploadVehicleVideo(
      {required lib.Vehicle car,
      required File file,
      required File thumbnailFile}) async {
    pp('\n\n\n$mm️ uploadVideo ☕️☕️☕️☕️☕️☕️☕️️ ... ${car.vehicleReg}');

    pp('\n$mm adding video data to the database ...o');
    try {
      pp('$mm adding video ..... 😡😡 😡😡');
      final user = prefs.getUser();

      final urls = await _doTheUpload(
          file: file,
          thumbnailFile: thumbnailFile,
          id: car.vehicleId!,
          isVideo: true);
      final loc = await locationBloc.getLocation();
      final position = lib.Position(
          type: 'Point',
          coordinates: [loc.longitude, loc.latitude],
          latitude: loc.latitude,
          longitude: loc.longitude);

      var vehicleVideo = lib.VehicleVideo(
        vehicleVideoId: const Uuid().v4().toString(),
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

  Future<(String, String)> _doTheUpload({
    required File file,
    required File thumbnailFile,
    required String id,
    required bool isVideo,
  }) async {
    pp('$mm️ _doTheUpload ☕️☕️☕️☕️☕️☕️☕️ file path: \n${file.path}');

    // Upload main file
    late UploadTask uploadTask;
    late TaskSnapshot taskSnapshot;
    var type = 'jpg';
    if (isVideo) {
      type = 'mp4';
    }
    final suffix = '${id}__${DateTime.now().millisecondsSinceEpoch}.$type';

    var fileName = 'photo_$suffix';
    var firebaseStorageRef =
        firebaseStorage.ref().child(photoStorageName).child(fileName);

    if (kIsWeb) {
      // For web, use putData instead of putFile
      final bytes = await file.readAsBytes();
      uploadTask = firebaseStorageRef.putData(bytes);
    } else {
      // For mobile/desktop, use putFile
      uploadTask = firebaseStorageRef.putFile(file);
    }

    _reportProgress(uploadTask);
    taskSnapshot = await uploadTask.whenComplete(() {});
    final url = await taskSnapshot.ref.getDownloadURL();
    pp('$mm file url is available, meaning that upload is complete: \n$url');
    _printSnapshot(taskSnapshot);

    // Upload thumbnail
    final thumbName = 'thumbnail_$suffix';
    final firebaseStorageRef2 =
        firebaseStorage.ref().child(photoStorageName).child(thumbName);

    late UploadTask thumbUploadTask;
    if (kIsWeb) {
      // For web, use putData instead of putFile
      final thumbBytes = await thumbnailFile.readAsBytes();
      thumbUploadTask = firebaseStorageRef2.putData(thumbBytes);
    } else {
      // For mobile/desktop, use putFile
      thumbUploadTask = firebaseStorageRef2.putFile(thumbnailFile);
    }

    final thumbTaskSnapshot = await thumbUploadTask.whenComplete(() {});
    final thumbUrl = await thumbTaskSnapshot.ref.getDownloadURL();
    pp('$mm thumbnail file url is available, meaning that upload is complete: \n$thumbUrl');
    _printSnapshot(thumbTaskSnapshot);

    return (url, thumbUrl);
  }

  Future<String> _doFileUpload({
    required File file,
    required String id,
  }) async {
    pp('$mm️ _doFileUpload ☕️☕️☕️☕️☕️☕️☕️ file path: \n${file.path}');

    // Upload main file
    late UploadTask uploadTask;
    late TaskSnapshot taskSnapshot;
    var type = 'png';
    final suffix = '${id}__${DateTime.now().millisecondsSinceEpoch}.$type';

    var fileName = 'qrcode_$suffix';
    var firebaseStorageRef =
        firebaseStorage.ref().child(photoStorageName).child(fileName);

    if (kIsWeb) {
      // For web, use putData instead of putFile
      final bytes = await file.readAsBytes();
      uploadTask = firebaseStorageRef.putData(bytes);
    } else {
      uploadTask = firebaseStorageRef.putFile(file);
    }
    _reportProgress(uploadTask);
    taskSnapshot = await uploadTask.whenComplete(() {});
    final url = await taskSnapshot.ref.getDownloadURL();
    pp('$mm file url is available, meaning that upload is complete, url: \n$url');
    _printSnapshot(taskSnapshot);

    return (url);
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
  Future<Uint8List?> downloadFile(String fileName) async {
    pp('$xz : downloadFile from cloud storage: 😡😡😡 $fileName ....');

    try {
      // Create a storage reference from our app
      final storageRef = firebaseStorage.ref();
      final pathReference = storageRef.child(fileName);
      var bytes = await pathReference.getData();
      return bytes;
    } catch (e) {
      pp('$xz No Internet connection, really means that server cannot be reached 😑');
      throw KasieException(
          message: 'cloud storage download failed',
          url: 'downLoadFile',
          translationKey: 'networkProblem',
          errorType: KasieException.socketException);
    }
  }

  static const timeOutInSeconds = 120;
}

const uploadBusy = 201;
const uploadFinished = 200;
const uploadError = 500;
