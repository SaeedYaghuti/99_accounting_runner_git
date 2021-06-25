class TransactionFeed {
  final String accountId;
  final double amount;
  final bool isDebit;
  final DateTime date;
  final String note;

  TransactionFeed({
    required this.accountId,
    required this.amount,
    required this.isDebit,
    required this.date,
    required this.note,
  });
}
