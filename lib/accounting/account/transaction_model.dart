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
}
