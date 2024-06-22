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

  List<String> findUrls(String text) {
    if (text.startsWith('upi://')) {
      return [text.split(' ')[0]];
    }
    // Regular expression to match URLs
    final urlRegExp = RegExp(
      r'(?:(?:https?|ftp|upi):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
      caseSensitive: false,
    );

    // Find all matches in the text
    final matches = urlRegExp.allMatches(text);

    // Extract the matched URLs into a list
    return matches.map((match) => match.group(0) ?? '').toList();
  }

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

  String _resultType(String text) {
    List links = findUrls(text);

    if (links.isNotEmpty) {
      String firstLink = links[0];
      if (firstLink.startsWith('upi://')) {
        return "UPI";
      } else if (firstLink.startsWith("https://maps.google.com") ||
          firstLink.startsWith("https://www.google.com/maps") ||
          firstLink.startsWith("https://goo.gl/maps") ||
          firstLink.startsWith("https://maps.app.goo.gl")) {
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
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.currency_rupee_rounded),
            SizedBox(width: 8),
            Text('Pay with UPI app'),
          ],
        );
      case "GMAPS":
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_rounded),
            SizedBox(width: 8),
            Text('Navigate to location'),
          ],
        );
      default:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_rounded),
            SizedBox(width: 8),
            Text('Open link in browser'),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    String url = "";
    List links = findUrls(resultText);

    print("links found in text are");
    print(links);
    bool resultContainsLink = links.isNotEmpty;
    if (resultContainsLink) {
      url = links[0];
    }

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
                    'Scan Type :',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(
                      resultFormat,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // color: Theme.of(context).highlightColor,
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
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
                      Text('Copy'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (resultContainsLink) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _launchUrl(url),
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
