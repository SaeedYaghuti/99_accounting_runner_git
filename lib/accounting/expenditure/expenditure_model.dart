import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/transaction_feed.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_feed.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/expenditure/expenditure_form_fields.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/exceptions/curropted_input.dart';

class ExpenditureModel {
  static Future<void> createExpenditureInDB(
      AuthProviderSQL authProvider, ExpenditurFormFields fields) async {
    var voucherFeed = VoucherFeed(date: fields.date!);
    var transactionFeedDebit = TransactionFeed(
      accountId: fields.paidBy!.id,
      amount: fields.amount!,
      isDebit: true,
      date: fields.date!,
      note:
          '${fields.paidBy!.titleEnglish} paid for ${ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID}',
    );
    var transactionFeedCredit = TransactionFeed(
      accountId: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
      amount: fields.amount!,
      isDebit: false,
      date: fields.date!,
      note: fields.note!,
    );
    return VoucherModel.createVoucher(
      authProvider,
      voucherFeed,
      [
        transactionFeedDebit,
        transactionFeedCredit,
      ],
    );
  }

  static Future<List<VoucherModel?>> expenditureVouchers(
      AuthProviderSQL authProvider) {
    return VoucherModel.accountVouchers(
      ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
      authProvider,
    );
  }

  static Future<void> updateVoucher(
    VoucherModel oldVoucher,
    ExpenditurFormFields fields,
    AuthProviderSQL authProvider,
  ) async {
    // print('EXP_MDL updateVoucher()| 01 | oldVoucher: $oldVoucher');
    // print('EXP_MDL updateVoucher()| 02 | fields: $fields');
    // mix oldVoucher with fields data
    var debitTransactions = oldVoucher.debitTransactions();
    var creditTdransactions = oldVoucher.creditTransactions();

    if (debitTransactions.length > 1 || creditTdransactions.length > 1)
      throw CurroptedInputException(
        'EM 40| This form can handle only One debit and One credit transaction',
      );

    VoucherModel newVoucher = VoucherModel(
      id: oldVoucher.id,
      creatorId: authProvider.authId!,
      voucherNumber: oldVoucher.voucherNumber,
      date: fields.date!,
      note: '${fields.paidBy!.titleEnglish} paid for Expenditure',
    );
    newVoucher.transactions = [
      // updated debit transaction
      TransactionModel(
        accountId: fields.paidBy!.id,
        voucherId: oldVoucher.id!,
        amount: fields.amount!,
        isDebit: true,
        date: fields.date!,
        note: fields.note!,
      ),
      // updated credit transaction
      TransactionModel(
        accountId: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
        voucherId: oldVoucher.id!,
        amount: fields.amount!,
        isDebit: false,
        date: fields.date!,
        note: fields.note!,
      ),
    ];

    // print('EM 43| new Voucher to be updated at db');
    // print(newVoucher);
    try {
      await VoucherModel.updateVoucher(newVoucher, authProvider);
    } catch (e) {
      print('EM 43| updateVoucher() |@ catch e: $e');
      throw e;
    }
  }
}
