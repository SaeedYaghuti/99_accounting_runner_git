import 'package:shop/accounting/account/transaction_model.dart';
import 'package:shop/accounting/account/voucher_model.dart';
import 'package:shop/accounting/expenditure/expenditure_form_fields.dart';
import 'package:shop/shared/DBException.dart';

class ExpenditureModel {
  static const EXPENDITURE_ACCOUNT_ID = 'expenditure';

  static Future<void> createExpenditureInDB(ExpenditurFormFields fields) async {
    // DO: we should track voucher number in db; increasig

    // step 1# create voucher
    VoucherModel voucher = VoucherModel(
      voucherNumber: 'vn#001',
      date: fields.date!,
      note: '${fields.paidBy} paid for Expence',
    );
    print('EM01| voucher before save in db >');
    print(voucher);

    try {
      int voucherId = await voucher.insertInDB();
      voucher.id = voucherId;
      print('EM20| voucherId: $voucherId');

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
        int debitTransactionId = await debitTransaction.insertInDB();
        debitTransaction.id = debitTransactionId;
        print('EM21| debitTransactionId: $debitTransactionId');

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
          int creditTransactionId = await creditTransaction.insertInDB();
          creditTransaction.id = creditTransactionId;
          print('EM22| creditTransactionId: $creditTransactionId');

          // End: all steps were successfull
        } catch (e) {
          // do: delete debitTransaction from db
          throw DBException(
            'EM12| Unable to create creditTransaction: e: ${e.toString()}',
          );
        }
      } catch (e) {
        // do: delete voucher from db
        throw DBException(
          'EM11| Unable to create debitTransaction: e: ${e.toString()}',
        );
      }
    } catch (e) {
      throw DBException(
        'EM10| Unable to create voucher: e: ${e.toString()}',
      );
    }
  }
}
