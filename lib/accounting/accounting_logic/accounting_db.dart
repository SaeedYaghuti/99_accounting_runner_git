import 'package:path/path.dart' as path;
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/accounts_tree.dart';
import 'package:shop/accounting/accounting_logic/floating_account.dart';
import 'package:shop/accounting/accounting_logic/floating_account_tree.dart';
import 'package:shop/accounting/accounting_logic/transaction_class/transaction_classification.dart';
import 'package:shop/accounting/accounting_logic/transaction_classification/tranClass_tree.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_number_model.dart';
import 'package:shop/accounting/expenditure/expenditure_class_tree.dart';
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
        print('AccountingDB 01| onCreate runing...');
        await db.execute('PRAGMA foreign_keys = ON;');
        await db.execute(AccountModel.QUERY_CREATE_ACCOUNT_TABLE);
        await insertPredefinedAccounts(db);
        await db.execute(VoucherModel.QUERY_CREATE_VOUCHER_TABLE);
        await db.execute(TransactionModel.QUERY_CREATE_TRANSACTION_TABLE);
        await db.execute(VoucherNumberModel.QUERY_CREATE_VOUCHER_NUMBER_TABLE);
        await insertPredefinedVoucherNumbers(db);
        await db.execute(TransactionClassification.QUERY_CREATE_EXPENDITURE_CLASSIFICATION_TABLE);
        await insertPredefinedTransactionClasses(db);
        await db.execute(FloatingAccount.QUERY_CREATE_FLOAT_ACCOUNT_TABLE);
        await insertPredefinedFloatAccount(db);
      },
    );
    await db.execute('PRAGMA foreign_keys = ON;');
    return db;
  }

  static Future<int> insert(String table, Map<String, Object?> data) async {
    final db = await AccountingDB.database();
    return db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> update(String table, Map<String, Object?> data) async {
    final db = await AccountingDB.database();
    return db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteDB() async {
    final db = await AccountingDB.database();
    db.close();
    final dbName = 'accounting.db';
    final dbDirectory = await getDatabasesPath();
    final dbPath = path.join(dbDirectory, dbName);
    await deleteDatabase(dbPath);
    print('AccountingDB deleteDB| database deleted ...');
  }

  static Future<List<Map<String, Object?>>> runRawQuery(String query, [List<Object?>? arguments]) async {
    final db = await AccountingDB.database();
    return db.rawQuery(query, arguments);
  }

  static Future<int> deleteRawQuery(String query, [List<Object?>? arguments]) async {
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

  static Future<void> insertPredefinedTransactionClasses(Database db) async {
    // tranClassTree
    for (var tranClass in TRANS_CLASS_TREE) {
      int insertResult = await db.insert(
        TransactionClassification.tableName,
        tranClass.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('ACC_DB| @insertPredefinedTransactionClasses() 01 | insertResult: $insertResult');
    }
    // expClassTree
    for (TransactionClassification expClass in EXP_CLASS_TREE) {
      int insertResult = await db.insert(
        TransactionClassification.tableName,
        expClass.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('ACC_DB| @insertPredefinedTransactionClasses() 02 | insertResult: $insertResult');
    }
  }

  static Future<void> insertPredefinedFloatAccount(Database db) async {
    for (FloatingAccount floatAcc in FLOAT_ACCOUNT_TREE) {
      int insertResult = await db.insert(
        FloatingAccount.tableName,
        floatAcc.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('ACC_DB| @insertPredefinedFloatAccount()| insertResult: $insertResult');
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
