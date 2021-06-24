import 'package:shop/accounting/account/voucher_model.dart';

import 'account_model.dart';

class TransactionModel {
  final String id;
  final String accountId;
  final String voucherId;
  final double amount;
  final bool isDebit;
  final DateTime date;
  final String note;

  const TransactionModel({
    required this.id,
    required this.accountId,
    required this.voucherId,
    required this.amount,
    required this.isDebit,
    required this.date,
    this.note = '',
  });

  static const String tableName = 'transactions';
  static const String column1Id = 'id';
  static const String column2AccountId = 'accountId';
  static const String column3VoucherId = 'voucherId';
  static const String column4Amount = 'amount';
  static const String column5IsDebit = 'isDebit';
  static const String column6Date = 'date';
  static const String column7Note = 'note';

  static const String QUERY_CREATE_TRANSACTION_TABLE =
      '''CREATE TABLE $tableName (
    $column1Id TEXT PRIMARY KEY, 
    $column2AccountId TEXT NOT NULL, 
    $column3VoucherId TEXT NOT NULL, 
    $column4Amount REAL NOT NULL, 
    $column5IsDebit BOOLEAN NOT NULL CHECK( $column5IsDebit IN (0, 1) ),
    $column6Date INTEGER NOT NULL, 
    $column7Note TEXT, 
    FOREIGN KEY ($column2AccountId) REFERENCES ${AccountModel.tableName} (${AccountModel.columnId}),
    FOREIGN KEY ($column3VoucherId) REFERENCES ${VoucherModel.tableName} (${VoucherModel.column1Id}),
  )''';

  Map<String, Object> toMapForDB() {
    return {
      column1Id: id,
      column2AccountId: accountId,
      column3VoucherId: voucherId,
      column4Amount: amount,
      column5IsDebit: isDebit ? 1 : 0,
      column6Date: date.toUtc().millisecondsSinceEpoch,
      column7Note: note,
    };
  }

  String toString() {
    return '''
    ${TransactionModel.column1Id}: $id, 
    ${TransactionModel.column2AccountId}: $accountId,
    ${TransactionModel.column3VoucherId}: $voucherId,
    ${TransactionModel.column4Amount}: $amount,
    ${TransactionModel.column5IsDebit}: $isDebit,
    ${TransactionModel.column6Date}: ${date.day}/${date.month}/${date.year},
    ${TransactionModel.column7Note}: $note,
    ''';
  }
}
