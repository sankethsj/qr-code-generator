// Dart imports:
import "dart:io";

// Flutter imports:
import "package:flutter/material.dart";
import "package:flutter/services.dart";

// Package imports:
import "package:image_picker/image_picker.dart";
import "package:mobile_scanner/mobile_scanner.dart";

// Project imports:
import "package:qr_code_gen/pages/scan_result.dart";
import "package:qr_code_gen/utils/db.dart";
import "package:qr_code_gen/utils/model.dart";
import "package:qr_code_gen/utils/utils.dart";

class ScanImage extends StatefulWidget {
  const ScanImage({super.key});

  @override
  ScanImageState createState() => ScanImageState();
}

class ScanImageState extends State<ScanImage> {
  File? image;
  MobileScannerController controller = MobileScannerController();

  @override
  void initState() {
    super.initState();
    pickImage(context);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          content: Text("Failed to pick image: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).primaryColor,
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
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "CLOSE",
              ),
            ),
          ],
        );
      },
    );
  }

  Future handleOnScan(BuildContext context) async {
    final BarcodeCapture? barcodes = await controller.analyzeImage(
      image!.path,
    );

    if (barcodes == null || barcodes.barcodes.isEmpty) {
      showModal("Invalid Image", "No valid QR Codes found in the image");
      return;
    }

    final Barcode result = barcodes.barcodes.first;

    final ScanArchive scan =
        ScanArchive(timestamp: getFormattedTimestamp(), barcode: result);
    DatabaseHelper.instance.insertScan(scan);

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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: image != null
                      ? Image.file(
                          image!,
                          fit: BoxFit.cover,
                        )
                      : const CircularProgressIndicator(),
                ),
                const SizedBox(height: 30),
                if (image != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => handleOnScan(context),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_search_rounded),
                          SizedBox(width: 8),
                          Text("Scan this Image"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => pickImage(context),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_library_outlined),
                          SizedBox(width: 8),
                          Text("Choose another Image"),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => pickImage(context),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_library_outlined),
                          SizedBox(width: 8),
                          Text("Select an Image"),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
