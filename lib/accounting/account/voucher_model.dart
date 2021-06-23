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
}
