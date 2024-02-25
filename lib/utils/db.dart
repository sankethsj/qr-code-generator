// Dart imports:
import "dart:async";

// Package imports:
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

// Project imports:
import "package:qr_code_gen/utils/barcode_decoder.dart";
import "package:qr_code_gen/utils/model.dart";

class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static const _databaseName = "MyQr.db";
  static const _databaseVersion = 2;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Lazily instantiate the db the first time it is accessed.
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database and create the table if it doesn't exist.
  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // SQL string to create the database.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
          CREATE TABLE scan_archive (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            barcode TEXT NOT NULL
          )
          """);
  }

  // SQL string to upgrade the database.
  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute("""
          DROP TABLE scan_archive
          """);
    await _onCreate(db, newVersion);
  }

  // Helper methods
  Future<int> insertScan(ScanArchive scan) async {
    final Database db = await instance.database;
    return await db.insert("scan_archive", scan.toMap());
  }

  Future<List<ScanArchive>> getAllScans() async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      "scan_archive",
      orderBy: "timestamp DESC",
    );

    return List.generate(maps.length, (i) {
      return ScanArchive(
        id: maps[i]["id"] as int?,
        timestamp: maps[i]["timestamp"] as String,
        barcode: decodeBarcode(maps[i]["barcode"] as String),
      );
    });
  }

  // Delete a ScanArchive record by ID
  Future<int> deleteScan(int id) async {
    final Database db = await instance.database;
    return await db.delete(
      "scan_archive",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
