// Dart imports:
import "dart:io";
import "dart:typed_data";
import "dart:ui" as ui;

// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:path_provider/path_provider.dart";
import "package:qr_flutter/qr_flutter.dart";
import "package:share_plus/share_plus.dart";

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
      buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }

  Future<String> createQrFile() async {
    // generate QR code as image
    const double imageSize = 2048;
    const double margin = 50;
    const double qrImageSize = imageSize - margin * 2;

    final ui.Image qrImage = await QrPainter(
      data: _controller.text,
      gapless: true,
      version: QrVersions.auto,
    ).toImage(qrImageSize);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rect =
        Rect.fromPoints(Offset.zero, const Offset(imageSize, imageSize));
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawRect(rect, paint);

    // Draw the image in the center.
    canvas.drawImage(qrImage, const Offset(margin, margin), Paint());
    final image = await recorder
        .endRecording()
        .toImage(imageSize.toInt(), imageSize.toInt());

    final ByteData? picData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    // final qrValidationResult = QrValidator.validate(
    //   data: _controller.text,
    //   version: QrVersions.auto,
    //   errorCorrectionLevel: QrErrorCorrectLevel.L,
    // );

    // if (qrValidationResult.status != QrValidationStatus.valid) {
    //   throw Exception(qrValidationResult.error);
    // } else {
    //   final qrCode = qrValidationResult.qrCode!;

    //   final painter = QrPainter.withQr(
    //       qr: qrCode,
    //       color: Colors.black,
    //       emptyColor: Colors.white,
    //       gapless: true,
    //       embeddedImageStyle: null,
    //       embeddedImage: null);

    //   final picData = await painter.toImageData(
    //     2048,
    //     format: ImageByteFormat.png,
    //   );

    // get temporary directory path
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;

    // save image to temporary directory
    final String ts = DateTime.now().millisecondsSinceEpoch.toString();
    final String filepath = "qrcode_$ts.png";
    final String path = "$tempPath/$filepath";

    await writeToFile(picData!, path);

    return path;
  }

  Future saveQrCode(BuildContext context) async {
    String status;
    String message;

    try {
      //final String qrFilePath = await createQrFile();

      //TODO await GallerySaver.saveImage(qrFilePath);

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
                "OK",
              ),
            ),
          ],
        );
      },
    );
  }

  Future shareQrCode() async {
    final String path = await createQrFile();

    await Share.shareXFiles(
      [XFile(path, mimeType: "image/png")],
      subject: "Checkout my QR code",
      text: "Please scan me",
    );
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
                color: Theme.of(context).primaryColor,
                fontSize: 16.0,
              ),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).primaryColorDark),
                ),
                labelText: "Enter your text",
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
                        Text("Save to Gallery"),
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
                        Text("Share QR"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ],
      ),
    );
  }
}
