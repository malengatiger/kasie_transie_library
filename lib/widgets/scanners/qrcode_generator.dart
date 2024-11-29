import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/widgets/scanners/gen_code.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import '../../data/ticket.dart';
import '../../utils/functions.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;

class QRCodeGenerator extends StatefulWidget {
  const QRCodeGenerator(
      {super.key,
      required this.associationId,
      this.user,
      this.vehicle,
      this.route,
      this.ticket,
      this.routeLandmark, required this.onCodeGenerated});

  final String associationId;
  final User? user;
  final Vehicle? vehicle;
  final lib.Route? route;
  final Ticket? ticket;
  final RouteLandmark? routeLandmark;
  final Function(String) onCodeGenerated;

  @override
  State<QRCodeGenerator> createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {

  @override
  void initState() {
    super.initState();
    _generateQrCode();
  }

  static const mm = '🥦🥦🥦 QRCodeGenerator 🥦🥦';

  Uint8List? fileBytes;

  Future<void> _generateQrCode() async {
    if (widget.user != null) {
      fileBytes = await generateQrCode(data: widget.user!.toJson());
      data = jsonEncode(widget.user!.toJson());
    } else if (widget.vehicle != null) {
      fileBytes = await generateQrCode(data: widget.vehicle!.toJson());
      data = jsonEncode(widget.vehicle!.toJson());

    } else if (widget.route != null) {
      fileBytes = await generateQrCode(data: widget.route!.toJson());
      data = jsonEncode(widget.route!.toJson());

    } else if (widget.routeLandmark != null) {
      fileBytes = await generateQrCode(data: widget.routeLandmark!.toJson());
      data = jsonEncode(widget.routeLandmark!.toJson());

    } else if (widget.ticket != null) {
      fileBytes = await generateQrCode(data: widget.ticket!.toJson());
      data = jsonEncode(widget.ticket!.toJson());

    }
    pp('$mm fileBytes: ${fileBytes!.length}');
    setState(() {});
  }

  DataApiDog dataApi = GetIt.instance<DataApiDog>();

  String? url;
  bool busy = false;

  void _uploadFile() async {
    pp('\n\n$mm _uploadFile starting ...');
    setState(() {
      busy = true;
    });
    try {
      var fileName = 'file_${DateTime.now().millisecondsSinceEpoch}.png';

      url = await dataApi.uploadQRCodeFile(
          imageBytes: fileBytes!, associationId: widget.associationId);
      pp('$mm file upload response: 🍐 $url 🍐');
      if (url != null) {
        widget.onCodeGenerated(url!);
      }
    } catch (e, s) {
      pp('$e\n$s');
      if (mounted) {
        showErrorToast(message: 'Upload fucked! $e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  String data = 'Heita daarso Kasie Transie';
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: SizedBox(
          width: 600,
          height: 600,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "QR Code Generated",
                style: myTextStyle(
                    color: Colors.indigo, fontSize: 28, weight: FontWeight.w900),
              ),
              gapH32,
              QrImageView(
                data: data,
                size: 560,
              ),
              gapH32,
              gapH32,
              ElevatedButton(
                style: const ButtonStyle(
                  elevation: WidgetStatePropertyAll(8.0),
                ),
                onPressed: () {
                  pp('$mm submit clicked, upload the file');
                  _uploadFile();
                },
                child: Text(
                  'Save the Fucking QR Code',
                  style: myTextStyle(color: Colors.indigo),
                ),
              ),
              gapH32,
              url == null
                  ? gapW32
                  : Image.network(
                      url!,
                      height: 400,
                      width: 400,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
