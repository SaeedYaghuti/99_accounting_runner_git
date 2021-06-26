import 'package:shop/accounting/accounting_logic/transaction_feed.dart';
import 'package:shop/accounting/accounting_logic/voucher_feed.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_number_model.dart';
import 'package:shop/shared/DBException.dart';
import 'package:shop/shared/ValidationException.dart';

class VoucherManagement {
  static Future<void> createVoucher(
    VoucherFeed voucherFeed,
    List<TransactionFeed> transactionFeeds,
  ) async {
    // step 1# validate data
    if (!validateTransactionsAmount(transactionFeeds)) {
      throw ValidationException(
        'V_MG 00| amount in transactionFeeds are not valid',
      );
    }

    // step 2# get and lock voucherNumber
    var voucherNumber;
    try {
      voucherNumber = await VoucherNumberModel.getAndLockVoucherNumber();
      print('V_MG 03| voucherNumber: $voucherNumber');
    } catch (e) {
      print('V_MG 04| voucherNumber: $e');
      throw e;
      // maybe we want to use emergency unlock
      // ...
    }

    // step 1# create voucher
    VoucherModel voucher = VoucherModel(
      voucherNumber: voucherNumber,
      date: voucherFeed.date,
      note: makeVoucherNote(transactionFeeds),
    );
    print('V_MG 04| voucher before save in db >');
    print(voucher);

    try {
      int voucherId = await voucher.insertInDB();
      voucher.id = voucherId;
      print('V_MG 06| voucherId in db: $voucherId');
    } catch (e) {
      // unlock voucher number
      ...
      throw DBException(
        'V_MG 02| Unable to create voucher: e: ${e.toString()}',
      );
    }

    /// step 2 # unlock voucher number and increase
    await VoucherNumberModel.unlockVoucherNumberAndIcrease(voucherNumber);

    // step 2# create debit transaction
    TransactionModel debitTransaction = TransactionModel(
      accountId: fields.paidBy!,
      voucherId: voucherId,
      amount: fields.amount!,
      isDebit: true,
      date: fields.date!,
      note: fields.note!,
    );
    try {
      int debitTransactionId = await debitTransaction.insertTransactionToDB();
      debitTransaction.id = debitTransactionId;
      print('V_MG 02| debitTransactionId: $debitTransactionId');

      // step 3# create credit transaction
      TransactionModel creditTransaction = TransactionModel(
        accountId: EXPENDITURE_ACCOUNT_ID,
        voucherId: voucherId,
        amount: fields.amount!,
        isDebit: false,
        date: fields.date!,
        note: fields.note!,
      );
      try {
        int creditTransactionId =
            await creditTransaction.insertTransactionToDB();
        creditTransaction.id = creditTransactionId;
        print('V_MG 02| creditTransactionId: $creditTransactionId');

        // End: all steps were successfull
      } catch (e) {
        // do: delete debitTransaction from db
        throw DBException(
          'V_MG 02| Unable to create creditTransaction: e: ${e.toString()}',
        );
      }
    } catch (e) {
      // do: delete voucher from db
      throw DBException(
        'V_MG 02| Unable to create debitTransaction: e: ${e.toString()}',
      );
    }
  }

  static bool validateTransactionsAmount(List<TransactionFeed> feeds) {
    var totalDebit = 0.0;
    var totalCredit = 0.0;

    for (var feed in feeds) {
      if (feed.amount <= 0.0) {
        return false;
      }
      if (feed.isDebit) {
        totalDebit += feed.amount;
      } else {
        totalCredit += feed.amount;
      }
    }
    if (totalDebit == totalCredit) {
      return true;
    } else {
      print(
        'VMG10| totalDebit: $totalDebit and totalCredit: $totalCredit are not equal',
      );
      return false;
    }
  }

  static String makeVoucherNote(List<TransactionFeed> feeds) {
    List<String> debitNote = [];
    List<String> creditNote = [];

    for (var feed in feeds) {
      if (feed.isDebit) {
        debitNote.add(feed.accountId);
      } else {
        creditNote.add(feed.accountId);
      }
    }

    String note = debitNote.join(', ') + ' paid for ' + creditNote.join(', ');
    return note;
  }
}
