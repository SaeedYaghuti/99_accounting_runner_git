import 'package:shop/accounting/accounting_logic/transaction_feed.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_feed.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_number_model.dart';
import 'package:shop/accounting/accounting_logic/DBException.dart';
import 'package:shop/shared/ValidationException.dart';
import 'package:shop/accounting/accounting_logic/voucher_exception.dart';

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

    // step 2# borrow voucherNumber
    var voucherNumber;
    try {
      voucherNumber = await VoucherNumberModel.borrowNumber();
      // print('V_MG 03| voucherNumber: $voucherNumber');

    } catch (e) {
      print('V_MG 04| voucherNumber: $e');
      print('V_MG 04| we did VoucherNumberModel.reset() try again!');
      await VoucherNumberModel.reset();
      throw e;
    }

    // step 3# create voucher
    VoucherModel voucher = VoucherModel(
      voucherNumber: voucherNumber,
      date: voucherFeed.date,
      note: makeVoucherNote(transactionFeeds),
    );
    // print('V_MG 07| voucher before save in db >');
    // print(voucher);

    try {
      await voucher.insertMeInDB();
    } catch (e) {
      await VoucherNumberModel.numberNotConsumed(voucherNumber);
      throw DBException(
        'V_MG 10| Unable to create voucher: e: ${e.toString()}',
      );
    }

    // step 4# create transactions
    List<TransactionModel> successTransactions = [];

    for (var feed in transactionFeeds) {
      var transaction = TransactionModel(
        accountId: feed.accountId,
        voucherId: voucher.id!,
        amount: feed.amount,
        isDebit: feed.isDebit,
        date: feed.date,
        note: feed.note,
      );
      try {
        await transaction.insertTransactionToDB();
        successTransactions.add(transaction);
      } catch (e) {
        // delete all transactions and voucher
        try {
          await voucher.deleteMeFromDB();
          for (var transaction in successTransactions) {
            await transaction.deleteMeFromDB();
          }
        } catch (e) {
          // we have dirty data in voucher or transactions
          // do log at error_log ...
          throw VoucherException(
            'V_MG 13| We have dirty data at voucher or transactions table',
          );
        }
        throw VoucherException(
          'V_MG 16| Voucher did not saved at db!  we do not have dirty data at db e: ${e.toString()}',
        );
      }
    }
    // step #5 voucher has mad Successfully
    await VoucherNumberModel.numberConsumed(voucherNumber);
    print('V_MG 19| voucher and all its transactions saved Successfully!');

    // TODO: remove me
    await voucher.fetchMyTransactions();
  }

  static Future<void> updateVoucher(
    VoucherFeed voucherFeed,
    List<TransactionFeed> transactionFeeds,
  ) async {
    // step 1# validate amount
    if (!validateTransactionsAmount(transactionFeeds)) {
      throw ValidationException(
        'V_MG 30| amount in transactionFeeds are not valid',
      );
    }

    // step 2# we should have voucher with voucher_id and voucher_number
    VoucherModel.

    // step 2# borrow voucherNumber
    var voucherNumber;
    try {
      voucherNumber = await VoucherNumberModel.borrowNumber();
      // print('V_MG 03| voucherNumber: $voucherNumber');

    } catch (e) {
      print('V_MG 04| voucherNumber: $e');
      print('V_MG 04| we did VoucherNumberModel.reset() try again!');
      await VoucherNumberModel.reset();
      throw e;
    }

    // step 3# create voucher
    VoucherModel voucher = VoucherModel(
      voucherNumber: voucherNumber,
      date: voucherFeed.date,
      note: makeVoucherNote(transactionFeeds),
    );
    // print('V_MG 07| voucher before save in db >');
    // print(voucher);

    try {
      await voucher.insertMeInDB();
    } catch (e) {
      await VoucherNumberModel.numberNotConsumed(voucherNumber);
      throw DBException(
        'V_MG 10| Unable to create voucher: e: ${e.toString()}',
      );
    }

    // step 4# create transactions
    List<TransactionModel> successTransactions = [];

    for (var feed in transactionFeeds) {
      var transaction = TransactionModel(
        accountId: feed.accountId,
        voucherId: voucher.id!,
        amount: feed.amount,
        isDebit: feed.isDebit,
        date: feed.date,
        note: feed.note,
      );
      try {
        await transaction.insertTransactionToDB();
        successTransactions.add(transaction);
      } catch (e) {
        // delete all transactions and voucher
        try {
          await voucher.deleteMeFromDB();
          for (var transaction in successTransactions) {
            await transaction.deleteMeFromDB();
          }
        } catch (e) {
          // we have dirty data in voucher or transactions
          // do log at error_log ...
          throw VoucherException(
            'V_MG 13| We have dirty data at voucher or transactions table',
          );
        }
        throw VoucherException(
          'V_MG 16| Voucher did not saved at db!  we do not have dirty data at db e: ${e.toString()}',
        );
      }
    }
    // step #5 voucher has mad Successfully
    await VoucherNumberModel.numberConsumed(voucherNumber);
    print('V_MG 19| voucher and all its transactions saved Successfully!');

    // TODO: remove me
    await voucher.fetchMyTransactions();
  }

  static bool validateTransactionsAmount(List<TransactionFeed> feeds) {
    var totalDebit = 0.0;
    var totalCredit = 0.0;

    for (var feed in feeds) {
      // maybe redundent
      if (feed.amount < 0.0) {
        return false;
      }
      // maybe redundent
      if (feed.amount == 0.0) {
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
