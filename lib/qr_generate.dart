import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QrGenerate extends StatelessWidget {
  const QrGenerate(this.controller, {super.key});

  final TextEditingController controller;

  Widget _showQrCode() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: QrImage(
        data: controller.text,
        size: 320,
        padding: const EdgeInsets.all(10),
      ),
    );
  }

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future createQrFile() async {
    // generate QR code as image
    final qrValidationResult = QrValidator.validate(
      data: controller.text,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    if (qrValidationResult.status != QrValidationStatus.valid) {
      throw Exception(qrValidationResult.error);
    } else {
      final qrCode = qrValidationResult.qrCode!;

      final painter = QrPainter.withQr(
          qr: qrCode,
          color: Colors.black,
          emptyColor: Colors.white,
          gapless: true,
          embeddedImageStyle: null,
          embeddedImage: null);

      final picData =
          await painter.toImageData(2048, format: ImageByteFormat.png);

      // get temporary directory path
      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;

      // save image to temporary directory
      final ts = DateTime.now().millisecondsSinceEpoch.toString();
      final filepath = 'qrcode_$ts.png';
      final path = '$tempPath/$filepath';

      await writeToFile(picData!, path);

      return path;
    }
  }

  Future saveQrCode(context) async {
    String status;
    String message;

    try {
      final qrFilePath = await createQrFile();

      await GallerySaver.saveImage(qrFilePath);

      status = "Success";
      message = "Successfully saved to Gallery";
    } catch (e) {
      status = "Failed";
      message = "Failed to save to Gallery. $e";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            status,
            style: const TextStyle(
              color: Colors.white, // set the text color here
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white, // set the text color here
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white, // set the text color here
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future shareQrCode() async {
    String path = await createQrFile();

    await Share.shareXFiles([XFile(path, mimeType: "image/png")],
        subject: 'Checkout my QR code', text: 'Please scan me');
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
            padding: const EdgeInsets.fromLTRB(0, 100, 0, 30),
            child: _showQrCode(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await saveQrCode(context);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text('Save to Gallery'),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await shareQrCode();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
            ],
          )
        ],
      )),
    );
  }
}
