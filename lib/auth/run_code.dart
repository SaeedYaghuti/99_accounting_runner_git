import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/auth/auth_model.dart';

void runCode() async {
  // await VoucherModel.fetchAllVouchers();
  // await TransactionModel.allTransactions();
  // await TransactionModel.allTranJoinVch();
  // await TransactionModel.allTranJoinVchForAccount('expenditure');
  // await VoucherManagement.createVoucher();
  // await VoucherModel.maxVoucherNumber();
  // await VoucherModel.accountVouchers('expenditure');
  // await VoucherModel.fetchAllVouchers();
  // var resault = await AccountingDB.runRawQuery('PRAGMA foreign_keys');
  // print('PRAGMA foreign_keys > $resault');
  var auth = AuthModel();
  // var result = auth.createNewUserInDB('saeid', '123456');
  auth.fetchUserById(1);
}
