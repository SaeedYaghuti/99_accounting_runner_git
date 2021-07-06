import 'package:path/path.dart' as path;
import 'package:shop/auth/local/auth_model.dart';
import 'package:sqflite/sqflite.dart';

class AuthDB {
  static const authDBName = 'auth.db';
  static const QUERY_FOREIGN_KEY_ON = 'PRAGMA foreign_keys = ON;';

  static Future<Database> database() async {
    final dbDirectory = await getDatabasesPath();
    final dbPath = path.join(dbDirectory, authDBName);

    var db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        print('AuthDB 01| onCreate runing...');
        await db.execute(QUERY_FOREIGN_KEY_ON);
        await db.execute(AuthModel.QUERY_CREATE_AUTH_TABLE);
      },
    );
    await db.execute(QUERY_FOREIGN_KEY_ON);
    return db;
  }

  static Future<int> insert(String table, Map<String, Object?> data) async {
    final db = await AuthDB.database();
    return db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  static Future<int> update(String table, Map<String, Object?> data) async {
    final db = await AuthDB.database();
    return db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteDB() async {
    final db = await AuthDB.database();
    db.close();
    final dbDirectory = await getDatabasesPath();
    final dbPath = path.join(dbDirectory, authDBName);
    deleteDatabase(dbPath);
  }

  static Future<List<Map<String, Object?>>> runRawQuery(String query,
      [List<Object?>? arguments]) async {
    final db = await AuthDB.database();
    return db.rawQuery(query, arguments);
  }

  static Future<int> deleteRawQuery(String query,
      [List<Object?>? arguments]) async {
    final db = await AuthDB.database();
    return db.rawDelete(query, arguments);
  }

  static Future<List<Map<String, Object?>>> getData(String table) async {
    final db = await AuthDB.database();
    return db.query(table);
  }
}
