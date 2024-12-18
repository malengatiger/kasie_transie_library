import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';

import '../bloc/cloud_storage_bloc.dart';
import '../bloc/data_api_dog.dart';
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
  DeviceLocationBloc deviceLocationBloc = GetIt.instance<DeviceLocationBloc>();

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
    pp('\n\n$mm .....photo taking started ....');
    myPrettyJsonPrint(widget.vehicle.toJson());

    var height = 640.0, width = 480.0;

    final XFile? xFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxHeight: height,
        maxWidth: width,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.front);

    if (xFile != null) {
      await _processFile(xFile);
      setState(() {});
    }
    // xFile.saveTo(path);
  }

  File? imageFile, thumbFile;

  Future<void> _processFile(XFile file) async {
    pp('$mm _processFile 🔵🔵🔵 file to upload, '
        'size: ${await file.length()} bytes 🔵');

    //
    bool isLandscape = false;

    pp('$mm ... isLandscape: $isLandscape - check if true!  🍎');
    final suffix =
        '${user!.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      var x = '/photo_$suffix';
      final File mFile =
          File('${directory.path}$x'); // Create a new File in app directory
      await file.saveTo(
          mFile.path); // Copy contents of original file to the app's directory

      if (_deviceOrientation != null) {
        switch (_deviceOrientation!.name) {
          case 'landscapeLeft':
            isLandscape = true;
            _processOrientation(mFile, _deviceOrientation!);
            break;
          case 'landscapeRight':
            isLandscape = true;
            _processOrientation(mFile, _deviceOrientation!);
            break;
        }
      } else {
        pp('😈😈😈😈😈_deviceOrientation is null, wtf?? 😈 means that user did not change device orientation? ..........');
      }
      var thumb = await _getThumbnail(mFile);

      pp('$mm ... mFile: ${await mFile.length()} bytes,  🍎');
      pp('$mm ... thumb: ${await thumb?.length()} bytes,  🍎');

      setState(() {
        imageFile = mFile;
        thumbFile = thumb;
        _showUploadPhoto = true;
        _showNextPhoto = true;
      });

      widget.onPhotoTaken(mFile, thumb!);

      var size = await mFile.length();
      var m = (size / 1024 / 1024).toStringAsFixed(2);
      pp('$mm Picture taken is $m MB in size');

      if (mounted) {
        showToast(
            context: context,
            message: fileSavedWillUpload == null
                ? 'Picture file saved on device, size: $m MB'
                : fileSavedWillUpload!,
            backgroundColor: Colors.black,
            textStyle: myTextStyle(color: Colors.white),
            toastGravity: ToastGravity.TOP,
            duration: const Duration(seconds: 2));
      }
    } catch (e, s) {
      pp('$e $s');
    }
  }

  Future<File?> _getThumbnail(File mFile) async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    final File tFile = File(
        '${appDocumentDirectory.path}/thumbnails${DateTime.now().millisecondsSinceEpoch}.jpg');

    final imageCommand = img.Command();
    imageCommand.decodeImageFile(mFile.path);
    imageCommand.copyResize(width: 100, height: 100);
    imageCommand.writeToFile(tFile.path);
    var cmdRes = await imageCommand.executeThread();
    return tFile;
  }

  void _startNextPhoto() {
    pp('$mm _startNextPhoto');
    _startPhoto();
  }

  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();

  Future _uploadFiles() async {
    pp('$mm ..................... _uploadFiles for vehicle: ');
    myPrettyJsonPrint(widget.vehicle.toJson());
    setState(() {
      _busy = true;
    });
    try {
      var loc = await deviceLocationBloc.getLocation();
      dataApiDog.uploadVehiclePhotoFromCamera(
          file: imageFile!,
          thumb: thumbFile!,
          vehicleId: widget.vehicle.vehicleId!,
          latitude: loc.latitude,
          longitude: loc.longitude);

      photos.add(imageFile!);
      thumbNails.add(thumbFile!);
      if (mounted) {
        showOKToast(
            duration: const Duration(seconds: 2),
            message: 'Photo uploaded OK', context: context);
      }
    } catch (e, s) {
      pp('$e $s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }
    setState(() {
      _showUploadPhoto = false;
      _showNextPhoto = true;
      _busy = false;
    });
  }

  List<File> photos = [];
  List<File> thumbNails = [];
  bool _showUploadPhoto = false;
  bool _showNextPhoto = false;
  bool _busy = false;

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
        ),
        body: Stack(
          children: [
            imageFile == null
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/intro/pic5.jpg'),
                          opacity: 0.1,
                          fit: BoxFit.cover),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(imageFile!), fit: BoxFit.cover),
                    ),
                  ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 20,
              child: SizedBox(
                width: 240,
                height: 160,
                child: Card(
                  elevation: 4,
                  color: Colors.black26,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _showUploadPhoto
                          ? TextButton(
                              onPressed: () {
                                _uploadFiles();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  'Upload Photo',
                                  style: myTextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ))
                          : gapW4,
                      _showNextPhoto
                          ? TextButton(
                              onPressed: _startNextPhoto,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  takePicture == null
                                      ? 'Take Picture'
                                      : takePicture!,
                                  style: myTextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ))
                          : gapH32,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 16, bottom: 16, child: ElevatedButton(onPressed: (){
                Navigator.of(context).pop();
            },
                child: const Text('Done'))
            ),
            _busy
                ? const Positioned(
                    child: Center(
                        child: CircularProgressIndicator(
                    strokeWidth: 4,
                  )))
                : gapW32,
          ],
        ),
      ),
    );
  }
}
