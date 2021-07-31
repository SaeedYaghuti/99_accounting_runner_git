import 'package:shop/accounting/accounting_logic/transaction_classification.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/exceptions/DBException.dart';
import 'package:shop/exceptions/curropted_input.dart';
import 'package:shop/exceptions/dirty_database.dart';
import 'package:shop/shared/seconds_of_time.dart';

import 'account_model.dart';

class TransactionModel {
  int? id;
  AccountModel? account;
  final String accountId;
  final int voucherId;
  final double amount;
  final bool isDebit;
  final DateTime date;
  final String note;

  // data recived from client it is null
  // data fetched from db it is not null
  TransactionClassification tranClass;

  TransactionModel({
    this.id,
    required this.accountId,
    this.account,
    required this.voucherId,
    required this.amount,
    required this.isDebit,
    required this.date,
    required this.note,
    required this.tranClass,
  });

  Future<int> insertMeIntoDB() async {
    // do some logic on variables
    return AccountingDB.insert(transactionTableName, toMapForDB());
  }

  static Future<void> allTransactions() async {
    final query = '''
    SELECT *
    FROM $transactionTableName
    ''';
    var result = await AccountingDB.runRawQuery(query);
    print('TM10| All DB $transactionTableName: ########');
    print(result);
    print('##################');
  }

  Future<void> fetchMyAccount() async {
    AccountModel? fAccount = await AccountModel.fetchAccountById(accountId);
    if (fAccount == null) {
      throw CurroptedInputException('TRN_MDL | fetchMyAccount() | Not found account for accountId: <$accountId>');
    }
    account = fAccount;
  }

  static Future<TransactionModel?> transactionById(int tranId) async {
    final _query0 = '''
    SELECT *
    FROM $transactionTableName 
    LEFT JOIN 
      ${TransactionClassification.tableName}
    ON ${TransactionModel.column8TranClassId} = ${TransactionClassification.column1Id}
    AND ${TransactionModel.column2AccountId} = ?
    WHERE $column1Id = ? ;
    ''';

    final query = '''
    SELECT *
    FROM $transactionTableName 
    LEFT JOIN 
      ${TransactionClassification.tableName}
    ON ${TransactionModel.column8TranClassId} = ${TransactionClassification.column1Id}
    AND ${TransactionModel.column1Id} = ? ;
    ''';
    var transactionsMap = await AccountingDB.runRawQuery(query, [tranId]);

    // convert map to TransactionModel
    List<TransactionModel> transactionsModels = [];
    transactionsMap.forEach(
      (tranMap) => transactionsModels.add(fromMapOfTransactionJClass(tranMap)),
    );

    if (transactionsModels.isEmpty) {
      return null;
    }
    if (transactionsModels.length > 1) {
      throw DirtyDatabaseException(
        'TRAN_MDL | transactionById($tranId)| there are more than one transaction with same id',
      );
    }

    print('TRAN_MDL | transactionById($tranId) | 01');
    print(transactionsModels);
    print('#');

    return transactionsModels[0];
  }

  Future<int> deleteMeFromDB() async {
    if (id == null) {
      return 0;
    }
    final query = '''
    DELETE FROM $transactionTableName
    WHERE $column1Id = ? ;
    ''';
    var count = await AccountingDB.deleteRawQuery(query, [id]);
    // print('TRN_MDL 10| DELETE $id; result: $count');
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
            isDebit: convertIntToBoolean(tran[TransactionModel.column5IsDebit] as int),
            date: secondsToDateTime(tran[TransactionModel.column6Date] as int),
            note: tran[TransactionModel.column7Note] as String,
            tranClass: TransactionClassification.fromMap(tran, true)!,
          ),
        )
        .toList();
  }

  static TransactionModel fromMapOfTransactionJClass(Map<String, Object?> tran) {
    var transaction = TransactionModel(
      id: tran[TransactionModel.column1Id] as int,
      accountId: tran[TransactionModel.column2AccountId] as String,
      voucherId: tran[TransactionModel.column3VoucherId] as int,
      amount: tran[TransactionModel.column4Amount] as double,
      isDebit: convertIntToBoolean(tran[TransactionModel.column5IsDebit] as int),
      date: secondsToDateTime(tran[TransactionModel.column6Date] as int),
      note: tran[TransactionModel.column7Note] as String,
      tranClass: TransactionClassification.fromMap(tran, true)!,
    );
    // print('TM 52 | @ fromMapOfTransaction() > after conversion');
    // print(transaction);
    return transaction;
  }

  static TransactionModel fromMapOfTransactionJAccountJClass(
    Map<String, Object?> tranJAccJClass,
  ) {
    // print('TRN_MDL | 01 fromMapOfTransactionJoinAccount | input:');
    // print(tranJAccJClass);

    var transaction;
    try {
      transaction = TransactionModel(
        id: tranJAccJClass[TransactionModel.column1Id] as int,
        accountId: tranJAccJClass[TransactionModel.column2AccountId] as String,
        voucherId: tranJAccJClass[TransactionModel.column3VoucherId] as int,
        amount: tranJAccJClass[TransactionModel.column4Amount] as double,
        isDebit: convertIntToBoolean(tranJAccJClass[TransactionModel.column5IsDebit] as int),
        date: secondsToDateTime(tranJAccJClass[TransactionModel.column6Date] as int),
        note: tranJAccJClass[TransactionModel.column7Note] as String,
        account: AccountModel.fromMap(tranJAccJClass),
        tranClass: TransactionClassification.fromMap(tranJAccJClass, true)!,
      );
    } catch (e) {
      print('TRN_MDL | fromMapOfTransactionJoinAccount() 01| @ catch e: $e');
      throw e;
    }
    // print('TRN_MDL | 02 fromMapOfTransactionJoinAccount | output:');
    // print(transaction);

    return transaction;
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
        column8TranClassId: tranClass.id,
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
        column8TranClassId: tranClass.id,
      };
    }
  }

  String toString() {
    return '''
    tranId: $id, voucherId: $voucherId,  
    accountId: $accountId, amount: $amount, isDebit: $isDebit,
    note: $note, date: ${date.day}/${date.month}/${date.year},
    tranClass: $tranClass,
    ****
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
  static const String column8TranClassId = 'tran_classId';

  static const String QUERY_CREATE_TRANSACTION_TABLE = '''CREATE TABLE $transactionTableName (
    $column1Id INTEGER PRIMARY KEY, 
    $column2AccountId TEXT NOT NULL, 
    $column3VoucherId INTEGER NOT NULL, 
    $column4Amount REAL NOT NULL, 
    $column5IsDebit BOOLEAN NOT NULL CHECK( $column5IsDebit IN (0, 1) ),
    $column6Date INTEGER NOT NULL, 
    $column7Note TEXT, 
    $column8TranClassId TEXT NOT NULL, 
    CONSTRAINT fk_${AccountModel.tableName} FOREIGN KEY ($column2AccountId) REFERENCES ${AccountModel.tableName} (${AccountModel.column1Id}) ON DELETE CASCADE,
    CONSTRAINT fk_${VoucherModel.voucherTableName} FOREIGN KEY ($column3VoucherId) REFERENCES ${VoucherModel.voucherTableName} (${VoucherModel.column1Id}) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_${TransactionClassification.tableName} FOREIGN KEY ($column8TranClassId) REFERENCES ${TransactionClassification.tableName} (${TransactionClassification.column1Id}) 
  )''';
}
