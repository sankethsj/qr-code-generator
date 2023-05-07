import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanResult extends StatefulWidget {
  final BarcodeFormat resultFormat;
  final String resultText;

  const ScanResult({
    Key? key,
    required this.resultText,
    required this.resultFormat,
  }) : super(key: key);

  @override
  ScanResultState createState() => ScanResultState();
}

class ScanResultState extends State<ScanResult> {
  get resultFormat => widget.resultFormat.formatName;
  get resultText => widget.resultText;

  Future<void> _copyToClipboard(textData) async {
    await Clipboard.setData(ClipboardData(text: textData));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        content: const Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri url0 = Uri.parse(url);

    if (!await launchUrl(url0, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url0');
    }
  }

  bool _textIsLink(String text) {
    try {
      return Uri.parse(text).isAbsolute;
    } catch (e) {
      return false;
    }
  }

  String _resultType(String text) {
    if (_textIsLink(text)) {
      if (text.startsWith('upi://')) {
        return "UPI";
      } else if (text.startsWith("https://maps.google.com") ||
          text.startsWith("https://www.google.com/maps") ||
          text.startsWith("https://goo.gl/maps") ||
          text.startsWith("https://maps.app.goo.gl")) {
        return "GMAPS";
      } else {
        return "URL";
      }
    } else {
      return "TEXT";
    }
  }

  Widget _myButton(BuildContext context) {
    switch (_resultType(resultText)) {
      case "UPI":
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.currency_rupee_rounded),
            SizedBox(width: 8),
            Text('Pay with UPI app'),
          ],
        );
      case "GMAPS":
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.map_rounded),
            SizedBox(width: 8),
            Text('Navigate to location'),
          ],
        );
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.link_rounded),
            SizedBox(width: 8),
            Text('Open link in browser'),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Code Type :',
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.copy_rounded),
                      SizedBox(width: 8),
                      Text('Copy'),
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
                    child: _myButton(context),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
