import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:qr_code_gen/pages/scan_image.dart';
import 'package:qr_code_gen/pages/scan_result.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  QrScannerState createState() => QrScannerState();
}

class QrScannerState extends State<QrScanner> {
  late String scanResult;
  late MobileScannerController controller;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      autoZoom: true,
    );
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pause();
    } else if (Platform.isIOS) {
      controller.start();
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
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
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Text('Point your Camera towards a QR code'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller.toggleTorch();
                          setState(() {}); // Add this to rebuild the widget
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              controller.value.torchState == TorchState.on
                                  ? Icons.flashlight_on_rounded
                                  : Icons.flashlight_off_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: () => controller.switchCamera(),
                        child: const Icon(Icons.cameraswitch_rounded),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ScanImage()),
                        );
                      },
                      child: const Text("Select Image"),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return MobileScanner(
      controller: controller,
      overlayBuilder: (context, constraints) => BarcodeOverlay(
        boxFit: BoxFit.cover,
        controller: controller,
        color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
      ),
      onDetect: _onQRViewCreated,
    );
  }

  void _onQRViewCreated(BarcodeCapture capture) {
    controller.stop();

    // Check if barcodes were detected
    if (capture.barcodes.isEmpty) {
      controller.start();
      return;
    }

    final barcode = capture.barcodes.first;
    final rawValue = barcode.rawValue;

    // Check if rawValue is valid
    if (rawValue == null || rawValue.isEmpty) {
      _showError("Invalid QR Code", "Could not read QR code content");
      controller.start();
      return;
    }

    setState(() {
      scanResult = rawValue;
    });

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResult(
            resultText: rawValue,
            resultFormat: barcode.format,
            saveToHistory: true,
          ),
        ),
      ).then((value) => controller.start());
    }
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
