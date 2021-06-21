import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbDirectory = await getDatabasesPath();
    final dbName = 'shop.db';
    final dbPath = path.join(dbDirectory, dbName);

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        // if we had boolean
        // , isFavorite BOOLEAN NOT NULL CHECK (mycolumn IN (0, 1))
        return db.execute(
            'CREATE TABLE product (id TEXT PRIMARY KEY, title TEXT, description TEXT, price REAL, imageUrl TEXT, creatorId TEXT)');
      },
    );
  }

  static Future<int> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, Object?>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }
}
