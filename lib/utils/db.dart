import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:qr_code_gen/utils/model.dart';

class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static const _databaseName = "MyQr.db";
  static const _databaseVersion = 1;

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
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL string to create the database.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE scan_archive (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            scanText TEXT NOT NULL
          )
          ''');
  }

  // Helper methods
  Future<int> insertScan(ScanArchive scan) async {
    Database db = await instance.database;
    return await db.insert('scan_archive', scan.toMap());
  }

  Future<List<ScanArchive>> getAllScans() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scan_archive',
      orderBy: "timestamp DESC",
    );

    return List.generate(maps.length, (i) {
      return ScanArchive(
        id: maps[i]['id'],
        timestamp: maps[i]['timestamp'],
        scanText: maps[i]['scanText'],
      );
    });
  }

  // Delete a ScanArchive record by ID
  Future<int> deleteScan(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'scan_archive',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
