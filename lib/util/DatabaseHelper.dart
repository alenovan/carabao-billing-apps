import 'package:carabaobillingapps/service/models/order/ResponseListOrdersModels.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const int DATABASE_VERSION = 2; // Increased version number

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'orders.db');
    return await openDatabase(
      path,
      version: DATABASE_VERSION,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE orders (
        room_id INTEGER PRIMARY KEY,
        code TEXT,
        multiple_channel TEXT,
        is_multiple_channel INTEGER,
        name TEXT,
        status_rooms INTEGER,
        status_order TEXT,
        type TEXT,
        ip TEXT,
        secret TEXT,
        id INTEGER,
        newest_order_start_time TEXT,
        newest_order_end_time TEXT
      )
    ''');
    await _createLogsTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      await _createLogsTable(db);
    }
  }

  Future<void> _createLogsTable(Database db) async {
    await db.execute('''
      CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message TEXT,
        type TEXT,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        severity TEXT DEFAULT 'INFO',
        additional_data TEXT
      )
    ''');

    await db.insert('logs', {
      'message': 'Logs table created',
      'type': 'SYSTEM',
      'severity': 'INFO',
      'additional_data': json.encode({'database_version': DATABASE_VERSION})
    });
  }

  Future<void> insertOrder(NewestOrder order) async {
    final db = await database;
    await db.insert(
      'orders',
      order.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NewestOrder>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('orders');
    return List.generate(maps.length, (i) {
      return NewestOrder.fromJson(maps[i]);
    });
  }

  Future<void> clearOrders() async {
    final db = await database;
    await db.delete('orders');
  }

  Future<List<NewestOrder>> getActiveOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'status_rooms = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return NewestOrder.fromJson(maps[i]);
    });
  }

  Future<void> insertLog(String message, String type,
      {String severity = 'INFO', Map<String, dynamic>? additionalData}) async {
    final db = await database;
    await db.insert('logs', {
      'message': message,
      'type': type,
      'severity': severity,
      'additional_data':
          additionalData != null ? json.encode(additionalData) : null,
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  Future<List<Map<String, dynamic>>> getLogs(
      {int limit = 100, int offset = 0, String? type, String? severity}) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (type != null) {
      whereClause += 'type = ?';
      whereArgs.add(type);
    }

    if (severity != null) {
      whereClause += whereClause.isEmpty ? 'severity = ?' : ' AND severity = ?';
      whereArgs.add(severity);
    }

    return await db.query(
      'logs',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<void> cleanupOldLogs({int daysToKeep = 30}) async {
    final db = await database;
    final cutoffDate =
        DateTime.now().subtract(Duration(days: daysToKeep)).toIso8601String();

    await db.delete(
      'logs',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate],
    );
  }

  Future<int> getDatabaseVersion() async {
    final db = await database;
    final result = await db.rawQuery('PRAGMA user_version');
    return result.first['user_version'] as int;
  }

  Future<void> clearLogs() async {
    final db = await database;
    await db.delete('logs');
  }
}
