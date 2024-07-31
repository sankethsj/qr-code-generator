// Dart imports:
import "dart:io";

// Flutter imports:
import "package:flutter/material.dart";
import "package:flutter/services.dart";

// Package imports:
import "package:image_picker/image_picker.dart";
import "package:mobile_scanner/mobile_scanner.dart";

// Project imports:
import "package:qr_code_gen/main.dart";
import "package:qr_code_gen/pages/scan_history.dart";
import "package:qr_code_gen/pages/scan_result.dart";
import "package:qr_code_gen/utils/db.dart";
import "package:qr_code_gen/utils/model.dart";
import "package:qr_code_gen/utils/utils.dart";

class ScanImage extends StatefulWidget {
  final MobileScannerController controller;

  const ScanImage({
    super.key,
    required this.controller,
  });

  @override
  ScanImageState createState() => ScanImageState();
}

class ScanImageState extends State<ScanImage> {
  File? image;

  @override
  void initState() {
    super.initState();
    pickImage(context);
  }

  Future pickImage(BuildContext context) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        return;
      }
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to pick image: $e"),
        ),
      );
    }
  }

  void showModal(String heading, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            heading,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            message,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Close",
              ),
            ),
          ],
        );
      },
    );
  }

  Future handleOnScan(BuildContext context) async {
    final BarcodeCapture? barcodes = await widget.controller.analyzeImage(
      image!.path,
    );

    if (barcodes == null || barcodes.barcodes.isEmpty) {
      showModal("Invalid Image", "No valid QR Codes found in the image");
      return;
    }

    final Barcode result = barcodes.barcodes.first;

    final ScanArchive scan =
        ScanArchive(timestamp: getFormattedTimestamp(), barcode: result);
    DatabaseHelper.instance.insertScan(scan).then(
          (_) =>
              (scanHistoryKey.currentState as ScanHistoryState?)?.loadScans(),
        );

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanResult(
          barcode: result,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan Image",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: image != null
                        ? Image.file(
                            image!,
                            fit: BoxFit.cover,
                          )
                        : const CircularProgressIndicator(),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 16)),
                  if (image != null) ...[
                    FilledButton.icon(
                      onPressed: () => handleOnScan(context),
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text("Scan Image"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => pickImage(context),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text("Choose another Image"),
                    ),
                  ] else ...[
                    FilledButton.icon(
                      onPressed: () => pickImage(context),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text("Select an Image"),
                    ),
                  ],
                  const Padding(padding: EdgeInsets.only(bottom: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
