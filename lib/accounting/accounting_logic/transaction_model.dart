import 'package:shop/accounting/accounting_logic/accounts_tree.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/accounting_logic/DBException.dart';
import 'package:shop/shared/seconds_of_time.dart';

import 'account_model.dart';

class TransactionModel {
  int? id;
  final String accountId;
  final int voucherId;
  final double amount;
  final bool isDebit;
  final DateTime date;
  final String note;

  TransactionModel({
    this.id,
    required this.accountId,
    required this.voucherId,
    required this.amount,
    required this.isDebit,
    required this.date,
    required this.note,
  });

  Future<int> insertTransactionToDB() async {
    // do some logic on variables
    return AccountingDB.insert(transactionTableName, toMapForDB());
  }

  static Future<void> allTransactions() async {
    final query = '''
    SELECT *
    FROM $transactionTableName
    ''';
    var result = await AccountingDB.runRawQuery(query);
    print('TM10| SELECT * FROM $transactionTableName >');
    print(result);
  }

  Future<int> deleteMeFromDB() async {
    if (id == null) {
      return 0;
    }
    final query = '''
    DELETE FROM $transactionTableName
    WHERE $column1Id = $id ;
    ''';
    var count = await AccountingDB.deleteRawQuery(query);
    print('TM10| DELETE $id; count: $count');
    return count;
  }

  static Future<List<Map<String, Object?>>> allTransactionsForAccount(
    String accountId,
  ) async {
    final query = '''
    SELECT *
    FROM $transactionTableName
    WHERE $transactionTableName.$column2AccountId = ?
    ''';
    var result = await AccountingDB.runRawQuery(query, [accountId]);
    // print('TM11| SELECT * FROM $transactionTableName for $accountId>');
    // print(result);
    return result;
  }

  static Future<void> allTranJoinVch() async {
    final query = '''
    SELECT *
    FROM $transactionTableName
    LEFT JOIN ${VoucherModel.voucherTableName}
    ON $transactionTableName.$column3VoucherId = ${VoucherModel.voucherTableName}.${VoucherModel.column1Id}
    ''';
    var result = await AccountingDB.runRawQuery(query);
    print('TM16| $transactionTableName JOIN result >');
    print(result);
  }

  // not_good: only fetch voucher with some of it's transactions not all of them
  static Future<List<Map<String, Object?>>> allTranJoinVchForAccount(
    String accountId,
  ) async {
    final query = '''
    SELECT *
    FROM $transactionTableName
    LEFT JOIN ${VoucherModel.voucherTableName}
    ON $transactionTableName.$column3VoucherId = ${VoucherModel.voucherTableName}.${VoucherModel.column1Id}
    WHERE $transactionTableName.$column2AccountId = ?
    ''';
    var result = await AccountingDB.runRawQuery(query, [accountId]);
    print('TM20| $transactionTableName and Vouchers for $accountId >');
    print(result);
    return result;
  }

  static List<TransactionModel> fromMapOfTransactions(
    List<Map<String, Object?>> dbResult,
  ) {
    return dbResult
        .map(
          (tran) => TransactionModel(
            id: tran[TransactionModel.column1Id] as int,
            accountId: tran[TransactionModel.column2AccountId] as String,
            voucherId: tran[TransactionModel.column3VoucherId] as int,
            amount: tran[TransactionModel.column4Amount] as double,
            isDebit: convertIntToBoolean(
              tran[TransactionModel.column5IsDebit] as int,
            ),
            // date: DateTime.fromMicrosecondsSinceEpoch(
            //   tran[TransactionModel.column6Date] as int,
            // ),
            date: secondsToDateTime(
              tran[TransactionModel.column6Date] as int,
            ),
            note: tran[TransactionModel.column7Note] as String,
          ),
        )
        .toList();
  }

  static TransactionModel fromMapOfTransaction(
    Map<String, Object?> tran,
  ) {
    var transaction = TransactionModel(
      id: tran[TransactionModel.column1Id] as int,
      accountId: tran[TransactionModel.column2AccountId] as String,
      voucherId: tran[TransactionModel.column3VoucherId] as int,
      amount: tran[TransactionModel.column4Amount] as double,
      isDebit: convertIntToBoolean(
        tran[TransactionModel.column5IsDebit] as int,
      ),
      date: secondsToDateTime(
        tran[TransactionModel.column6Date] as int,
      ),
      note: tran[TransactionModel.column7Note] as String,
    );
    // print('TM 52 | @ fromMapOfTransaction() > after conversion');
    // print(transaction);
    return transaction;
  }

  static List<Map<String, dynamic>> fromMapOfVoucherJoinTransactions(
    List<Map<String, Object?>> dbResult,
  ) {
    return dbResult
        .map(
          (voucherJointran) => {
            VoucherModel.voucherTableName:
                VoucherModel.fromMapOfVoucher(voucherJointran),
            TransactionModel.transactionTableName:
                fromMapOfTransaction(voucherJointran),
          },
        )
        .toList();
  }

  Map<String, Object?> toMapForDB() {
    if (id == null) {
      return {
        column2AccountId: accountId,
        column3VoucherId: voucherId,
        column4Amount: amount,
        column5IsDebit: isDebit ? 1 : 0,
        column6Date: seconsdOfDateTime(date),
        column7Note: note,
      };
    } else {
      return {
        column1Id: id!,
        column2AccountId: accountId,
        column3VoucherId: voucherId,
        column4Amount: amount,
        column5IsDebit: isDebit ? 1 : 0,
        column6Date: seconsdOfDateTime(date),
        column7Note: note,
      };
    }
  }

  String toString() {
    return '''
    id: $id, 
    accountId: $accountId,
    voucherId: $voucherId,
    amount: $amount,
    isDebit: $isDebit,
    date: ${date.day}/${date.month}/${date.year},
    note: $note,
    ''';
  }

  static bool convertIntToBoolean(int num) {
    if (num == 0) {
      return false;
    } else if (num == 1) {
      return true;
    } else {
      throw DBException('TM50| $num is stored at database as boolean value!');
    }
  }

  static const String transactionTableName = 'transactions';
  static const String column1Id = 'tran_id';
  static const String column2AccountId = 'tran_accountId';
  static const String column3VoucherId = 'tran_voucherId';
  static const String column4Amount = 'tran_amount';
  static const String column5IsDebit = 'isDebit';
  static const String column6Date = 'tran_date';
  static const String column7Note = 'tran_note';

  static const String QUERY_CREATE_TRANSACTION_TABLE =
      '''CREATE TABLE $transactionTableName (
    $column1Id INTEGER PRIMARY KEY, 
    $column2AccountId TEXT NOT NULL, 
    $column3VoucherId INTEGER NOT NULL, 
    $column4Amount REAL NOT NULL, 
    $column5IsDebit BOOLEAN NOT NULL CHECK( $column5IsDebit IN (0, 1) ),
    $column6Date INTEGER NOT NULL, 
    $column7Note TEXT, 
    FOREIGN KEY ($column2AccountId) REFERENCES ${AccountModel.tableName} (${AccountModel.columnId}),
    FOREIGN KEY ($column3VoucherId) REFERENCES ${VoucherModel.voucherTableName} (${VoucherModel.column1Id})
  )''';
}
