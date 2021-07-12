import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/auth/auth_model_sql.dart';
import 'package:shop/auth/permission_model.dart';

import 'account_ids.dart';

void runCode() async {
  // await VoucherModel.fetchAllVouchers();
  // await TransactionModel.allTransactions();
  // await TransactionModel.allTranJoinVch();
  // await TransactionModel.allTranJoinVchForAccount('expenditure');
  // await VoucherManagement.createVoucher();
  // await VoucherModel.maxVoucherNumber();
  // await VoucherModel.accountVouchers('expenditure');
  // await VoucherModel.fetchAllVouchers();
  // print('PRAGMA foreign_keys > $resault');
  var muscat = AccountModel(
    id: 'AMERICAN_EXPRESS',
    parentId: ACCOUNTS_ID.BANKS_ACCOUNT_ID,
    titleEnglish: 'american experess',
    titleArabic: 'امريكن اكسبرس',
    titlePersian: 'امريكن اكسبرس',
    note: '٤٥٧٠٣٣١٣٤٠٦٠',
    createTransactionPermissionsAny: [],
    readTransactionPermissionsAny: [],
    editTransactionPermissionsAny: [],
    deleteTransactionPermissionsAny: [],
  );

  await AccountModel.allAccounts();

  var insertResut = await muscat.insertMeIntoDB();
  print(insertResut);

  await AccountModel.allAccounts();

  // var deleteResut = await muscat.deleteMeFromDB();
  // print(deleteResut);

  // await AccountModel.allAccounts();

  // await AccountModel.fetchAccountById('MUSCAT_BANK');
}
