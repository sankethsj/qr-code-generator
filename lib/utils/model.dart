// Package imports:
import "package:mobile_scanner/mobile_scanner.dart";

// Project imports:
import "package:qr_code_gen/utils/barcode_encoder.dart";

class ScanArchive {
  int? id;
  late String timestamp;
  late Barcode barcode;

  ScanArchive({this.id, required this.timestamp, required this.barcode});

  // Convert a ScanArchive into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      "id": id,
      "timestamp": timestamp,
      "barcode": encodeBarcode(barcode),
    };
  }

  // Implement toString to make it easier to see information about
  // each ScanArchive when using the print statement.
  @override
  String toString() {
    return "ScanArchive{id: $id, timestamp: $timestamp, barcode: $barcode}";
  }
}
