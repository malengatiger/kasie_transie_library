import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
//
import 'package:kasie_transie_library/widgets/scanners/kasie/mlkit/painters/barcode_detector_painter.dart';

import '../../../../../utils/functions.dart';
import 'detector_view.dart';

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({super.key, required this.onScanned});

  final Function(String) onScanned;
  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  static const mm = '🔵🔵🔵🔵 BarcodeScannerView 🔵';
  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Kasie QRcode Scanner',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    pp('$mm ... _processImage : ${inputImage.filePath} ...');

    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final barcodes = await _barcodeScanner.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = BarcodeDetectorPainter(
        barcodes,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
      pp('$mm ... _customPaint size, width: ${_customPaint?.size.width}  height: ${_customPaint?.size.height}...');

    } else {
      String text = 'Barcodes found: ${barcodes.length}\n\n';
      pp('$mm text: $text');
      for (final barcode in barcodes) {
        text += 'Barcode: ${barcode.rawValue}\n\n';
      }
      _text = text;
      _customPaint = null;
      widget.onScanned(text);
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
