import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile_scanner/src/mobile_scanner_controller.dart';
import 'package:mobile_scanner/src/mobile_scanner_exception.dart';
import 'package:mobile_scanner/src/mobile_scanner_platform_interface.dart';
import 'package:mobile_scanner/src/objects/barcode_capture.dart';
import 'package:mobile_scanner/src/objects/mobile_scanner_state.dart';
import 'package:mobile_scanner/src/scan_window_calculation.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

import '../../../../utils/functions.dart';
import 'mobile_scanner_one_controller.dart';

/// The function signature for the error builder.
typedef MobileScannerErrorBuilder = Widget Function(
  BuildContext,
  MobileScannerException,
  Widget?,
);

/// This widget displays a live camera preview for the barcode scanner.
class MobileScannerOne extends StatefulWidget {
  /// Create a new [MobileScannerOne] using the provided [controller].
  const MobileScannerOne({
    this.onDetect,
    this.onDetectError = _onDetectErrorHandler,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.overlayBuilder,
    this.placeholderBuilder,
    this.scanWindow,
    this.scanWindowUpdateThreshold = 0.0,
    super.key,
    required this.onScanned,
  });

  /// The controller for the camera preview.
  final Function(BarcodeCapture barcodes) onScanned;

  /// The function that signals when new codes were detected by the [controller].
  ///
  /// To handle both [BarcodeCapture]s and [MobileScannerBarcodeException]s,
  /// use the [MobileScannerController.barcodes] stream directly (recommended),
  /// or provide a function to [onDetectError].
  final void Function(BarcodeCapture barcodes)? onDetect;

  /// The error handler equivalent for the [onDetect] function.
  ///
  /// If [onDetect] is not null, and this is null, errors are silently ignored.
  final void Function(Object error, StackTrace stackTrace) onDetectError;

  /// The error builder for the camera preview.
  ///
  /// If this is null, a black [ColoredBox],
  /// with a centered white [Icons.error] icon is used as error widget.
  final MobileScannerErrorBuilder? errorBuilder;

  /// The [BoxFit] for the camera preview.
  ///
  /// Defaults to [BoxFit.cover].
  final BoxFit fit;

  /// The builder for the overlay above the camera preview.
  ///
  /// The resulting widget can be combined with the [scanWindow] rectangle
  /// to create a cutout for the camera preview.
  ///
  /// The [BoxConstraints] for this builder
  /// are the same constraints that are used to compute the effective [scanWindow].
  ///
  /// The overlay is only displayed when the camera preview is visible.
  final LayoutWidgetBuilder? overlayBuilder;

  /// The placeholder builder for the camera preview.
  ///
  /// If this is null, a black [ColoredBox] is used as placeholder.
  ///
  /// The placeholder is displayed when the camera preview is being initialized.
  final Widget Function(BuildContext, Widget?)? placeholderBuilder;

  /// The scan window rectangle for the barcode scanner.
  ///
  /// If this is not null, the barcode scanner will only scan barcodes
  /// which intersect this rectangle.
  ///
  /// This rectangle is relative to the layout size
  /// of the *camera preview widget* in the widget tree,
  /// rather than the actual size of the camera preview output.
  /// This is because the size of the camera preview widget
  /// might not be the same as the size of the camera output.
  ///
  /// For example, the applied [fit] has an effect on the size of the camera preview widget,
  /// while the camera preview size remains the same.
  ///
  /// The following example shows a scan window that is centered,
  /// fills half the height and one third of the width of the layout:
  ///
  /// ```dart
  /// LayoutBuider(
  ///   builder: (BuildContext context, BoxConstraints constraints) {
  ///     final Size layoutSize = constraints.biggest;
  ///
  ///     final double scanWindowWidth = layoutSize.width / 3;
  ///     final double scanWindowHeight = layoutSize.height / 2;
  ///
  ///     final Rect scanWindow = Rect.fromCenter(
  ///       center: layoutSize.center(Offset.zero),
  ///       width: scanWindowWidth,
  ///       height: scanWindowHeight,
  ///     );
  ///   }
  /// );
  /// ```
  final Rect? scanWindow;

  /// The threshold for updates to the [scanWindow].
  ///
  /// If the [scanWindow] would be updated,
  /// due to new layout constraints for the scanner,
  /// and the width or height of the new scan window have not changed by this threshold,
  /// then the scan window is not updated.
  ///
  /// It is recommended to set this threshold
  /// if scan window updates cause performance issues.
  ///
  /// Defaults to no threshold for scan window updates.
  final double scanWindowUpdateThreshold;

  @override
  State<MobileScannerOne> createState() => _MobileScannerOneState();

  /// This empty function is used as the default error handler for [onDetect].
  static void _onDetectErrorHandler(Object error, StackTrace stackTrace) {
    // Do nothing.
  }
}

class _MobileScannerOneState extends State<MobileScannerOne>
    with WidgetsBindingObserver {
  late final mobileScannerController = MobileScannerOneController(
    autoStart: true,
    formats: [BarcodeFormat.qrCode],
    returnImage: true,
    facing: CameraFacing.back,
  );

  static const mm = '💊💊💊💊MobileScannerOne 💊';

  /// The current scan window.
  Rect? scanWindow;

  /// Calculate the scan window based on the given [constraints].
  ///
  /// If the [scanWindow] is already set, this method does nothing.
  void _maybeUpdateScanWindow(
    MobileScannerState scannerState,
    BoxConstraints constraints,
  ) {
   pp('$mm _maybeUpdateScanWindow , scannerState: ${scannerState.toString()}');
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final center = MediaQuery.sizeOf(context).center(Offset.zero);

    final double scanWindowWidth = width / 3;
    final double scanWindowHeight = height / 2;

    final Rect scanWindow = Rect.fromCenter(
      center: center,
      width: scanWindowWidth,
      height: scanWindowHeight,
    );

    final Rect newScanWindow = calculateScanWindowRelativeToTextureInPercentage(
      widget.fit,
      scanWindow,
      textureSize: scannerState.size,
      widgetSize: constraints.biggest,
    );

    // The scan window was never set before.
    // Set the initial scan window.


      pp('$mm controller.updateScanWindow(scanWindow) ...');
      unawaited(mobileScannerController.updateScanWindow(scanWindow));

    // The scan window did not not change.
    // The left, right, top and bottom are the same.
    if (scanWindow == newScanWindow) {
      return;
    }

    // The update threshold is not set, allow updating the scan window.
    if (widget.scanWindowUpdateThreshold == 0.0) {
      unawaited(mobileScannerController.updateScanWindow(scanWindow));
      return;
    }

    final double dx = (newScanWindow.width - scanWindow!.width).abs();
    final double dy = (newScanWindow.height - scanWindow!.height).abs();

    // The new scan window has changed enough, allow updating the scan window.
    if (dx >= widget.scanWindowUpdateThreshold ||
        dy >= widget.scanWindowUpdateThreshold) {
      unawaited(mobileScannerController.updateScanWindow(scanWindow));
    }
  }

  @override
  Widget build(BuildContext context) {
    pp('$mm build ....');
    return FutureBuilder(
        future: mobileScannerController.start(),
        builder: (ctx, snapShot) {
          return ValueListenableBuilder<MobileScannerState>(
            valueListenable: mobileScannerController,
            builder: (BuildContext context, MobileScannerState scannerState,
                Widget? child) {
              pp('\n\n$mm  ValueListenableBuilder ...');
              pp('$mm  scannerState: size: width: ${scannerState.size.width} height: ${scannerState.size.height}');
              pp('$mm  scannerState: availableCameras: ${scannerState.availableCameras}');
              pp('$mm  scannerState: error: ${scannerState.error}');
              pp('$mm  scannerState: isInitialized: ${scannerState.isInitialized}');
              pp('$mm  scannerState: isRunning: ${scannerState.isRunning}\n\n');

              if (!scannerState.isInitialized) {
                pp('$mm scannerState is not initialized ... ');
                const Widget defaultPlaceholder =
                    ColoredBox(color: Colors.black);
                return widget.placeholderBuilder?.call(context, child) ??
                    defaultPlaceholder;
              }

              final MobileScannerException? error = scannerState.error;

              if (error != null) {
                pp('$mm error is not null ... ');
                const Widget defaultError = ColoredBox(
                  color: Colors.black,
                  child: Center(child: Icon(Icons.error, color: Colors.white)),
                );

                return widget.errorBuilder?.call(context, error, child) ??
                    defaultError;
              }
              pp('$mm error is null ... return LayoutBuilder ');
              return LayoutBuilder(
                builder: (context, constraints) {
                  _maybeUpdateScanWindow(scannerState, constraints);

                  final Widget? overlay =
                      widget.overlayBuilder?.call(context, constraints);
                  final Size cameraPreviewSize = scannerState.size;

                  pp('$mm cameraPreviewSize: width: ${cameraPreviewSize.width} height: ${cameraPreviewSize.height} MobileScannerPlatform.instance.buildCameraView ...');
                  final Widget scannerWidget = ClipRect(
                    child: SizedBox.fromSize(
                      size: constraints.biggest,
                      child: FittedBox(
                        fit: widget.fit,
                        child: SizedBox(
                          width: cameraPreviewSize.width,
                          height: cameraPreviewSize.height,
                          child:
                              MobileScannerPlatform.instance.buildCameraView(),
                        ),
                      ),
                    ),
                  );

                  if (overlay == null) {
                    pp('$mm overlay is null ... returning scannerWidget');
                    return scannerWidget;
                  }

                  pp('$mm return scannerWidget with overlay');
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      scannerWidget,
                      overlay,
                    ],
                  );
                },
              );
            },
          );
        });
  }

  StreamSubscription? _subscription;

  @override
  void initState() {
    pp('$mm initState ....addObserver ...');
    WidgetsBinding.instance.addObserver(this);
    pp('$mm initState ....mobileScannerController.barcodes.listen ...');
    _start();
    super.initState();
    ();
  }

  _start() async {
    pp('$mm _start: 🌀🌀🌀🌀🌀🌀🌀mobileScannerController starting ...');

    _subscription =
        mobileScannerController.barcodes.listen(_handleBarcode, onError: (err) {
      pp('\n\n$mm 😈😈😈 error: $err 😈');
    }, cancelOnError: false);
    await mobileScannerController.start();
    pp('$mm _start: 🌀🌀🌀🌀🌀🌀🌀mobileScannerController started ...');

    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    pp('$mm dispose .... controller.stop() ');
    if (mobileScannerController.autoStart) {
      mobileScannerController.stop();
    }
    // When this widget is unmounted, reset the scan window.
    unawaited(mobileScannerController.updateScanWindow(null));

    // Dispose default controller if not provided by user
    mobileScannerController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  _handleBarcode(BarcodeCapture capture) {
    pp('\n\n$mm ........ _handleBarcode .... ${capture.barcodes.length}');
    pp('$mm _handleBarcode .... ${capture.barcodes.first.rawValue}');

    widget.onDetect!(capture);
    widget.onScanned(capture);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    pp('$mm  🔵🔵🔵🔵🔵didChangeAppLifecycleState .... 🔵 state: ${state.name}');
    if (!mobileScannerController.value.hasCameraPermission) {
      pp('$mm widget.controller != null || !controller.value.hasCameraPermission');
      return;
    }
    switch (state) {
      case AppLifecycleState.detached:
        pp('$mm AppLifecycleState.detached');
        break;
      case AppLifecycleState.hidden:
        pp('$mm AppLifecycleState.hidden');
        break;
      case AppLifecycleState.paused:
        pp('$mm AppLifecycleState.paused');
        return;
      case AppLifecycleState.resumed:
        pp('\n\n$mm AppLifecycleState.resumed, 🍎controller.barcodes.listen ...');
        _subscription = mobileScannerController.barcodes.listen(_handleBarcode,
            onError: (err) {
          pp('\n\n$mm 😈😈😈 error: $err 😈');
        }, cancelOnError: false);
        pp('\n\n$mm unawaited 🍎🍎🍎🍎🍎🍎🍎🍎 controller.start() 🍎🍎');
        unawaited(mobileScannerController.start());
        break;
      case AppLifecycleState.inactive:
        pp('$mm AppLifecycleState.inactive, _subscription?.cancel()');
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(mobileScannerController.stop());
    }
  }
}
