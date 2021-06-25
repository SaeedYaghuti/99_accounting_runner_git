import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';

class VoucherModel {
  int? id;
  final String voucherNumber;
  final DateTime date;
  final String note;

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
    return AccountingDB.insert(tableName, map);
  }

  static Future<void> fetchAllVouchers() async {
    final query = '''
    SELECT *
    FROM $tableName
    ''';
    var result = await AccountingDB.runRawQuery(query);
    print('VM11| SELECT * FROM $tableName >');
    print(result);
  }

  static Future<void> fetchAllVouchersJoin() async {
    final query = '''
    SELECT *
    FROM $tableName
    LEFT JOIN ${TransactionModel.transactionTableName}
    ON $tableName.$column1Id = ${TransactionModel.transactionTableName}.${TransactionModel.column3VoucherId}
    ''';
    var result = await AccountingDB.runRawQuery(query);
    print('VM11| $tableName JOIN result >');
    print(result);
  }

  static const String tableName = 'vouchers';
  static const String column1Id = 'vch_id';
  static const String column2VoucherNumber = 'voucherNumber';
  static const String column3Date = 'vch_date';
  static const String column4Note = 'vch_note';

  static const String QUERY_CREATE_VOUCHER_TABLE = '''CREATE TABLE $tableName (
    $column1Id INTEGER PRIMARY KEY, 
    $column2VoucherNumber TEXT NOT NULL, 
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

  String toString() {
    return '''
    ${VoucherModel.column1Id}: $id, 
    ${VoucherModel.column2VoucherNumber}: $voucherNumber,
    ${VoucherModel.column3Date}: ${date.day}/${date.month}/${date.year},
    ${VoucherModel.column4Note}: $note,
    ''';
  }
}
