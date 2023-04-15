import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class QrGenerate extends StatelessWidget {
  const QrGenerate(this.controller, {super.key});

  final TextEditingController controller;

  Widget _generateQrCode() {
    return QrImage(
      data: controller.text,
      size: 320,
      // You can include embeddedImageStyle Property if you
      //wanna embed an image from your Asset folder
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: const Size(
          100,
          100,
        ),
      ),
    );
  }

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<bool> saveQrCode() async {
    final qrValidationResult = QrValidator.validate(
      data: controller.text,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: const Color(0xFF000000),
        gapless: true,
        embeddedImageStyle: null,
        embeddedImage: null,
      );

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      final ts = DateTime.now().millisecondsSinceEpoch.toString();
      String path = '$tempPath/$ts.png';

      final picData =
          await painter.toImageData(2048, format: ImageByteFormat.png);
      await writeToFile(picData!, path);

      await GallerySaver.saveImage(path);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (controller.text == "") {
      return Scaffold(
          appBar: AppBar(
            title: const Text('QR code failed'),
            centerTitle: true,
          ),
          body: const Center(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Cannot generate QR code without text!',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )),
          ));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR code generated'),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 150, 0, 30),
            child: _generateQrCode(),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // generate QR code as image
                final image = await QrPainter(
                  data: controller.text,
                  version: QrVersions.auto,
                  gapless: false,
                  color: Colors.black,
                  emptyColor: Colors.white,
                ).toImage(400);

                // convert image to byte data
                final byteData =
                    await image.toByteData(format: ImageByteFormat.png);
                final pngBytes = byteData!.buffer.asUint8List();

                // get temporary directory path
                final tempDir = await getTemporaryDirectory();
                final tempPath = tempDir.path;

                // save image to temporary directory
                final ts = DateTime.now().millisecondsSinceEpoch.toString();
                final imgFile = await File('$tempPath/qrcode_$ts.png')
                    .writeAsBytes(pngBytes);

                // save image to gallery
                final result = await GallerySaver.saveImage(imgFile.path);
                print('Image saved to gallery: $result');
              } catch (e) {
                print('Failed to save image to gallery: $e');
              }
            },
            child: const Text('Save to Gallery'),
          ),
        ],
      )),
    );
  }
}
