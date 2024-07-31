// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:qr_code_gen/main.dart";
import "package:qr_code_gen/pages/scan_result.dart";
import "package:qr_code_gen/utils/db.dart";
import "package:qr_code_gen/utils/model.dart";

class ScanHistory extends StatefulWidget {
  const ScanHistory({super.key});

  @override
  State<ScanHistory> createState() => ScanHistoryState();
}

class ScanHistoryState extends State<ScanHistory>
    with AutomaticKeepAliveClientMixin<ScanHistory> {
  @override
  bool get wantKeepAlive => true;

  late Future<List<ScanArchive>> scanHistory;
  bool isScanHistoryOn = false;

  @override
  void initState() {
    super.initState();
    loadScans();
  }

  Future<void> loadScans() async {
    final scans = DatabaseHelper.instance.getAllScans();
    setState(() {
      scanHistory = scans;
    });
  }

  Future<void> _deleteScan(int id) async {
    await DatabaseHelper.instance.deleteScan(id);
    loadScans(); // Refresh the list after deletion
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return (prefs.getBool("scanHistory") ?? true)
        ? FutureBuilder<List<ScanArchive>>(
            future: scanHistory,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No scans found."));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemBuilder: (context, index) {
                    final scan = snapshot.data![index];
                    return ScanArchiveListItem(
                      scan: scan,
                      onDelete: (id) {
                        _deleteScan(id);
                      },
                    );
                  },
                );
              }
            },
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Scan history is turned off"),
                const Padding(padding: EdgeInsets.only(top: 8)),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      prefs.setBool("scanHistory", true);
                      loadScans();
                    });
                  },
                  child: const Text("Turn on"),
                ),
              ],
            ),
          );
  }
}

class ScanArchiveListItem extends StatelessWidget {
  final ScanArchive scan;
  final Function(int) onDelete;

  const ScanArchiveListItem({
    super.key,
    required this.scan,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          title: Text(
            scan.barcode.displayValue ?? scan.barcode.rawValue ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Scanned on: ${scan.timestamp}",
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              onDelete(scan.id!);
            },
          ),
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScanResult(
                  barcode: scan.barcode,
                ),
              ),
            ),
          },
        ),
      ),
    );
  }
}
