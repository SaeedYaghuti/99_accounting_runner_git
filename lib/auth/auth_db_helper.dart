import 'package:path/path.dart' as path;
import 'package:shop/auth/auth_model_sql.dart';
import 'package:shop/auth/auth_permission_model.dart';
import 'package:shop/auth/permissions_list.dart';
import 'package:shop/auth/permission_model.dart';
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
        await insertPredefinedAuth(db);
        await db.execute(PermissionModel.QUERY_CREATE_PERMISSION_TABLE);
        await insertPredefinedPermissions(db);
        await db.execute(
          AuthPermissionModel.QUERY_CREATE_JOIN_TABLE_AUTH_PERMISSION,
        );
        await insertPredefinedPermissionsToFirstAuth(db);
      },
    );
    await db.execute(QUERY_FOREIGN_KEY_ON);
    return db;
  }

  static Future<void> insertPredefinedPermissions(Database db) async {
    for (PermissionModel permission in PERMISSIONS_LIST) {
      int insertResult = await db.insert(
        PermissionModel.tableName,
        permission.toMap(),
        conflictAlgorithm: ConflictAlgorithm.rollback,
      );
      print(
        'AuthDB predPerm 01| @insertPredefinedPermissions() insertResult: $insertResult',
      );
    }
  }

  static Future<void> insertPredefinedPermissionsToFirstAuth(
    Database db,
  ) async {
    await AuthPermissionModel.giveAllPermissionsToFirstAuth(db);
  }

  static Future<void> insertPredefinedAuth(Database db) async {
    var auth = AuthModel();
    await auth.createFirstUserInDB(db);
    print(
      'AuthDB predAuth 01| firstUser inserted in db',
    );
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
    await deleteDatabase(dbPath);
    print('AuthDB deleteDB| AuthDB is deleted ...');
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
