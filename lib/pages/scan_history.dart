import 'package:flutter/material.dart';
import 'package:qr_code_gen/pages/scan_result.dart';
import 'package:qr_code_gen/utils/model.dart';
import 'package:qr_code_gen/utils/db.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanHistory extends StatefulWidget {
  const ScanHistory({super.key});

  @override
  State<ScanHistory> createState() => _ScanHistoryState();
}

class _ScanHistoryState extends State<ScanHistory> {
  late Future<List<ScanArchive>> scanHistory;
  final Set<int> _selectedScans = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  Future<void> _loadScans() async {
    final scans = DatabaseHelper.instance.getAllScans();
    setState(() {
      scanHistory = scans;
    });
  }

  Future<void> _deleteSelectedScans() async {
    for (int id in _selectedScans) {
      await DatabaseHelper.instance.deleteScan(id);
    }
    _selectedScans.clear();
    _loadScans(); // Refresh the list after deletion
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        scanHistory.then((scans) {
          _selectedScans.addAll(scans.map((scan) => scan.id!));
        });
      } else {
        _selectedScans.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: _toggleSelectAll,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _selectedScans.isEmpty ? null : _deleteSelectedScans,
          ),
        ],
      ),
      body: FutureBuilder<List<ScanArchive>>(
        future: scanHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No scans found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final scan = snapshot.data![index];
                final isSelected = _selectedScans.contains(scan.id);
                return ScanArchiveListItem(
                  scan: scan,
                  isSelected: isSelected,
                  onSelect: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedScans.add(scan.id!);
                      } else {
                        _selectedScans.remove(scan.id);
                      }
                    });
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ScanArchiveListItem extends StatelessWidget {
  final ScanArchive scan;
  final bool isSelected;
  final Function(bool) onSelect;

  const ScanArchiveListItem({
    super.key,
    required this.scan,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Checkbox(
            value: isSelected,
            onChanged: (selected) => onSelect(selected!),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          title: Text(
            scan.scanText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
            child: Text(
              'Scanned on: ${scan.timestamp}',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12,
                color: Colors.grey
              ),
            ),
          ),
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScanResult(
                  resultText: scan.scanText,
                  resultFormat: BarcodeFormat.qrcode,
                ),
              ),
            )
          },
        ),
      ),
    );
  }
}
