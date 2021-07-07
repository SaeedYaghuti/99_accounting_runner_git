import 'package:shop/accounting/accounting_logic/transaction_feed.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_feed.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_number_model.dart';
import 'package:shop/exceptions/DBException.dart';
import 'package:shop/exceptions/curropted_input.dart';
import 'package:shop/exceptions/db_operation.dart';
import 'package:shop/exceptions/dirty_database.dart';
import 'package:shop/exceptions/lazy_saeid.dart';
import 'package:shop/shared/ValidationException.dart';
import 'package:shop/exceptions/voucher_exception.dart';

class XVoucherManagement {
  static Future<void> createVoucher(
    VoucherFeed voucherFeed,
    List<TransactionFeed> transactionFeeds,
  ) async {
    // step 1# validate data
    if (!validateTransactionFeedsAmount(transactionFeeds)) {
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
        await transaction.insertMeIntoDB();
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

  static Future<void> updateVoucher(VoucherModel rVoucher) async {
    // step 1# validate amount
    if (!validateTransactionModelsAmount(rVoucher.transactions)) {
      throw ValidationException(
        'V_MG 30| amount in transactionFeeds are not valid',
      );
    }
    if (rVoucher.id == null || rVoucher.voucherNumber == null) {
      throw CurroptedInputException('VM 31| rVoucher is not valid voucher!');
    }

    // step 2# fetch voucher by id
    var fVoucher = await VoucherModel.fetchVoucherById(rVoucher.id!);

    // step 3# chack validity
    if (fVoucher == null) {
      throw CurroptedInputException(
          'VM 32| there is not voucher in db with id ${rVoucher.id}!');
    }
    if (fVoucher.voucherNumber != rVoucher.voucherNumber) {
      throw CurroptedInputException(
        'VM 33| there is not voucher in db with id:${rVoucher.id} and voucherNumber: ${rVoucher.voucherNumber}; voucherNumber could not be updated!',
      );
    }

    // step 4# remove old transactions from db: we rebuild all transaction in update
    List<TransactionModel> successfullDeleted = [];

    for (var tran in fVoucher.transactions) {
      if (tran == null) break;
      try {
        await tran.deleteMeFromDB();
        successfullDeleted.add(tran);
      } catch (e) {
        // if couldn't delete any tran we should recreate deleted tran
        try {
          for (var transaction in successfullDeleted) {
            if (transaction == null) break;
            await tran.insertMeIntoDB();
          }
          throw DBOperationException(
            'VM 35| unsuccessful update vouchr: ${fVoucher.id}! there is no dirty data in db',
          );
        } catch (e) {
          // do log
          // ...
          throw DirtyDatabaseException(
            'VM 34| There is Dirty transaction in vouchr: ${fVoucher.id}',
          );
        }
      }
    }

    // step #5 recreate new transactions
    List<TransactionModel> successTransactions = [];

    for (var transaction in rVoucher.transactions) {
      try {
        await transaction!.insertMeIntoDB();
        successTransactions.add(transaction);
      } catch (e) {
        // unable to build all new transactions:
        try {
          // step #a delete successTransactions
          for (var transaction in successTransactions) {
            await transaction.deleteMeFromDB();
          }
          // step #b recreate old transactions
          for (var transaction in fVoucher.transactions) {
            await transaction!.insertMeIntoDB();
          }

          // strp #c notify update problem; without dirty data
          throw DBOperationException(
            'VM 36| unsuccessful update vouchr: ${fVoucher.id}! there is no dirty data in db',
          );
        } catch (e) {
          // we have dirty data in voucher or transactions
          // do log at error_log ...
          throw DirtyDatabaseException(
            'V_MG 35| We have dirty data at voucher ${rVoucher.id}',
          );
        }
      }
    }

    // step #6 update voucher at db
    try {
      await rVoucher.updateMeWithoutTransactionsInDB();
    } catch (e) {
      throw LazySaeidException(
        'VM UP39| rVoucher not updated successfuly; And Saeid did not handle this situation',
      );
    }
  }

  static bool validateTransactionFeedsAmount(List<TransactionFeed> feeds) {
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

  static bool validateTransactionModelsAmount(
      List<TransactionModel?> transactions) {
    var totalDebit = 0.0;
    var totalCredit = 0.0;

    // at least we should have 2 transactions
    if (transactions.length < 2) return false;

    for (var tran in transactions) {
      if (tran == null) return false;
      // maybe redundent
      if (tran.amount < 0.0) {
        return false;
      }
      // maybe redundent
      if (tran.amount == 0.0) {
        return false;
      }
      if (tran.isDebit) {
        totalDebit += tran.amount;
      } else {
        totalCredit += tran.amount;
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
