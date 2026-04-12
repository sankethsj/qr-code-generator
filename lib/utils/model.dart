class ScanArchive {
  int? id;
  late String timestamp;
  late String scanText;
  late int scanType;

  ScanArchive(
      {this.id,
      required this.timestamp,
      required this.scanText,
      this.scanType = -1});

  // Convert a ScanArchive into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'scanText': scanText,
      'scanType': scanType,
    };
  }

  // Implement toString to make it easier to see information about
  // each ScanArchive when using the print statement.
  @override
  String toString() {
    return 'ScanArchive{id: $id, timestamp: $timestamp, scanText: $scanText, scanType: $scanType}';
  }
}
