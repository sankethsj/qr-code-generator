import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_code_gen/utils/model.dart';
import 'package:qr_code_gen/utils/db.dart';
import 'package:qr_code_gen/utils/url_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ScanResult extends StatefulWidget {
  final BarcodeFormat resultFormat;
  final String resultText;
  final bool saveToHistory;

  const ScanResult({
    super.key,
    required this.resultText,
    required this.resultFormat,
    this.saveToHistory = false,
  });

  @override
  ScanResultState createState() => ScanResultState();
}

// Enum to represent the status of each test
enum TestStatus { loading, success, failed }

// Class to hold test result information
class TestResult {
  final String name;
  TestStatus? status;

  TestResult(this.name, this.status);
}

class ScanResultState extends State<ScanResult> {
  get resultFormat => widget.resultFormat.formatName;
  get resultText => widget.resultText;

  // List of test results with test names and their status
  final List<TestResult> _tests = [
    TestResult('DNS Lookup', null),
    TestResult('HTTPS/SSL Check', null),
  ];

  String resultType = "TEXT";

  bool resultContainsLink = false;
  String url = "";
  bool hasInternetConnection = false;
  String domain = "";
  String ipAddress = "";
  String sslIssuer = "";
  String sslValidity = "";

  String getFormattedTimestamp() {
    final now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(now);
  }

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _checkInternetConnectionAndRunTests();
  }

  Future<void> _checkInternetConnectionAndRunTests() async {
    await _checkInternetConnection();
    List links = findUrls(resultText);
    setState(() {
      resultContainsLink = links.isNotEmpty;
    });
    if (resultContainsLink && hasInternetConnection) {
      url = links[0];
      domain = Uri.parse(url).host;
      _runTests(url);
    }
  }

  Future<void> _initializePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool scanHistory = prefs.getBool('scanHistory') ?? false;

    if (scanHistory && widget.saveToHistory) {
      ScanArchive scan =
          ScanArchive(timestamp: getFormattedTimestamp(), scanText: resultText);
      DatabaseHelper.instance.insertScan(scan);
    }
  }

  Future<void> _checkInternetConnection() async {
    List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      setState(() {
        hasInternetConnection = false;
      });
    } else {
      setState(() {
        hasInternetConnection = true;
      });
    }
  }

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

  Future<void> _performAction() async {
    switch (resultType) {
      case "UPI":
        await _launchUrl(resultText);
        break;
      case "GMAPS":
        await _launchUrl(resultText);
        break;
      case "URL":
        await _launchUrl(resultText);
        break;
      case "WIFI":
        // todo
        break;
      default:
        break;
    }
  }

  String _resultType(String text) {
    String tempResultType = "";

    List links = findUrls(text);
    if (links.isNotEmpty) {
      String firstLink = links[0];
      if (firstLink.startsWith('upi://')) {
        tempResultType = "UPI";
      } else if (firstLink.startsWith("https://maps.google.com") ||
          firstLink.startsWith("https://www.google.com/maps") ||
          firstLink.startsWith("https://goo.gl/maps") ||
          firstLink.startsWith("https://maps.app.goo.gl")) {
        tempResultType = "GMAPS";
      } else {
        tempResultType = "URL";
      }
    } else if (text.startsWith('WIFI:')) {
      tempResultType = "WIFI";
    } else {
      tempResultType = "TEXT";
    }
    setState(() {
      resultType = tempResultType;
    });
    return tempResultType;
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
      case "WIFI":
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi),
            SizedBox(width: 8),
            Text('Connect to WiFi'),
          ],
        );
      case "URL":
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_rounded),
            SizedBox(width: 8),
            Text('Open link in browser'),
          ],
        );
      default:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Just text. Nothing fancy.'),
          ],
        );
    }
  }

  Widget _buildTestIcon(TestStatus? status) {
    if (status == TestStatus.loading) {
      return const CircularProgressIndicator(); // Show loading indicator while test is running
    } else if (status == TestStatus.success) {
      return const Icon(Icons.check_circle,
          color: Colors.green); // Green tick for success
    } else if (status == TestStatus.failed) {
      return const Icon(Icons.cancel,
          color: Colors.red); // Red cross for failure
    } else {
      return const Icon(Icons.dangerous,
          color: Colors.red); // Default icon if no status is available
    }
  }

  // Function to run all tests in sequence
  Future<void> _runTests(urlToTest) async {
    // DNS Lookup Test
    setState(() {
      _tests[0].status = TestStatus.loading;
    });
    var dnsResult = await checkDnsResolution(urlToTest);
    setState(() {
      _tests[0].status =
          dnsResult['success'] ? TestStatus.success : TestStatus.failed;
      ipAddress = dnsResult['ip'];
    });

    // HTTPS/SSL Check
    setState(() {
      _tests[1].status = TestStatus.loading;
    });
    var sslResult = await checkSslCertificate(urlToTest);
    setState(() {
      _tests[1].status =
          sslResult['success'] ? TestStatus.success : TestStatus.failed;
      sslIssuer = sslResult['issuer'];
      sslValidity = sslResult['validity'];
    });
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
      body: RefreshIndicator(
        onRefresh: _checkInternetConnectionAndRunTests,
        child: SizedBox(
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
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _performAction(),
                    child: _myButton(context),
                  ),
                ),
                const SizedBox(height: 20),
                if (resultContainsLink) ...[
                  Expanded(
                    child: SizedBox(
                      child: ListView.builder(
                        itemCount: _tests.length,
                        itemBuilder: (context, index) {
                          TestResult test = _tests[index];
                          return ListTile(
                            title: Text(
                              test.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: test.name == 'DNS Lookup'
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Domain:',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      SelectableText(domain),
                                      const Text(
                                        'IP Address:',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      SelectableText(ipAddress),
                                    ],
                                  )
                                : test.name == 'HTTPS/SSL Check'
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'SSL Issuer:',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          SelectableText(sslIssuer),
                                          const Text(
                                            'SSL Validity:',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          SelectableText(sslValidity),
                                        ],
                                      )
                                    : null,
                            trailing: _buildTestIcon(test.status),
                          );
                        },
                      ),
                    ),
                  ),
                  if (!hasInternetConnection)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'To run these tests requires an internet connection.',
                        style: TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
