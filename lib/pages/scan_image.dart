import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:qr_code_gen/pages/scan_result.dart';

class ScanImage extends StatefulWidget {
  const ScanImage({super.key});

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

  Future<void> pickImage(BuildContext context) async {
    try {
      final ctx = context;
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        if (mounted && ctx.mounted) {
          Navigator.of(ctx).pop();
        }
        return;
      }
      final imageTemp = File(image.path);
      if (mounted) {
        setState(() => this.image = imageTemp);
      }
    } on PlatformException catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            content: Text('Failed to pick image: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
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
          content: Text(message),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePreview() {
    return Container(
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
          : const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }

  Widget _buildActionButtons() {
    if (image != null) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => handleOnScan(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_search_rounded),
                  SizedBox(width: 8),
                  Text('Scan this Image'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => pickImage(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library_outlined),
                  SizedBox(width: 8),
                  Text('Choose another Image'),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => pickImage(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_library_outlined),
              SizedBox(width: 8),
              Text('Select an Image'),
            ],
          ),
        ),
      );
    }
  }

  Future<void> handleOnScan(BuildContext context) async {
    final ctx = context;
    final MobileScannerController controller = MobileScannerController();

    try {
      if (image == null) {
        if (mounted && ctx.mounted) {
          showModal("Error", "No image selected");
        }
        return;
      }

      final BarcodeCapture? result = await controller.analyzeImage(image!.path);

      if (result == null || result.barcodes.isEmpty) {
        if (mounted && ctx.mounted) {
          showModal("Invalid Image", "No valid QR Codes found in the image");
        }
        return;
      }

      final barcode = result.barcodes.first;
      final rawValue = barcode.rawValue;

      if (rawValue == null || rawValue.isEmpty) {
        if (mounted && ctx.mounted) {
          showModal("Invalid QR Code", "QR Code content could not be read");
        }
        return;
      }

      if (mounted && ctx.mounted) {
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (context) => ScanResult(
              resultText: rawValue,
              resultFormat: barcode.format,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted && ctx.mounted) {
        showModal("Error", "Failed to scan image: $e");
      }
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Image',
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
                _buildImagePreview(),
                const SizedBox(height: 30),
                _buildActionButtons(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
