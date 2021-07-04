import 'package:path/path.dart' as path;
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/accounts_tree.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_number_model.dart';
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
        await db.execute('PRAGMA foreign_keys = ON;');
        await db.execute(AccountModel.QUERY_CREATE_ACCOUNT_TABLE);
        await insertPredefinedAccounts(db);
        await db.execute(VoucherModel.QUERY_CREATE_VOUCHER_TABLE);
        await db.execute(TransactionModel.QUERY_CREATE_TRANSACTION_TABLE);
        await db.execute(VoucherNumberModel.QUERY_CREATE_VOUCHER_NUMBER_TABLE);
        await insertPredefinedVoucherNumbers(db);
      },
    );
    await db.execute('PRAGMA foreign_keys = ON;');
    return db;
  }

  static Future<int> insert(String table, Map<String, Object?> data) async {
    final db = await AccountingDB.database();
    return db.insert(table, data,
        conflictAlgorithm: ConflictAlgorithm.rollback);
  }

  static Future<int> update(String table, Map<String, Object?> data) async {
    final db = await AccountingDB.database();
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteDB() async {
    final db = await AccountingDB.database();
    db.close();
    final dbName = 'accounting.db';
    final dbDirectory = await getDatabasesPath();
    final dbPath = path.join(dbDirectory, dbName);
    deleteDatabase(dbPath);
  }

  static Future<List<Map<String, Object?>>> runRawQuery(String query,
      [List<Object?>? arguments]) async {
    final db = await AccountingDB.database();
    return db.rawQuery(query, arguments);
  }

  static Future<int> deleteRawQuery(String query,
      [List<Object?>? arguments]) async {
    final db = await AccountingDB.database();
    return db.rawDelete(query, arguments);
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
      // print('ADB20| @insertPredefinedAccounts() insertResult: $insertResult');
    }
  }

  static Future<void> insertPredefinedVoucherNumbers(Database db) async {
    await db.insert(
      VoucherNumberModel.tableName,
      VoucherNumberModel.InitialVoucherNumber,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
