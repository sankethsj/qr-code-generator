import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QrGenerator extends StatefulWidget {
  const QrGenerator({super.key});

  @override
  QrGeneratorState createState() => QrGeneratorState();
}

class QrGeneratorState extends State<QrGenerator> {
  final TextEditingController _controller = TextEditingController();

  bool _isTextFieldEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isTextFieldEmpty = _controller.text.isEmpty;
      });
    });
  }

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future createQrFile() async {
    // generate QR code as image
    double imageSize = 2048;
    double margin = 50;
    double qrImageSize = imageSize - margin * 2;

    ui.Image qrImage = await QrPainter(
      data: _controller.text,
      gapless: true,
      version: QrVersions.auto,
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Colors.black,
      ),
    ).toImage(qrImageSize);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rect = Rect.fromPoints(Offset.zero, Offset(imageSize, imageSize));
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawRect(rect, paint);

    // Draw the image in the center.
    canvas.drawImage(qrImage, Offset(margin, margin), Paint());
    final image = await recorder
        .endRecording()
        .toImage(imageSize.toInt(), imageSize.toInt());

    ByteData? picData = await image.toByteData(format: ui.ImageByteFormat.png);

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
          ),
          content: Text(
            message,
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
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
    return Container(
        margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 30),
            const Center(
              child: Text(
                "QR Generator",
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 14),
            const Center(
              child: Text(
                "Paste the link below or start typing to dynamically generate QR Codes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _controller,
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 16.0),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColorDark),
                  ),
                  labelText: 'Enter your text',
                  suffixIcon: _isTextFieldEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _controller.clear();
                          },
                        ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ),
            if (!_isTextFieldEmpty) ...[
              const SizedBox(height: 20),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 3.0,
                      color: Theme.of(context).hintColor,
                    ),
                    color: Colors.white,
                  ),
                  child: QrImageView(
                    data: _controller.text,
                    size: 360,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton(
                      style: const ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(10.0)),
                      ),
                      onPressed: () {
                        saveQrCode(context);
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text('Save to Gallery'),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: const ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(10.0)),
                      ),
                      onPressed: () {
                        shareQrCode();
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('Share QR'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ],
        ));
  }
}
