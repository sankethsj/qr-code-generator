// Flutter imports:
import "package:flutter/material.dart";
import "package:flutter/services.dart";

// Package imports:
import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:mobile_scanner/mobile_scanner.dart";
import "package:url_launcher/url_launcher.dart";
import "package:wifi_iot/wifi_iot.dart";

// Project imports:
import "package:qr_code_gen/main.dart";
import "package:qr_code_gen/utils/utils.dart";

class ScanResult extends StatefulWidget {
  final Barcode barcode;

  const ScanResult({
    super.key,
    required this.barcode,
  });

  @override
  ScanResultState createState() => ScanResultState();
}

class ScanResultState extends State<ScanResult> {
  @override
  void initState() {
    super.initState();

    handleResult();
  }

  void handleResult() {
    if (widget.barcode.type == BarcodeType.url &&
        widget.barcode.url != null &&
        (prefs.getBool("autoOpenLinks") ?? false)) {
      launchUrl(
        Uri.parse(widget.barcode.url!.url),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> _copyToClipboard(String textData) async {
    await Clipboard.setData(ClipboardData(text: textData));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Copied to clipboard"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget? _actionButton(BuildContext context) {
    switch (widget.barcode.type) {
      case BarcodeType.url:
        return FilledButton.icon(
          onPressed: () => launchUrl(
            Uri.parse(widget.barcode.url!.url),
            mode: LaunchMode.externalApplication,
          ),
          icon: const Icon(Icons.link_rounded),
          label: const Text("Open link in browser"),
        );
      case BarcodeType.wifi:
        //TODO Intermittenly not working
        return FilledButton.icon(
          onPressed: () {
            print("Connecting to WiFi");

            final WiFi? wifi = widget.barcode.wifi;

            if (wifi == null || wifi.ssid == null) return;

            if (wifi.password == null ||
                wifi.password == "" ||
                wifi.encryptionType == EncryptionType.none ||
                wifi.encryptionType == EncryptionType.open) {
              WiFiForIoTPlugin.registerWifiNetwork(wifi.ssid!);
              return;
            } else {
              NetworkSecurity security = NetworkSecurity.NONE;
              if (wifi.encryptionType == EncryptionType.wep) {
                security = NetworkSecurity.WEP;
              } else if (wifi.encryptionType == EncryptionType.wpa) {
                security = NetworkSecurity.WPA;
              }

              WiFiForIoTPlugin.registerWifiNetwork(
                wifi.ssid!,
                password: wifi.password,
                security: security,
              );
            }
          },
          icon: const Icon(Icons.wifi_rounded),
          label: const Text("Connect to WiFi"),
        );
      case BarcodeType.email:
        return FilledButton.icon(
          onPressed: () {
            final Email? email = widget.barcode.email;

            if (email != null) {
              // Replace spaces with '%20' for subject and body
              final String subject = email.subject ?? "";
              final String body = email.body ?? "";

              final Uri emailUri = Uri(
                scheme: "mailto",
                path: email.address,
                query: encodeQueryParameters(<String, String>{
                  "subject": subject,
                  "body": body,
                }),
              );
              launchUrl(emailUri, mode: LaunchMode.externalApplication);
            }
          },
          icon: const Icon(Icons.email_rounded),
          label: const Text("Send email"),
        );
      case BarcodeType.phone:
        return FilledButton.icon(
          onPressed: () {
            final Phone? phone = widget.barcode.phone;

            if (phone != null) {
              launchUrl(
                Uri(scheme: "tel", path: phone.number),
                mode: LaunchMode.externalApplication,
              );
            }
          },
          icon: const Icon(Icons.phone_rounded),
          label: const Text("Call number"),
        );
      case BarcodeType.sms:
        return FilledButton.icon(
          onPressed: () {
            final SMS? sms = widget.barcode.sms;

            if (sms != null) {
              launchUrl(
                Uri(
                  scheme: "sms",
                  path: sms.phoneNumber,
                  queryParameters: {"body": sms.message},
                ),
                mode: LaunchMode.externalApplication,
              );
            }
          },
          icon: const Icon(Icons.sms_rounded),
          label: const Text("Send SMS"),
        );
      case BarcodeType.geo:
        return FilledButton.icon(
          onPressed: () {
            final GeoPoint? geoPoint = widget.barcode.geoPoint;

            if (geoPoint != null) {
              launchUrl(
                Uri(
                  scheme: "geo",
                  queryParameters: {
                    "q": "${geoPoint.latitude},${geoPoint.longitude}",
                  },
                ),
                mode: LaunchMode.externalApplication,
              );
            }
          },
          icon: const Icon(Icons.location_on_rounded),
          label: const Text("Open in Maps"),
        );
      case BarcodeType.contactInfo:
        //TODO Not working
        return FilledButton.icon(
          onPressed: () {
            final ContactInfo? contactInfo = widget.barcode.contactInfo;

            if (contactInfo != null) {
              final Uri contactUri = Uri(
                scheme: "content",
                path: "contacts",
                queryParameters: {
                  "name": contactInfo.name,
                  "phone": contactInfo.phones.join(","),
                  "email": contactInfo.emails.join(","),
                },
              );
              launchUrl(contactUri, mode: LaunchMode.externalApplication);
            }
          },
          icon: const Icon(Icons.contact_page_rounded),
          label: const Text("Add to Contacts"),
        );
      case BarcodeType.calendarEvent:
        //TODO undefined
        return FilledButton.icon(
          onPressed: () {
            final CalendarEvent? calendarEvent = widget.barcode.calendarEvent;

            if (calendarEvent != null) {
              final Uri calendarUri = Uri(
                scheme: "content",
                path: "calendar",
                queryParameters: {
                  "title": calendarEvent.summary,
                  "description": calendarEvent.description,
                  "location": calendarEvent.location,
                  "start": calendarEvent.start?.toIso8601String(),
                  "end": calendarEvent.end?.toIso8601String(),
                },
              );
              launchUrl(calendarUri, mode: LaunchMode.externalApplication);
            }
          },
          icon: const Icon(Icons.calendar_today_rounded),
          label: const Text("Add to Calendar"),
        );
      case BarcodeType.text:
      default:
        return null;
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
      body: SingleChildScrollView(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        "Code Format:",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Text(
                          widget.barcode.format.name.capitalize,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        "Data type:",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Text(
                          widget.barcode.type.name.capitalize,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // color: Theme.of(context).highlightColor,
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    child: SelectableText(
                      widget.barcode.displayValue ??
                          widget.barcode.rawValue ??
                          "No data found",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 8)),
                if (_actionButton(context) != null) ...[
                  _actionButton(context)!,
                ],
                FilledButton.icon(
                  onPressed: () => _copyToClipboard(
                    widget.barcode.displayValue ??
                        widget.barcode.rawValue ??
                        "",
                  ),
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text("Copy"),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text("Scan again"),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
