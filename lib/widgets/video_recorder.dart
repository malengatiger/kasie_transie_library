import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kasie_transie_library/bloc/cloud_storage_bloc.dart';
import 'package:kasie_transie_library/widgets/video_controls.dart';

import 'package:path_provider/path_provider.dart';
import 'package:realm/realm.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../data/schemas.dart' as lib;
import '../l10n/translation_handler.dart';
import '../utils/device_location_bloc.dart';
import '../utils/functions.dart';
import '../utils/prefs.dart';

List<CameraDescription> cameras = [];

class VideoRecorder extends StatefulWidget {
  const VideoRecorder({
    Key? key,
    required this.vehicle, required this.onVideoMade,
  }) : super(key: key);

  final lib.Vehicle vehicle;
  final Function(File, File) onVideoMade;


  @override
  VideoRecorderState createState() => VideoRecorderState();
}

class VideoRecorderState extends State<VideoRecorder>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  static const mm = '🍏🍏🍏🍏🍏🍏 VideoRecorder: ';

  final resolutionPresets = ResolutionPreset.values;
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  late CameraController _cameraController;

  CameraDescription? cameraDescription;
  bool _isCameraInitialized = false;
  Timer? timer;
  Duration duration = const Duration(seconds: 0);
  Duration finalDuration = const Duration(seconds: 0);
  bool _showChoice = false;

  String? title;
  String? fileUploadSize,
      uploadAudioClipText,
      locationNotAvailable,
      elapsedTime,
      fileSizeText,
      videoToBeUploaded,
      getCameraReady,
      recordingComplete,
      durationText,
      fileSavedWillUpload,
      recordingLimitReached,
      waitingToRecordVideo;
  int limitInSeconds = 0;
  // late StreamSubscription<SettingsModel> settingsSubscription;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    pp('$mm initState cameras: ${cameras.length} ...');
    super.initState();
    // Hide the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _setTexts();
    _getUser();
    _getCameras();
  }

  Future _setTexts() async {
    final c = await prefs.getColorAndLocale();
    final loc = c.locale!;
    limitInSeconds = 2 * 60;
    recordingComplete = await translator.translate('recordingComplete', loc);
    elapsedTime = await translator.translate('elapsedTime', loc);

    fileUploadSize = await translator.translate('fileSize', loc);
    uploadAudioClipText = await translator.translate('uploadAudioClip', loc);
    elapsedTime = await translator.translate('elapsedTime', loc);
    locationNotAvailable =
        await translator.translate('locationNotAvailable', loc);

    waitingToRecordVideo =
        await translator.translate('waitingToRecordVideo', loc);
    recordingLimitReached =
        await translator.translate('recordingLimitReached', loc);
    videoToBeUploaded = await translator.translate('videoToBeUploaded', loc);
    maxSeconds = 120;
    title = await translator.translate('recordVideo', loc);
    durationText = await translator.translate('duration', loc);
    fileSizeText = await translator.translate('fileSize', loc);
    fileSavedWillUpload =
        await translator.translate('fileSavedWillUpload', loc);

    setState(() {});
  }

  lib.User? user;
  void _getUser() async {
    user = await prefs.getUser();
  }

  int maxSeconds = 10;
  bool busy = false;
  void _getCameras() async {
    setState(() {
      busy = true;
    });
    try {
      user = await prefs.getUser();
      cameras = await availableCameras();

      pp('$mm video recording limit: $maxSeconds seconds');
      onNewCameraSelected(cameras[0]);
    } catch (e) {
      pp(e);
      if (mounted) {
        showToast(message: '$e', context: context);
      }
    }

    setState(() {
      busy = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    pp('$mm didChangeAppLifecycleState: $state');
    final CameraController cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (!cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  bool _isRecordingInProgress = false;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    pp('$mm onNewCameraSelected: $cameraDescription');
    // final previousCameraController = _cameraController;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    // await previousCameraController.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        _cameraController = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      pp('$mm cameraController.initialize() ...');
      await cameraController.initialize();
      pp('$mm cameraController.initialized!');
    } on CameraException catch (e) {
      pp('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = _cameraController!.value.isInitialized;
      });
    }
  }

  void startTimer() async {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      duration = Duration(seconds: timer.tick);
      if (timer.tick > maxSeconds) {
        pp('$mm video recording limit reached ... will stop!');
        stopVideoRecording();
        showToast(
            duration: const Duration(seconds: 6),
            padding: 20.0,
            toastGravity: ToastGravity.TOP,
            textStyle: myTextStyleMedium(context),
            message: recordingLimitReached == null
                ? 'Recording limit reached'
                : recordingLimitReached!,
            context: context);
      }
      setState(() {});
    });
  }

  Future<void> startVideoRecording() async {
    pp('$mm .... startVideoRecording ...');
    final CameraController cameraController = _cameraController;
    if (_cameraController.value.isRecordingVideo) {
      pp('$mm A recording has already started, do nothing.');
      return;
    }
    try {
      setState(() {
        _isRecordingInProgress = true;
        isRecording = true;
        _showChoice = false;
        pp('$mm _isRecordingInProgress: $_isRecordingInProgress');
      });
      duration == const Duration(seconds: 0);
      startTimer();
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      pp('Error starting to record video: $e');
    }
  }

  XFile? file;
  String fileSize = '0';
  Future<XFile?> stopVideoRecording() async {
    pp('$mm stopVideoRecording ... 🔴');

    if (!_cameraController!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }
    try {
      file = await _cameraController!.stopVideoRecording();
      timer!.cancel();
      fileSize = getFileSizeString(bytes: await file!.length(), decimals: 2);
      pp('$mm Error stopping video recording, file size: '
          '$fileSize');
      finalDuration = Duration(seconds: duration.inSeconds);
      setState(() {
        _isRecordingInProgress = false;
        isRecording = false;
        duration = const Duration(seconds: 0);
        _showChoice = true;
        pp('$mm setting state:_isRecordingInProgress: $_isRecordingInProgress');
      });

      return file;
    } on CameraException catch (e) {
      pp('$mm Error stopping video recording: $e');
      return null;
    }
  }

  void _processFile() async {
    setState(() {
      _showChoice = false;
    });
    var bytes = await file?.length();
    var size = getFileSizeString(bytes: bytes!, decimals: 2);
    pp('\n\n$mm _processFile ... video file size: $size ');

    final suffix =
        '${widget.vehicle.vehicleId!}_${DateTime.now().millisecondsSinceEpoch}';
    final Directory directory = await getApplicationDocumentsDirectory();
    var x = '/video_$suffix.mp4';
    final File mFile = File('${directory.path}$x');

    var z = '/video_thumbnail_$suffix.jpg';
    final File tFile = File('${directory.path}$z');

    File mImageFile = File(file!.path);
    await mImageFile.copy(mFile.path);
    pp('$mm _processFile 🔵🔵🔵 video file to upload: ${mFile.path}'
        ' size: ${await mFile.length()} bytes 🔵');

    final thumbnailFile0 = await getVideoThumbnail(mImageFile);
    await thumbnailFile0.copy(tFile.path);

    pp('$mm.......... _danceWithTheVideo ... Take Me To Church!!');

    widget.onVideoMade(mFile,tFile);
    cloudStorageBloc.uploadVideo(car: widget.vehicle, file: mFile, thumbnailFile: tFile);

    if (mounted) {
      showToast(
          duration: const Duration(seconds: 3),
          padding: 16,
          textStyle: myTextStyleMediumBold(context),
          toastGravity: ToastGravity.TOP,
          backgroundColor: Theme.of(context).primaryColor,
          message: videoToBeUploaded == null
              ? 'Video will be uploaded soon!'
              : videoToBeUploaded!,
          context: context);
    }
  }

  void pauseVideoRecording() {}
  void resumeVideoRecording() {}

  bool isPlaying = false;
  bool isPaused = false;
  bool isStopped = false;
  bool isRecording = false;

  void onRecord() {
    pp('\n\n$mm onRecord ...calling startVideoRecording ...');
    startVideoRecording();
  }

  void onPlay() {
    //todo - figure out how to play
    pp('$mm onPlay ...figure out how to play ...');
  }

  void onPause() {
    pp('$mm onPause ...figure out how to pause ...');
    pauseVideoRecording();
  }

  void onStop() {
    pp('$mm onPause ...figure out how to stop ...');
    stopVideoRecording();
  }

  @override
  Widget build(BuildContext context) {
    final ori = MediaQuery.of(context).orientation;
    var pad = 200.0;
    var bottomPad = 12.0;
    if (ori.name == 'portrait') {
      pad = 100.0;
      bottomPad = 12.0;
    }
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var color = getTextColorForBackground(Theme.of(context).primaryColor);

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    }
    return ScreenTypeLayout.builder(
      mobile: (ctx) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                title == null ? 'Record Video' : title!,
                style: myTextStyleMediumLargeWithColor(context, color, 24),
              ),
            ),
            body: Stack(
              children: [
                _isCameraInitialized
                    ? _showChoice
                        ? Positioned(
                            top: 120,
                            left: 20,
                            right: 20,
                            child: Card(
                              shape: getDefaultRoundedBorder(),
                              child: SizedBox(
                                height: 400,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      Text(
                                        recordingComplete == null
                                            ? 'Recording complete'
                                            : recordingComplete!,
                                        style: myTextStyleLarge(context),
                                      ),
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(fileSizeText == null
                                              ? 'File Size'
                                              : fileSizeText!),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          Text(
                                            fileSize,
                                            style:
                                                myNumberStyleLargerPrimaryColor(
                                                    context),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(durationText == null
                                              ? 'Duration'
                                              : durationText!),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          Text(
                                            getFormattedTime(
                                                timeInSeconds:
                                                    finalDuration.inSeconds),
                                            style:
                                                myNumberStyleLargerPrimaryColor(
                                                    context),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 28,
                                      ),
                                      VideoRecorderControls(
                                          onUpload: onUpload,
                                          onPlay: onPlay,
                                          onCancel: onCancel),
                                    ],
                                  ),
                                ),
                              ),
                            ))
                        : AspectRatio(
                            aspectRatio:
                                1 / _cameraController.value.aspectRatio,
                            child: _cameraController.buildPreview(),
                          )
                    : Center(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              waitingToRecordVideo == null
                                  ? 'Getting camera ready'
                                  : waitingToRecordVideo!,
                              style: myTextStyleMediumBold(context),
                            ),
                          ),
                        ),
                      ),
                Positioned(
                    right: 48,
                    top: 8,
                    child: Card(
                      shape: getDefaultRoundedBorder(),
                      color: Colors.black12,
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          getFormattedTime(timeInSeconds: duration.inSeconds),
                          style: myTextStyleMediumBoldPrimaryColor(context),
                        ),
                      ),
                    )),
                Positioned(
                    bottom: 20,
                    right: pad,
                    left: pad,
                    child: VideoControls(
                      onRecord: onRecord,
                      onPlay: onPlay,
                      onPause: onPause,
                      onStop: onStop,
                      isPlaying: isPlaying,
                      isPaused: isPaused,
                      isStopped: isStopped,
                      isRecording: isRecording,
                      onClose: () {
                        // widget.onClose();
                      },
                    )),
              ],
            ),
          ),
        );
      },
      tablet: (ctx) {
        return Card(
          elevation: 8,
          shape: getDefaultRoundedBorder(),
          child: SizedBox(
            width: 600,
            height: 600,
            child: Stack(
              children: [
                _isCameraInitialized
                    ? _showChoice
                        ? Positioned(
                            top: 100,
                            left: 20,
                            right: 20,
                            child: SizedBox(
                              height: 360,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  Text(
                                    recordingComplete == null
                                        ? 'Recording complete'
                                        : recordingComplete!,
                                    style: myTextStyleLarge(context),
                                  ),
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(fileSize),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        fileSize,
                                        style: myNumberStyleLargerPrimaryColor(
                                            context),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(durationText == null
                                          ? 'Duration'
                                          : durationText!),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        getFormattedTime(
                                            timeInSeconds:
                                                finalDuration.inSeconds),
                                        style: myNumberStyleLargerPrimaryColor(
                                            context),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 32,
                                  ),
                                  VideoRecorderControls(
                                      onUpload: onUpload,
                                      onPlay: onPlay,
                                      onCancel: onCancel),
                                ],
                              ),
                            ))
                        : SizedBox(
                            width: _cameraController.value.previewSize?.width,
                            height: _cameraController.value.previewSize?.height,
                            child: AspectRatio(
                              aspectRatio: _cameraController.value.aspectRatio,
                              child: _cameraController.buildPreview(),
                            ),
                          )
                    : Center(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              waitingToRecordVideo == null
                                  ? 'Getting camera ready'
                                  : waitingToRecordVideo!,
                              style: myTextStyleMediumBold(context),
                            ),
                          ),
                        ),
                      ),
                Positioned(
                    right: 8,
                    top: 8,
                    child: Card(
                      shape: getDefaultRoundedBorder(),
                      color: Colors.black12,
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              getFormattedTime(
                                  timeInSeconds: duration.inSeconds),
                              style: myNumberStyleMedium(context),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            IconButton(
                                onPressed: () {
                                  //widget.onClose();
                                },
                                icon: const Icon(Icons.close)),
                          ],
                        ),
                      ),
                    )),
                Positioned(
                    bottom: bottomPad,
                    right: pad,
                    left: pad,
                    child: SizedBox(
                      child: VideoControls(
                        onRecord: onRecord,
                        onPlay: onPlay,
                        onPause: onPause,
                        onStop: onStop,
                        isPlaying: isPlaying,
                        isPaused: isPaused,
                        isStopped: isStopped,
                        isRecording: isRecording,
                        onClose: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void onUpload() {
    pp('$mm onUpload tapped');
    _processFile();
  }

  void onCancel() {
    pp('$mm onCancel tapped');
  }
}

class VideoRecorderControls extends StatelessWidget {
  const VideoRecorderControls(
      {Key? key,
      required this.onUpload,
      required this.onPlay,
      required this.onCancel})
      : super(key: key);

  final Function onUpload;
  final Function onPlay;
  final Function onCancel;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 360,
      child: Card(
        elevation: 8,
        shape: getDefaultRoundedBorder(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: () {
                    onUpload();
                  },
                  icon: const Icon(Icons.upload)),
              IconButton(
                  onPressed: () {
                    onPlay();
                  },
                  icon: const Icon(Icons.play_arrow)),
              IconButton(
                  onPressed: () {
                    onCancel();
                  },
                  icon: const Icon(Icons.cancel)),
            ],
          ),
        ),
      ),
    );
  }
}
