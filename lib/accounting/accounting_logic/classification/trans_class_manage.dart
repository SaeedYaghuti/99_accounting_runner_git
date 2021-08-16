import 'dart:math';

import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/classification/classification_form_fields.dart';
import 'package:shop/accounting/accounting_logic/classification/classification_types.dart';
import 'package:shop/accounting/accounting_logic/classification/transaction_classification.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/expenditure/expenditure_form_fields.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/exceptions/curropted_input.dart';
import 'package:shop/shared/random_string.dart';

class TranClassManagement {
  static Future<TransactionClassification> createTranClassInDB(
    AuthProviderSQL authProvider,
    ClassificationFormFields fields,
  ) async {
    // print('TRN_CLASS_MANAGMENT | createTranClassInDB() 01 | input fields:');
    // print(fields);

    // create unique id
    var uniqueIdIsCreated = false;
    var uniqueId = fields.titleEnglish!.trim().replaceAll(RegExp(' +'), '_').toUpperCase();
    while (!uniqueIdIsCreated) {
      var tranClass = await TransactionClassification.fetchTranClassById(uniqueId);
      if (tranClass == null) {
        // we fetched an id that there is not in db
        uniqueIdIsCreated = false;
        break;
      } else {
        uniqueId += '_' + getRandString(3);
      }
    }

    var tranClass = TransactionClassification(
      id: uniqueId,
      parentId: fields.parentClass!.id!,
      // TODO: we select from list
      classType: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
      titleEnglish: fields.titleEnglish!,
      titlePersian: fields.titlePersian!,
      titleArabic: fields.titleArabic!,
      note: fields.note ?? '_',
    );

    try {
      return await TransactionClassification.insertIntoDB(authProvider, tranClass);
    } on Exception catch (e) {
      print(
        'TRN_CLASS_MANAGMENT | createTranClassInDB() 02 | @ catch error while run TransactionClassification.insertIntoDB() e: $e',
      );
      throw e;
    }
  }

  static Future<TransactionClassification> editTranClassInDB(
    AuthProviderSQL authProvider,
    ClassificationFormFields fields,
  ) async {
    // print('TRN_CLASS_MANAGMENT | editTranClassInDB() 01 | input fields:');
    // print(fields);

    var tranClass = TransactionClassification(
      // TODO: currently id is title, if we change title we can not change the id; they mismatch!
      id: fields.id,
      parentId: fields.parentClass!.id!,
      // TODO: we select from list
      classType: ClassificationTypes.EXPENDITURE_TYPE,
      titleEnglish: fields.titleEnglish!,
      titlePersian: fields.titlePersian!,
      titleArabic: fields.titleArabic!,
      note: fields.note ?? '_',
    );

    try {
      await tranClass.updateMeIntoDB();
      return tranClass;
    } on Exception catch (e) {
      print(
        'TRN_CLASS_MANAGMENT | createTranClassInDB() 02 | @ catch error while run TransactionClassification.insertIntoDB() e: $e',
      );
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
