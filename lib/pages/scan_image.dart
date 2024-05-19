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

class ScanImage extends StatefulWidget {
  const ScanImage({super.key});

  @override
  ScanImageState createState() => ScanImageState();
}

class ScanImageState extends State<ScanImage> {
  File? image;
  MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  @override
  void initState() {
    super.initState();
    pickImage();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
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

    if (barcodes != null && barcodes.barcodes.isNotEmpty) {
      if (barcodes.barcodes.first.displayValue?.trim() != "") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResult(
              resultFormat: BarcodeFormat.qrCode,
              resultText:
                  barcodes.barcodes.first.displayValue ?? "No data found!",
            ),
          ),
        );
      } else {
        showModal("Invalid QR Code", "This QR Code doesn't contain any data");
      }
    } else {
      showModal("Invalid Image", "No valid QR Codes found in the image");
    }
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
                      onPressed: pickImage,
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
                      onPressed: pickImage,
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
