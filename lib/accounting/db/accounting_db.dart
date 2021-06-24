import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:shop/accounting/account/account_model.dart';
import 'package:shop/accounting/account/accounts_tree.dart';
import 'package:shop/accounting/account/transaction_model.dart';
import 'package:shop/accounting/account/voucher_model.dart';
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
        print('ADB10| onCreate runing...');
        await db.execute(AccountModel.QUERY_CREATE_ACCOUNT_TABLE);
        await insertPredefinedAccounts(db);
        await db.execute(VoucherModel.QUERY_CREATE_VOUCHER_TABLE);
        await db.execute(TransactionModel.QUERY_CREATE_TRANSACTION_TABLE);
      },
    );
    return db;
  }

  static Future<int> insert(String table, Map<String, Object> data) async {
    final db = await AccountingDB.database();
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, Object?>>> getData(String table) async {
    final db = await AccountingDB.database();
    return db.query(table);
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
}
