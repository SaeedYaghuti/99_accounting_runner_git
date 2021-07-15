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
  // var auth = AuthModel();
  // var result = await auth.validateUser(SAEIDEMAIL, SAEIDPASSWORD);
  // var isPermitted = auth.hasPermission(PermissionModel.EXPENDITURE_CATEGORY);
  // print('auth runCode 01| isPermitted: $isPermitted');
  AuthModel.printAllAuth();
  // AuthPermissionModel.printAllAuthPermissions();
  AuthPermissionModel.givePermissionsToAuth(
    2,
    [
      PermissionModel.EXPENDITURE_CATEGORY,
      PermissionModel.EXPENDITURE_CREATE_TRANSACTION,
    ],
  );

  // var muscatTrandCreate = PermissionModel(
  //   id: 'MUSCAT_CREATE_TRANSACTION',
  //   titleEnglish: 'MUSCAT BANK CREATE TRANSACTION PERMISSION !!!',
  //   titlePersian: 'ساخت تراكنش جديد براي بانك مسقط',
  //   titleArabic: 'ايجاد فاتورة حق مسقط بنك',
  // );

  // await PermissionModel.allPermissions();
  // await muscatTrandCreate.insertMeIntoDB();
  // await PermissionModel.allPermissions();

  // var permC = await PermissionModel.fetchPermissionById(
  //     'AMERICAN_EXPRESS_CREATE_TRANSACTION');
  // var permRA = await PermissionModel.fetchPermissionById(
  //     'AMERICAN_EXPRESS_READ_ALL_TRANSACTION');
  // var permROwn = await PermissionModel.fetchPermissionById(
  //     'AMERICAN_EXPRESS_READ_OWN_TRANSACTION');
  // var permEA = await PermissionModel.fetchPermissionById(
  //     'AMERICAN_EXPRESS_EDIT_ALL_TRANSACTION');
  // var permEO = await PermissionModel.fetchPermissionById(
  //     'AMERICAN_EXPRESS_EDIT_OWN_TRANSACTION');
  // var permDA = await PermissionModel.fetchPermissionById(
  //     'AMERICAN_EXPRESS_DELETE_ALL_TRANSACTION');
  // var permDO = await PermissionModel.fetchPermissionById(
  //     'AMERICAN_EXPRESS_DELETE_OWN_TRANSACTION');
  // print(perm);
  // await muscatTrandCreate.deleteMeFromDB();
}
