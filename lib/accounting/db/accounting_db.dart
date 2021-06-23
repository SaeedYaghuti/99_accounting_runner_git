import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:shop/accounting/account/account_model.dart';
import 'package:shop/accounting/account/accounts_tree.dart';
import 'package:sqflite/sqflite.dart';

class AccountingDB {
  static Future<Database> database() async {
    final dbDirectory = await getDatabasesPath();
    final dbName = 'accounting.db';
    final dbPath = path.join(dbDirectory, dbName);

    var db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // define bool: BOOLEAN NOT NULL CHECK (mycolumn IN (0, 1))
        await db.execute(
          AccountModel.CREATE_ACCOUNT_TABLE_QUERY,
        );
      },
    );

    // account_table should have predefined data
    await insertPredefinedAccounts(db);
    return db;
  }

  static Future<int> insert(String table, Map<String, Object> data) async {
    final db = await AccountingDB.database();
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> insertPredefinedAccounts(Database db) async {
    for (AccountModel account in ACCOUNTS_TREE) {
      int insertResult = await db.insert(
        AccountModel.tableName,
        account.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('ADB10| insertResult: $insertResult');
    }
  }

  static Future<List<Map<String, Object?>>> getData(String table) async {
    final db = await AccountingDB.database();
    return db.query(table);
  }
}
