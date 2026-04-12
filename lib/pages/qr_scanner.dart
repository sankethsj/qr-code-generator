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
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
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
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              controller.torchEnabled == true
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
                        onPressed: () async {
                          await controller.switchCamera();
                        },
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
    // var scanArea = (MediaQuery.of(context).size.width < 400 ||
    //         MediaQuery.of(context).size.height < 400)
    //     ? 280.0
    //     : 400.0;

    return MobileScanner(
      controller: controller,
      onDetect: _onQRViewCreated,
    );
    // return QRView(
    //   key: qrKey,
    //   onQRViewCreated: _onQRViewCreated,
    //   overlay: QrScannerOverlayShape(
    //       borderColor: Theme.of(context).primaryColor,
    //       borderRadius: 10,
    //       borderLength: 30,
    //       borderWidth: 10,
    //       cutOutSize: scanArea),
    //   onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    // );
  }

  // void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
  //   if (!p) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         margin: const EdgeInsets.fromLTRB(20, 10, 20, 40),
  //         content: const Text('Camera Permission denied'),
  //         behavior: SnackBarBehavior.floating,
  //         backgroundColor: Theme.of(context).primaryColor,
  //       ),
  //     );
  //   }
  // }

  void _onQRViewCreated(BarcodeCapture capture) {
    controller.pause();

    setState(() {
      scanResult = capture.barcodes.first.rawValue!;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanResult(
          resultText: capture.barcodes.first.rawValue!,
          resultFormat: capture.barcodes.first.format,
          saveToHistory: true,
        ),
      ),
    ).then((value) => controller.start());
  }
}
