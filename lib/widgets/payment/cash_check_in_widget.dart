import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/v4.dart';

import '../../data/commuter_cash_check_in.dart';
import '../../data/data_schemas.dart' as lib;
import '../../data/rank_fee_cash_check_in.dart';
import '../../utils/device_location_bloc.dart';
import '../../utils/prefs.dart';

class CashCheckInWidget extends StatefulWidget {
  const CashCheckInWidget({
    super.key,
    required this.onError,
    this.vehicle,
    this.route,
    required this.isCommuterCash,
    required this.isRankFeeCash,
  });

  final lib.Vehicle? vehicle;
  final lib.Route? route;
  final bool isCommuterCash, isRankFeeCash;
  final Function(String) onError;

  @override
  CashCheckInWidgetState createState() => CashCheckInWidgetState();
}

class CashCheckInWidgetState extends State<CashCheckInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '💙💙💙💙CashCheckInWidget 💙';
  final TextEditingController amountController =
      TextEditingController(text: '0');
  final TextEditingController passengersController = TextEditingController();

  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    if (widget.isRankFeeCash) {
      title = 'Rank Fees Checkin';
    }
    if (widget.isCommuterCash) {
      title = 'Commuter Payments Checkin';
    }
  }

  GlobalKey<FormState> mKey = GlobalKey();
  bool busy = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future _onSubmit() async {
    pp('$mm submit $title ...');
    if (!mKey.currentState!.validate()) {
      return;
    }
    if (imageFile == null) {
      showErrorToast(
          duration: const Duration(seconds: 2),
          message: 'Please take a picture of the receipt before you submit',
          context: context);
      return;
    }
    pp('$mm ............ submitting $title ...');
    var user = prefs.getUser();

    pp('$mm amountController.text: ${amountController.text}');
    var amount = double.parse(amountController.text);
    if (amount <= 0) {
      if (mounted) {
        showErrorToast(
            duration: const Duration(seconds: 2),
            message: 'Please enter an appropriate amount',
            context: context);
        return;
      }
    }
    setState(() {
      busy = true;
    });

    try {
      var url = await dataApiDog.uploadReceipt(
          file: imageFile!, associationId: user!.associationId!);
      if (url == null) {
        throw Exception('receipt photo upload failed');
      }

      pp('$mm receipt url: $url');
      DeviceLocationBloc bloc = GetIt.instance<DeviceLocationBloc>();
      var loc = await bloc.getLocation();
      if (widget.isCommuterCash) {
        var ccp = CommuterCashCheckIn(
            commuterCashCheckInId: const UuidV4().generate().toString(),
            vehicleId: widget.vehicle?.vehicleId,
            vehicleReg: widget.vehicle?.vehicleReg,
            associationId: user.associationId,
            associationName: user.associationName,
            amount: amount,
            userId: user.userId,
            userName: '${user.firstName} ${user.lastName}',
            created: DateTime.now().toUtc().toIso8601String(),
            position: lib.Position(
                coordinates: [loc.longitude, loc.latitude], type: 'Point'),
            receiptUrl: url);
        try {
          var res = await dataApiDog.addCommuterCashCheckIn(ccp);
          pp('$mm $title submitted OK: ${res.toJson()}');
          if (mounted) {
            showOKToast(
                duration: const Duration(seconds: 3),
                toastGravity: ToastGravity.BOTTOM,
                message: '$title submitted OK',
                context: context);
            Navigator.of(context).pop();
          }
        } catch (e) {
          if (mounted) {
            showErrorToast(message: "$title failed: $e", context: context);
          }
        }
      }
      if (widget.isRankFeeCash) {
        var ccp = RankFeeCashCheckIn(
            rankFeeCashCheckInId: const UuidV4().generate().toString(),
            vehicleId: widget.vehicle?.vehicleId,
            vehicleReg: widget.vehicle?.vehicleReg,
            associationId: user!.associationId,
            associationName: user.associationName,
            amount: double.parse(amountController.text),
            userId: user.userId,
            userName: '${user.firstName} ${user.lastName}',
            created: DateTime.now().toUtc().toIso8601String(),
            position: lib.Position(
                coordinates: [loc.longitude, loc.latitude], type: 'Point'),
            receiptUrl: url);
        try {
          var res = await dataApiDog.addRankFeeCashCheckIn(ccp);
          pp('$mm $title submitted OK: ${res.toJson()}');
          if (mounted) {
            showOKToast(
                duration: const Duration(seconds: 3),
                toastGravity: ToastGravity.BOTTOM,
                message: '$title submitted OK',
                context: context);
            Navigator.of(context).pop();
          }
        } catch (e) {
          if (mounted) {
            showErrorToast(message: "$title failed: $e", context: context);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorToast(message: "$title failed: $e", context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  void _onReceiptPhoto() async {
    pp('\n\n$mm .....photo taking started ....');

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
  NativeDeviceOrientation? _deviceOrientation;

  Future<void> _processFile(XFile file) async {
    pp('$mm _processFile 🔵🔵🔵 file to upload, '
        'size: ${await file.length()} bytes 🔵');

    //
    bool isLandscape = false;

    pp('$mm ... isLandscape: $isLandscape - check if true!  🍎');
    final suffix = '${DateTime.now().millisecondsSinceEpoch}.jpg';

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
      pp('$mm ... mFile: ${await mFile.length()} bytes,  🍎');
      // pp('$mm ... thumb: ${await thumb?.length()} bytes,  🍎');

      setState(() {
        imageFile = mFile;
        // thumbFile = thumb;
      });

      var size = await mFile.length();
      var m = (size / 1024 / 1024).toStringAsFixed(2);
      pp('$mm Picture taken is $m MB in size');

      if (mounted) {
        showToast(
            context: context,
            message: 'Picture file saved on device, size: $m MB',
            backgroundColor: Colors.black,
            textStyle: myTextStyle(color: Colors.white),
            toastGravity: ToastGravity.TOP,
            duration: const Duration(seconds: 2));
      }
    } catch (e, s) {
      pp('$e $s');
    }
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

  String title = 'Cash CheckIn';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CashCheckInForm(
                      globalKey: mKey,
                      amountController: amountController,
                      imageFile: imageFile,
                      onSubmit: () {
                        _onSubmit();
                      },
                      onReceiptPhoto: () {
                        _onReceiptPhoto();
                      },
                    ),
                    gapH32,
                    imageFile == null
                        ? gapW32
                        : Expanded(
                            child: SizedBox(
                                width: 300,
                                child: Image.file(imageFile!,
                                    fit: BoxFit.cover,
                                    height: 300,
                                    width: 300))),
                  ],
                ),
              ),
              busy
                  ? Positioned(
                      child: Center(
                      child: TimerWidget(
                          title: 'Saving $title', isSmallSize: true),
                    ))
                  : gapH32,
            ],
          ),
        ));
  }
}

class CashCheckInForm extends StatelessWidget {
  const CashCheckInForm(
      {super.key,
      required this.globalKey,
      required this.amountController,
      required this.onSubmit,
      required this.onReceiptPhoto,
      this.imageFile});

  final GlobalKey<FormState> globalKey;
  final TextEditingController amountController;
  final Function onSubmit;
  final Function onReceiptPhoto;
  final File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: globalKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          gapH32,
          Text(
            'Cash CheckIn',
            style: myTextStyleMediumLarge(context, 24),
          ),
          gapH32,
          TextFormField(
            keyboardType: TextInputType.number,
            controller: amountController,
            style: myTextStyleMediumLarge(context, 36),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter Amount",
              label: Text('Cash CheckIn Amount'),
            ),
            validator: (value) {
              if (value == null) {
                return 'Please enter Cash CheckIn Amount';
              }
              return null;
            },
          ),
          gapH32,
          SizedBox(
              width: 300,
              child: ElevatedButton(
                style: const ButtonStyle(
                    elevation: WidgetStatePropertyAll(8),
                    padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
                    backgroundColor: WidgetStatePropertyAll(Colors.grey)),
                onPressed: () {
                  onReceiptPhoto();
                },
                child: Text('Take Receipt Photo',
                    style: myTextStyle(color: Colors.white)),
              )),
          gapH32,
          imageFile == null
              ? gapW32
              : SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                        elevation: WidgetStatePropertyAll(8),
                        padding: WidgetStatePropertyAll(EdgeInsets.all(16)),
                        backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                    onPressed: () {
                      onSubmit();
                    },
                    child:
                        Text('Submit', style: myTextStyle(color: Colors.white)),
                  ),
                ),
        ],
      ),
    );
  }
}
