import 'package:shop/accounting/accounting_logic/floating_account.dart';
import 'package:shop/accounting/accounting_logic/transaction_classification.dart';

class TransactionFeed {
  final String accountId;
  final double amount;
  final bool isDebit;
  final DateTime date;
  final String note;
  final TransactionClassification tranClass;
  final FloatingAccount floatingAccount;

  TransactionFeed({
    required this.accountId,
    required this.amount,
    required this.isDebit,
    required this.date,
    required this.note,
    required this.tranClass,
    required this.floatingAccount,
  });
}
