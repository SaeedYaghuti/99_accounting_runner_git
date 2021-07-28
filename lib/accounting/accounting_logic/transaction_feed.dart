class TransactionFeed {
  final String accountId;
  final double amount;
  final bool isDebit;
  final DateTime date;
  final String note;
  final String tranClassId;

  TransactionFeed({
    required this.accountId,
    required this.amount,
    required this.isDebit,
    required this.date,
    required this.note,
    required this.tranClassId,
  });
}
