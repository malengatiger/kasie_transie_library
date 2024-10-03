import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';

import '../bloc/cloud_storage_bloc.dart';
import '../l10n/translation_handler.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';

class PhotoHandler extends StatefulWidget {
  const PhotoHandler({
    super.key,
    required this.vehicle,
    required this.onPhotoTaken,
  });

  final lib.Vehicle vehicle;
  final Function(File, File) onPhotoTaken;

  @override
  PhotoHandlerState createState() => PhotoHandlerState();
}

class PhotoHandlerState extends State<PhotoHandler>
    with SingleTickerProviderStateMixin {
  final mm =
      '${E.blueDot}${E.blueDot}${E.blueDot}${E.blueDot} PhotoHandler: 🌿';

  Prefs prefs = GetIt.instance<Prefs>();
  CloudStorageBloc cloudStorageBloc = GetIt.instance<CloudStorageBloc>();


  late AnimationController _controller;
  final ImagePicker _picker = ImagePicker();
  late StreamSubscription orientStreamSubscription;
  late StreamSubscription<String> killSubscription;

  NativeDeviceOrientation? _deviceOrientation;
  // var polygons = <mrm.ProjectPolygon>[];
  // var positions = <mrm.ProjectPosition>[];
  lib.User? user;
  String? fileSavedWillUpload;
  String? totalByteCount, bytesTransferred;
  String? fileUrl, thumbnailUrl, takePicture;
  // late mrm.SettingsModel sett;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _observeOrientation();
    _startPhoto();
  }

  Future _setTexts() async {
    user = prefs.getUser();
    final c = prefs.getColorAndLocale();
    fileSavedWillUpload =
        await translator.translate('fileSavedWillUpload', c.locale);
    takePicture = await translator.translate('takePicture', c.locale);
  }

  Future<void> _observeOrientation() async {
    pp('${E.blueDot} ........ _observeOrientation ... ');
    Stream<NativeDeviceOrientation> stream =
        NativeDeviceOrientationCommunicator()
            .onOrientationChanged(useSensor: true);
    orientStreamSubscription = stream.listen((event) {
      // pp('${E.blueDot}${E.blueDot} orientation, name: ${event.name} index: ${event.index}');
      _deviceOrientation = event;
    });
  }

  void _startPhoto() async {
    pp('$mm photo taking started ....');
    var settings = prefs.getSettings();
    var height = 640.0, width = 480.0;

    final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        maxHeight: height,
        maxWidth: width,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.front);

    if (file != null) {
      await _processFile(file);
      setState(() {});
    }
    // file.saveTo(path);
  }

  File? finalFile;
  Future<void> _processFile(XFile file) async {
    File mImageFile = File(file.path);
    pp('$mm _processFile 🔵🔵🔵 file to upload, '
        'size: ${await mImageFile.length()} bytes🔵');

    var thumbnailFile = await getPhotoThumbnail(file: mImageFile);
    bool isLandscape = false;
    if (_deviceOrientation != null) {
      switch (_deviceOrientation!.name) {
        case 'landscapeLeft':
          isLandscape = true;
          break;
        case 'landscapeRight':
          isLandscape = true;
          break;
      }
    } else {
      pp('_deviceOrientation is null, wtf?? means that user did not change device orientation ..........');
    }
    pp('$mm ... isLandscape: $isLandscape - check if true!  🍎');
    final suffix =
        '${user!.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final Directory directory = await getApplicationDocumentsDirectory();
    var x = '/photo_$suffix';
    final File mFile = File('${directory.path}$x');
    var z = '/photo_thumbnail_$suffix';
    final File tFile =
        File('${directory.path}$z${DateTime.now().millisecondsSinceEpoch}.jpg');
    await thumbnailFile.copy(tFile.path);
    //can i force
    if (_deviceOrientation != null) {
      final finalFile =
          await _processOrientation(mImageFile, _deviceOrientation!);
      await finalFile.copy(mFile.path);
    } else {
      await mImageFile.copy(mFile.path);
    }
    setState(() {
      finalFile = mFile;
    });

    widget.onPhotoTaken(mFile, tFile);

    cloudStorageBloc.uploadPhoto(
        car: widget.vehicle, file: mFile, thumbnailFile: tFile);

    var size = await mFile.length();
    var m = (size / 1024 / 1024).toStringAsFixed(2);
    pp('$mm Picture taken is $m MB in size');
    if (mounted) {
      showToast(
          context: context,
          message: fileSavedWillUpload == null
              ? 'Picture file saved on device, size: $m MB'
              : fileSavedWillUpload!,
          backgroundColor: Theme.of(context).primaryColor,
          textStyle: myTextStyleSmall(context),
          toastGravity: ToastGravity.TOP,
          duration: const Duration(seconds: 2));
    }
  }

  void _startNextPhoto() {
    pp('$mm _startNextPhoto');
    _startPhoto();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<File> _processOrientation(
      File file, NativeDeviceOrientation deviceOrientation) async {
    pp('$mm _processOrientation: attempt to rotate image file ...');
    switch (deviceOrientation.name) {
      case 'landscapeLeft':
        pp('$mm landscapeLeft ....');
        break;
      case 'landscapeRight':
        pp('$mm landscapeRight ....');
        break;
      case 'portraitUp':
        return file;
      case 'portraitDown':
        return file;
    }
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    final File mFile = File(
        '${appDocumentDirectory.path}/rotatedImageFile${DateTime.now().millisecondsSinceEpoch}.jpg');

    final img.Image? capturedImage = img.decodeImage(await file.readAsBytes());
    var orientedImage = img.copyRotate(capturedImage!, angle: 270);

    await File(mFile.path).writeAsBytes(img.encodeJpg(orientedImage));

    final heightOrig = capturedImage.height;
    final widthOrig = capturedImage.width;

    final height = orientedImage.height;
    final width = orientedImage.width;

    pp('$mm _processOrientation: rotated file has 😡height: $height 😡width: $width, 🔵 '
        'original file size: height: $heightOrig width: $widthOrig');
    return mFile;
  }
  String? takePhoto;


  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var color = getTextColorForBackground(Theme.of(context).primaryColor);

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios)),
          title: Text(
            '${widget.vehicle.vehicleReg}',
            style: myTextStyleMediumWithColor(context, color),
          ),
          // actions: [
          //   IconButton(
          //       onPressed: _navigateTimeline,
          //       icon: Icon(
          //         Icons.list,
          //         color: Theme.of(context).primaryColor,
          //       )),
          // ],
        ),
        body: Stack(
          children: [
            finalFile == null
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/intro/pic2.jpg'),
                          opacity: 0.1,
                          fit: BoxFit.cover),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(finalFile!), fit: BoxFit.cover),
                    ),
                  ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 20,
              child: SizedBox(
                width: 240,
                height: 80,
                child: Card(
                  elevation: 4,
                  color: Colors.black38,
                  shape: getDefaultRoundedBorder(),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      TextButton(
                          onPressed: _startNextPhoto,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(
                              takePicture == null
                                  ? 'Take Picture'
                                  : takePicture!,
                              style: myTextStyleMediumWithColor(context, color),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
