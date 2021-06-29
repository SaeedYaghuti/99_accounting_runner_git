import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/accounts_tree.dart';
import 'package:shop/accounting/accounting_logic/transaction_feed.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_feed.dart';
import 'package:shop/accounting/accounting_logic/voucher_management.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/expenditure/expenditure_form_fields.dart';
import 'package:shop/accounting/accounting_logic/DBException.dart';

class ExpenditureModel {
  static Future<void> createExpenditureInDB(ExpenditurFormFields fields) async {
    var voucherFeed = VoucherFeed(date: fields.date!);
    var transactionFeedDebit = TransactionFeed(
      accountId: fields.paidBy!,
      amount: fields.amount!,
      isDebit: true,
      date: fields.date!,
      note: '${fields.paidBy} paid for ${ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID}',
    );
    var transactionFeedCredit = TransactionFeed(
      accountId: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
      amount: fields.amount!,
      isDebit: false,
      date: fields.date!,
      note: fields.note!,
    );
    return VoucherManagement.createVoucher(
      voucherFeed,
      [
        transactionFeedDebit,
        transactionFeedCredit,
      ],
    );
  }

  static Future<List<VoucherModel>> expenditureVouchers() {
    return VoucherModel.accountVouchers(ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID);
  }
}
