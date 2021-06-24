class VoucherModel {
  final String id;
  final String voucherNumber;
  final DateTime date;
  final String note;

  const VoucherModel({
    required this.id,
    required this.voucherNumber,
    required this.date,
    this.note = '',
  });

  static const String tableName = 'vouchers';
  static const String column1Id = 'id';
  static const String column2VoucherNumber = 'voucherNumber';
  static const String column3Date = 'date';
  static const String column4Note = 'note';

  static const String QUERY_CREATE_VOUCHER_TABLE = '''CREATE TABLE $tableName (
    $column1Id TEXT PRIMARY KEY, 
    $column2VoucherNumber TEXT NOT NULL, 
    $column3Date INTEGER  NOT NULL, 
    $column4Note TEXT, 
  )''';

  Map<String, Object> toMapForDB() {
    return {
      column1Id: id,
      column2VoucherNumber: voucherNumber,
      column3Date: date.toUtc().millisecondsSinceEpoch,
      column4Note: note,
    };
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
