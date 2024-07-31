// Dart imports:
import "dart:async";

// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:mobile_scanner/mobile_scanner.dart";

// Project imports:
import "package:qr_code_gen/main.dart";
import "package:qr_code_gen/pages/mobile_scanner_overlay.dart";
import "package:qr_code_gen/pages/scan_history.dart";
import "package:qr_code_gen/pages/scan_image.dart";
import "package:qr_code_gen/pages/scan_result.dart";
import "package:qr_code_gen/pages/scanner_error_widget.dart";
import "package:qr_code_gen/utils/db.dart";
import "package:qr_code_gen/utils/model.dart";
import "package:qr_code_gen/utils/utils.dart";

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  QrScannerState createState() => QrScannerState();
}

class QrScannerState extends State<QrScanner>
    with WidgetsBindingObserver, RouteAware {
  final GlobalKey qrKey = GlobalKey(debugLabel: "QR");
  final MobileScannerController controller = MobileScannerController(
    useNewCameraSelector: true,
  );
  bool covered = false;

  StreamSubscription<Object?>? _subscription;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        if (covered) return;
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        _subscription = controller.barcodes.listen(_handleBarcode);
        unawaited(controller.start());
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register this route observer
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void initState() {
    super.initState();
    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    // Start listening to the barcode events.
    _subscription = controller.barcodes.listen(_handleBarcode);

    // Finally, start the scanner itself.
    unawaited(controller.start());
  }

  @override
  Future<void> dispose() async {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    unawaited(_subscription?.cancel());
    _subscription = null;
    // Dispose the widget itself.
    super.dispose();
    // Finally, dispose of the controller.
    await controller.dispose();

    // Unsubscribe when the widget is disposed
    routeObserver.unsubscribe(this);
  }

  @override
  void didPopNext() {
    covered = false;
    _subscription = controller.barcodes.listen(_handleBarcode);
    controller.start();
  }

  @override
  void didPushNext() {
    covered = true;
    unawaited(_subscription?.cancel());
    _subscription = null;
    controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: _buildQrView(context),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Text("Point your Camera towards a QR code"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        if (controller.value.cameraDirection ==
                            CameraFacing.front) return;

                        await controller.toggleTorch();
                        setState(() {});
                      },
                      child: Icon(
                        controller.value.torchState == TorchState.on
                            ? Icons.flashlight_on_rounded
                            : Icons.flashlight_off_rounded,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.switchCamera();
                        setState(() {});
                      },
                      child: const Icon(Icons.cameraswitch_rounded),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScanImage(
                              controller: controller,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.image_rounded),
                      label: const Text("Select Image"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (barcodes.barcodes.isEmpty) return;

    final Barcode result = barcodes.barcodes.first;

    final ScanArchive scan =
        ScanArchive(timestamp: getFormattedTimestamp(), barcode: result);
    DatabaseHelper.instance.insertScan(scan).then(
          (_) =>
              (scanHistoryKey.currentState as ScanHistoryState?)?.loadScans(),
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanResult(
          barcode: result,
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    final windowSize = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 450.0;
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(const Offset(0, -100)),
      width: windowSize,
      height: windowSize,
    );
    final overlaySize = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 350.0;
    final overlayWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(const Offset(0, -100)),
      width: overlaySize,
      height: overlaySize,
    );

    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          scanWindow: scanWindow,
          errorBuilder: (context, error, child) {
            return ScannerErrorWidget(error: error);
          },
          fit: BoxFit.fitHeight,
        ),
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, child) {
            if (!value.isInitialized ||
                !value.isRunning ||
                value.error != null) {
              return Container();
            }

            return CustomPaint(
              painter: ScannerOverlay(scanWindow: overlayWindow),
            );
          },
        ),
      ],
    );
  }
}
