import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:get_it/get_it.dart';

import '../../../utils/functions.dart';
import 'kasie_ai_scanner.dart';
const String vehicleData =
    '{"vehicleId":"6f74d3e7-06a1-4aa8-b1cf-327e33339f56","countryId":"7a2328bf-915f-4194-82ae-6c220c046cac","ownerName":"Dorianne Jensen-Fred","ownerId":null,"ownerCellphone":null,"created":"2024-10-26T11:31:14.613Z","dateInstalled":null,"vehicleReg":"GCH 58 GP","make":"Toyota","model":"Quantum","year":"2018","qrCodeUrl":"https://storage.googleapis.com/kasie-transie-3.appspot.com/kasie2025_data/The%20Most%20Awesome%20Taxi%20Association/qrCode_4575b7c1-b848-4ad0-b227-9f8392a5c68e.png?GoogleAccessId=firebase-adminsdk-efvna%40kasie-transie-3.iam.gserviceaccount.com&Expires=2678922004&Signature=f%2BKf%2B9OWvpM01%2FmSEfNM%2By6rDwY98J199uwVnwieHV6NFZTAx7psajbqEa7xzYBt5H8IqWp%2F6r%2FQA3UU62OSwr47CZ8BHoYyKeFLAbDtf4W1VpOjQDn7SmsNtQKnduUDqoxfgnmKfi5jaLNxVtLySV8KkSb2vFHB7s2Lh3XxtQAy5KL6cCc5A%2B%2B6RUTzZqkEnOLLVh1EPDEPfJZe%2F4NmVBrLBsY4R6lRXIF6MyXvASueF3mjBmW%2FKBd2XZonTNcWSa4WixA0vSbYT9npcBORy%2BqrzKuAWEeHJzjuxKEwa%2BLAWgycPCsfmrY583MenwFPrhjBZGANJyEP18Nr6nmECA%3D%3D","passengerCapacity":16,"associationId":"2f3faebd-6159-4b03-9857-9dad6d9a82ac","associationName":"The Most Awesome Taxi Association","photos":[],"videos":[]}';

class KasieQRGenerator extends StatefulWidget {
  const KasieQRGenerator(
      {super.key, required this.data, required this.onQRCodeGenerated, required this.title});

  final String data, title;
  final Function(File) onQRCodeGenerated;

  @override
  State<KasieQRGenerator> createState() => _KasieQRGeneratorState();
}

class _KasieQRGeneratorState extends State<KasieQRGenerator> {
  static const mm = '🍞🍞🍞KasieQRGenerator 🍞';
  @override
  void initState() {
    super.initState();
_start();

  }
  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 100));
    getBytes();
  }
  void getBytes() async {
    debugPrint('$mm get bytes ...');
    bytes = await controller.capture();
    if (bytes != null) {
      createFileFromUint8List();
    }
  }

  File? logoFile;
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  Future<File?> createFileFromUint8List() async {
    var fileName = 'file_${DateTime.now().toIso8601String()}.png';
    debugPrint('$mm createFileFromUint8List ... file: $fileName');

    try {
      final directory =
          await getTemporaryDirectory(); // Or getApplicationDocumentsDirectory() for persistent storage
      logoFile = File('${directory.path}/$fileName');
      await logoFile!.writeAsBytes(bytes!);
      debugPrint('$mm file created: ${await logoFile!.length()} bytes. path: ${logoFile?.path}');
      if (logoFile != null) {
        widget.onQRCodeGenerated(logoFile!);
        setState(() {});
      }
      var url = await dataApiDog.uploadQRCodeFile(imageBytes: bytes!, associationId: "ADMIN");
      pp('$mm url: $url');
      return logoFile;
    } catch (e) {
      // Handle exceptions, e.g., log the error or show a message to the user
      debugPrint('Error creating file: $e');
      return null;
    }
  }

  // WidgetsToImageController to access widget
  WidgetsToImageController controller = WidgetsToImageController();

  // to save image bytes of widget
  Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'QRCOde Generator',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
            Padding(padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4), child:   Column(
              children: [
                WidgetsToImage(
                  controller: controller,
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.title,
                        style:  const TextStyle(
                            fontSize: 36,
                            color: Colors.black,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                GestureDetector(
                  onTap: () {
                    getBytes();
                  },
                  child: logoFile == null
                      ? QrImageView(data: widget.data)
                      : QrImageView(
                    data: widget.data,
                    embeddedImage: FileImage(logoFile!),
                    padding: const EdgeInsets.all(16),
                  ),
                )
              ],
            ))
            ],
          ),
        ));
  }
}
