import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/classification/classification_form_fields.dart';
import 'package:shop/accounting/accounting_logic/classification/transaction_classification.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/expenditure/expenditure_form_fields.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/exceptions/curropted_input.dart';

class TranClassManagement {
  static Future<void> createTranClassInDB(AuthProviderSQL authProvider, ClassificationFormFields fields) async {
    var tranClass = TransactionClassification(
      id: fields.id,
      parentId: fields.parentClass!.parentId,
      // TODO: we select from list
      accountType: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
      titleEnglish: fields.titleEnglish!,
      titlePersian: fields.titlePersian!,
      titleArabic: fields.titleArabic!,
      note: fields.note ?? '_',
    );

    try {
      await TransactionClassification.insertIntoDB(authProvider, tranClass);
    } on Exception catch (e) {
      print(
          'TRN_CLASS_MANAGMENT | createTranClassInDB() 01 | @ catch error while run TransactionClassification.insertIntoDB() e: $e');
      throw e;
    }
  }

  static Future<List<VoucherModel?>> expenditureVouchers(
    AuthProviderSQL authProvider,
  ) {
    // print('TRN_CLASS_MANAGMENT | expenditureVouchers()');
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
    // print('TRN_CLASS_MANAGMENT updateVoucher()| 01 | oldVoucher: $oldVoucher');
    // print('TRN_CLASS_MANAGMENT updateVoucher()| 02 | fields: $fields');
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
      note: '${fields.paidByAccount!.titleEnglish} paid for Expenditure',
    );
    newVoucher.transactions = [
      // updated debit transaction
      TransactionModel(
        accountId: fields.paidByAccount!.id,
        voucherId: oldVoucher.id!,
        amount: fields.amount!,
        isDebit: true,
        date: fields.date!,
        note: fields.note!,
        tranClass: fields.expClass!,
        floatAccount: fields.floatAccount!,
      ),
      // updated credit transaction
      TransactionModel(
        accountId: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
        voucherId: oldVoucher.id!,
        amount: fields.amount!,
        isDebit: false,
        date: fields.date!,
        note: fields.note!,
        tranClass: fields.expClass!,
        floatAccount: fields.floatAccount!,
      ),
    ];

    // print('TRN_CLASS_MANAGMENT |  43| new Voucher to be updated at db');
    // print(newVoucher);
    try {
      await VoucherModel.updateVoucher(newVoucher, authProvider);
    } catch (e) {
      print('EM 43| updateVoucher() |@ catch e: $e');
      throw e;
    }
  }
}