import 'package:shop/accounting/accounting_logic/Voucher_model.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';

class VoucherModel {
  int? id;
  final int voucherNumber;
  final DateTime date;
  final String note;
  List<TransactionModel?> transactions = [];

  VoucherModel({
    this.id,
    required this.voucherNumber,
    required this.date,
    this.note = '',
  });

  Future<int> insertInDB() async {
    // do some logic on variables
    var map = this.toMapForDB();
    print('VM10| map: $map');
    id = await AccountingDB.insert(voucherTableName, map);
    print('VM10| insertInDB() id: $id');
    return id!;
  }

  Future<int> deleteMeFromDB() async {
    if (id == null) {
      return 0;
    }

    final query = '''
    DELETE FROM $voucherTableName
    WHERE $column1Id = $id ;
    ''';
    var count = await AccountingDB.deleteRawQuery(query);
    print('VM 20| DELETE $id; count: $count');
    return count;
  }

  Future<void> fetchMyTransactions() async {
    if (id == null) {
      print('VM 29| Warn: id is null: fetchMyTransactions()');
      return;
    }

    final query = '''
      SELECT *
      FROM ${TransactionModel.transactionTableName}
      WHERE ${TransactionModel.column3VoucherId} = $id
    ''';
    var result = await AccountingDB.runRawQuery(query);
    transactions = result
        .map(
          (tranMap) => TransactionModel.fromMapOfTransaction(tranMap),
        )
        .toList();
  }

  static Future<void> fetchAllVouchers() async {
    final query = '''
    SELECT *
    FROM $voucherTableName
    ''';
    var result = await AccountingDB.runRawQuery(query);
    print('VM11| SELECT * FROM $voucherTableName >');
    print(result);
  }

  static Future<int> maxVoucherNumber() async {
    final query = '''
    SELECT MAX($column2VoucherNumber) as max
    FROM $voucherTableName
    ''';
    var result = await AccountingDB.runRawQuery(query);
    print('VM 21| SELECT MAX FROM $voucherTableName >');
    print(result);

    var maxResult =
        (result[0]['max'] == null) ? '0' : (result[0]['max'] as String);
    var parse = int.tryParse(maxResult);
    var max = (parse == null) ? 0 : parse;
    print(max);
    return max;
  }

  static Future<void> fetchAllVouchersJoin() async {
    final query = '''
    SELECT *
    FROM $voucherTableName
    LEFT JOIN ${TransactionModel.transactionTableName}
    ON $voucherTableName.$column1Id = ${TransactionModel.transactionTableName}.${TransactionModel.column3VoucherId}
    ''';
    var result = await AccountingDB.runRawQuery(query);
    print('VM11| $voucherTableName JOIN result >');
    print(result);
  }

  static Future<void> vouchersOfAccountIncludeTransactions(
    String accountId,
  ) async {
    final query = '''
    SELECT *
    FROM $voucherTableName
    LEFT JOIN (
      SELECT 
        ${TransactionModel.column3VoucherId}, 
        group_concat(
          ${TransactionModel.column2AccountId}
        ) 
      FROM ${TransactionModel.transactionTableName}
      WHERE ${TransactionModel.column2AccountId} = ?
      GROUP BY ${TransactionModel.column3VoucherId}
    ) AS subquery 
    ON $voucherTableName.$column1Id = subquery.${TransactionModel.column3VoucherId}
    ''';

    final q = '''
    SELECT 
      ${TransactionModel.column3VoucherId}, 
      group_concat(
        ${TransactionModel.column1Id},
        ${TransactionModel.column2AccountId},
        ${TransactionModel.column3VoucherId},
        ${TransactionModel.column4Amount},
        ${TransactionModel.column5IsDebit},
        ${TransactionModel.column6Date},
        ${TransactionModel.column7Note}
      )
    FROM $voucherTableName
    LEFT JOIN (
      SELECT * 
      FROM ${TransactionModel.transactionTableName}
      WHERE ${TransactionModel.column2AccountId} = ?
      GROUP BY ${TransactionModel.column3VoucherId}
    ) AS subquery 
    ON $voucherTableName.$column1Id = subquery.${TransactionModel.column3VoucherId}
    ''';
    var result = await AccountingDB.runRawQuery(query, [accountId]);
    print('VM 30| vouchersOfAccountIncludeTransactions() result >');
    print(result);
  }

  static const String voucherTableName = 'vouchers';
  static const String column1Id = 'vch_id';
  static const String column2VoucherNumber = 'voucherNumber';
  static const String column3Date = 'vch_date';
  static const String column4Note = 'vch_note';
  static const String column5Transactions = 'transactions';

  static const String QUERY_CREATE_VOUCHER_TABLE =
      '''CREATE TABLE $voucherTableName (
    $column1Id INTEGER PRIMARY KEY, 
    $column2VoucherNumber INTEGER NOT NULL, 
    $column3Date INTEGER  NOT NULL, 
    $column4Note TEXT
  )''';

  Map<String, Object> toMapForDB() {
    if (id == null) {
      return {
        column2VoucherNumber: voucherNumber,
        column3Date: date.toUtc().millisecondsSinceEpoch,
        column4Note: note,
      };
    } else {
      return {
        column1Id: id ?? '',
        column2VoucherNumber: voucherNumber,
        column3Date: date.toUtc().millisecondsSinceEpoch,
        column4Note: note,
      };
    }
  }

  static VoucherModel fromMapOfVoucher(
    Map<String, Object?> voucherMap,
  ) {
    print('VM 20| fromMapOfVoucher; voucherMap:');
    print(voucherMap);

    var voucher = VoucherModel(
      id: voucherMap[VoucherModel.column1Id] as int,
      voucherNumber: voucherMap[VoucherModel.column2VoucherNumber] as int,
      date: DateTime.fromMicrosecondsSinceEpoch(
        voucherMap[VoucherModel.column3Date] as int,
      ),
      note: voucherMap[VoucherModel.column4Note] as String,
    );
    print('VM 21| fromMapOfVoucher; voucher:');

    print(voucher);
    return voucher;
  }

  String toString() {
    return '''
    id: $id, 
    voucherNumber: $voucherNumber,
    date: ${date.day}/${date.month}/${date.year},
    note: $note,
    ''';
  }
}
