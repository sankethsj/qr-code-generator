// Package imports:
import "package:intl/intl.dart";

String getFormattedTimestamp() {
  final now = DateTime.now();
  final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  return formatter.format(now);
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map(
        (MapEntry<String, String> e) =>
            "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}",
      )
      .join("&");
}
