import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../utils/functions.dart';
import '../../scanner_four.dart';

class BarcodeScannerReturningImage extends StatefulWidget {
  const BarcodeScannerReturningImage({super.key, required this.onScanned});

  final Function(String) onScanned;
  @override
  State<BarcodeScannerReturningImage> createState() =>
      _BarcodeScannerReturningImageState();
}

class _BarcodeScannerReturningImageState
    extends State<BarcodeScannerReturningImage> {
  final MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
    returnImage: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Returning image')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<BarcodeCapture>(
                stream: controller.barcodes,
                builder: (context, snapshot) {
                  final barcode = snapshot.data;

                  if (barcode == null) {
                    return const Center(
                      child: Text(
                        'Your scanned barcode will appear here!',
                      ),
                    );
                  }

                  final barcodeImage = barcode.image;

                  if (barcodeImage == null) {
                    return const Center(
                      child: Text('No image for this barcode.'),
                    );
                  }
                  widget.onScanned(barcodeImage.toString());
                  return Image.memory(
                    barcodeImage,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text('Could not decode image bytes. $error'),
                      );
                    },
                    frameBuilder: (
                        BuildContext context,
                        Widget child,
                        int? frame,
                        bool? wasSynchronouslyLoaded,
                        ) {
                      if (wasSynchronouslyLoaded == true || frame != null) {
                        return Transform.rotate(
                          angle: 90 * pi / 180,
                          child: child,
                        );
                      }

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: ColoredBox(
                color: Colors.grey,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: controller,
                      errorBuilder: (context, error, child) {
                        return ScannerErrorWidget(error: error);
                      },
                      fit: BoxFit.contain,
                      onDetect: (cap){
                        pp('$cap');
                      },
                    ),
                                     ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await controller.dispose();
  }
}
