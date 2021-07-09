import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/auth/auth_model_sql.dart';
import 'package:shop/auth/auth_permission_model.dart';
import 'package:shop/auth/permission_model.dart';
import 'package:shop/constants.dart';

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
  // var result = await auth.validateUser(SAEIDEMAIL, SAEIDPASSWORD);
  // var isPermitted = auth.hasPermission(PermissionModel.EXPENDITURE_CATEGORY);
  // print('auth runCode 01| isPermitted: $isPermitted');
  // AuthModel.printAllAuth();
  // AuthPermissionModel.printAllAuthPermissions();
  AuthPermissionModel.givePermissionsToAuth(
    2,
    PermissionModel.EXPENDITURE_CATEGORY,
  );
  AuthPermissionModel.givePermissionsToAuth(
    2,
    PermissionModel.EXPENDITURE_CREATE,
  );
  // AuthPermissionModel.givePermissionsToAuth(
  //   2,
  //   PermissionModel.EXPENDITURE_EDIT_OWN,
  // );
}
