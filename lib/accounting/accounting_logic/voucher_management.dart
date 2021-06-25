import 'package:shop/accounting/accounting_logic/transaction_feed.dart';
import 'package:shop/accounting/accounting_logic/voucher_feed.dart';
import 'package:shop/accounting/accounting_logic/voucher_number_model.dart';
import 'package:shop/shared/ValidationException.dart';

class VoucherManagement {
  static Future<void> createVoucher(
      // VoucherFeed voucherFeed,
      // List<TransactionFeed> transactionFeeds,
      ) async {
    // if (!validateTransactionsAmount(transactionFeeds)) {
    //   throw ValidationException(
    //     'VMG01| amount in transactionFeeds are not valid',
    //   );
    // }
    var voucherNumber1 = await VoucherNumberModel.getVoucherNumberAndLock();
    print('VM 01| first time getVNLock $voucherNumber1');
    var voucherNumber2 = await VoucherNumberModel.getVoucherNumberAndLock();
    print('VM 02| second time getVNLock $voucherNumber2');
    await VoucherNumberModel.unlockVoucherNumber(voucherNumber1);
    try {
      await VoucherNumberModel.unlockVoucherNumber(voucherNumber2);
    } catch (e) {
      print(e.toString());
    }
    var voucherNumber3 = await VoucherNumberModel.getVoucherNumberAndLock();
    print('VM 03| third time getVNLock $voucherNumber3');
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
}
