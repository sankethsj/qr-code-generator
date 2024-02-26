// Flutter imports:
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

// Package imports:
import "package:qr_code_scanner/qr_code_scanner.dart";
import "package:url_launcher/url_launcher.dart";

// Project imports:
import "package:qr_code_gen/main.dart";

class ScanResult extends StatefulWidget {
  final BarcodeFormat resultFormat;
  final String resultText;

  const ScanResult({
    super.key,
    required this.resultText,
    required this.resultFormat,
  });

  @override
  ScanResultState createState() => ScanResultState();
}

class ScanResultState extends State<ScanResult> {
  String get resultFormat => widget.resultFormat.formatName;
  late Future<String?> resultTextFuture;
  late String resultText = widget.resultText;

  @override
  void initState() {
    super.initState();

    handleResult();
  }

  Future<void> handleResult() async {
    resultTextFuture = getFinalDestinationUrl(widget.resultText);

    resultTextFuture.then((value) {
      if (value != null) {
        resultText = value;
      }
    });

    if (_textIsLink(resultText) && (prefs.getBool("autoOpenLinks") ?? false)) {
      await _launchUrl(resultText);
    }
  }

  Future<void> _copyToClipboard(String textData) async {
    await Clipboard.setData(ClipboardData(text: textData));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        content: const Text("Copied to clipboard"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri url0 = Uri.parse(url);

    if (!await launchUrl(url0, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url0");
    }
  }

  bool _textIsLink(String text) {
    try {
      return Uri.parse(text).isAbsolute;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getFinalDestinationUrl(String url) async {
    final client = HttpClient();
    final uri = Uri.parse(url);
    final request = await client.getUrl(uri);
    request.followRedirects = false;
    final response = await request.close();
    return response.headers.value(HttpHeaders.locationHeader);
  }

  Future<String> _resultType(String text) async {
    if (_textIsLink(text)) {
      await resultTextFuture;

      if (resultText.startsWith("upi://")) {
        return "UPI";
      } else if (resultText.startsWith("https://maps.google.com") ||
          resultText.startsWith("https://www.google.com/maps") ||
          resultText.startsWith("https://goo.gl/maps") ||
          resultText.startsWith("https://maps.app.goo.gl")) {
        return "GMAPS";
      } else {
        return "URL";
      }
    } else {
      return "TEXT";
    }
  }

  Future<Widget> _myButton(BuildContext context) async {
    switch (await _resultType(resultText)) {
      case "UPI":
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.currency_rupee_rounded),
            SizedBox(width: 8),
            Text("Pay with UPI app"),
          ],
        );
      case "GMAPS":
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_rounded),
            SizedBox(width: 8),
            Text("Navigate to location"),
          ],
        );
      default:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_rounded),
            SizedBox(width: 8),
            Text("Open link in browser"),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan Results",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "Code Type :",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Text(
                    resultFormat,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // color: Theme.of(context).highlightColor,
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: SelectableText(
                resultText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _copyToClipboard(resultText),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded),
                    SizedBox(width: 8),
                    Text("Copy"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_textIsLink(resultText)) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _launchUrl(resultText),
                  child: FutureBuilder(
                    future: _myButton(context),
                    builder: (context, value) {
                      return value.data ?? const Text("Open link in browser");
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
