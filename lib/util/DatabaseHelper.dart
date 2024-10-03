import 'package:carabaobillingapps/service/models/order/ResponseListOrdersModels.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

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
      version: 1,
      onCreate: _onCreate,
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
  }

  // Insert a new order
  Future<void> insertOrder(NewestOrder order) async {
    final db = await database;
    await db.insert(
      'orders',
      order.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all orders
  Future<List<NewestOrder>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('orders');
    return List.generate(maps.length, (i) {
      return NewestOrder.fromJson(maps[i]);
    });
  }

  // Clear all orders
  Future<void> clearOrders() async {
    final db = await database;
    await db.delete('orders');
  }
}
