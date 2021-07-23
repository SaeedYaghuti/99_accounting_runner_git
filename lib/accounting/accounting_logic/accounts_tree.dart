import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/auth/permission_model.dart';

import 'account_ids.dart';

const ACCOUNTS_TREE = const [
  AccountModel(
    id: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.MAIN_ACCOUNT_ID,
    titleEnglish: 'Ledger Report',
    titleArabic: 'لجر ريبورت',
    titlePersian: 'گزارش گروه های حسابداری',
    note: '_',
    createTransactionPermission: null,
    readAllTransactionPermission: PermissionModel.LEDGER_READ_ALL_TRANSACTION,
    readOwnTransactionPermission: null,
    editAllTransactionPermission: null,
    deleteAllTransactionPermission: null,
  ),
  AccountModel(
    id: ACCOUNTS_ID.SALES_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Sales',
    titleArabic: 'مبيعات',
    titlePersian: 'فروش',
    note: '_',
    createTransactionPermission: null,
    readAllTransactionPermission: PermissionModel.SALES_READ_ALL_TRANSACTION,
    readOwnTransactionPermission: null,
    editAllTransactionPermission: null,
    deleteAllTransactionPermission: null,
  ),
  AccountModel(
    id: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Expenditure',
    titleArabic: 'مصاريف',
    titlePersian: 'هزینه ها',
    note: '_',
    createTransactionPermission: PermissionModel.EXPENDITURE_CREATE_TRANSACTION,
    readAllTransactionPermission:
        PermissionModel.EXPENDITURE_READ_ALL_TRANSACTION,
    readOwnTransactionPermission:
        PermissionModel.EXPENDITURE_READ_OWN_TRANSACTION,
    editAllTransactionPermission:
        PermissionModel.EXPENDITURE_EDIT_ALL_TRANSACTION,
    editOwnTransactionPermission:
        PermissionModel.EXPENDITURE_EDIT_OWN_TRANSACTION,
    deleteAllTransactionPermission:
        PermissionModel.EXPENDITURE_DELETE_ALL_TRANSACTION,
    deleteOwnTransactionPermission:
        PermissionModel.EXPENDITURE_DELETE_OWN_TRANSACTION,
  ),
  AccountModel(
    id: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Assets',
    titleArabic: 'اصول',
    titlePersian: 'دارایی ها',
    note: '_',
    createTransactionPermission: null,
    readAllTransactionPermission: PermissionModel.ASSETS_READ_ALL_TRANSACTION,
    readOwnTransactionPermission: null,
    editAllTransactionPermission: null,
    deleteAllTransactionPermission: null,
  ),
  AccountModel(
    id: ACCOUNTS_ID.BANKS_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    titleEnglish: ACCOUNTS_ID.BANKS_ACCOUNT_ID,
    titleArabic: 'بنوك',
    titlePersian: 'بانک ها',
    note: '_',
    createTransactionPermission: null,
    readAllTransactionPermission: PermissionModel.BANKS_READ_ALL_TRANSACTION,
    readOwnTransactionPermission: null,
    editAllTransactionPermission: null,
    deleteAllTransactionPermission: null,
  ),
  AccountModel(
    id: ACCOUNTS_ID.NBO_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.BANKS_ACCOUNT_ID,
    titleEnglish: 'NBO Bank',
    titleArabic: 'بنک عمان الوطني',
    titlePersian: 'بانک ان بی او',
    note: '_',
    createTransactionPermission: PermissionModel.NBO_CREATE_TRANSACTION,
    readAllTransactionPermission: PermissionModel.NBO_READ_ALL_TRANSACTION,
    readOwnTransactionPermission: PermissionModel.NBO_READ_OWN_TRANSACTION,
    editAllTransactionPermission: PermissionModel.NBO_EDIT_ALL_TRANSACTION,
    editOwnTransactionPermission: PermissionModel.NBO_EDIT_OWN_TRANSACTION,
    deleteAllTransactionPermission: PermissionModel.NBO_DELETE_ALL_TRANSACTION,
    deleteOwnTransactionPermission: PermissionModel.NBO_DELETE_OWN_TRANSACTION,
  ),
  AccountModel(
    id: ACCOUNTS_ID.PETTY_CASH_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    titleEnglish: 'Petty Cash',
    titleArabic: 'بتي كش',
    titlePersian: 'تن خواه',
    note: '_',
    createTransactionPermission: PermissionModel.PETTY_CASH_CREATE_TRANSACTION,
    readAllTransactionPermission:
        PermissionModel.PETTY_CASH_READ_ALL_TRANSACTION,
    readOwnTransactionPermission:
        PermissionModel.PETTY_CASH_READ_OWN_TRANSACTION,
    editAllTransactionPermission:
        PermissionModel.PETTY_CASH_EDIT_ALL_TRANSACTION,
    editOwnTransactionPermission:
        PermissionModel.PETTY_CASH_EDIT_OWN_TRANSACTION,
    deleteAllTransactionPermission:
        PermissionModel.PETTY_CASH_DELETE_ALL_TRANSACTION,
    deleteOwnTransactionPermission:
        PermissionModel.PETTY_CASH_DELETE_OWN_TRANSACTION,
  ),
  AccountModel(
    id: ACCOUNTS_ID.CASH_DRAWER_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    titleEnglish: 'Cash Drawer',
    titleArabic: 'صندوق',
    titlePersian: 'صندوق',
    note: '_',
    createTransactionPermission: PermissionModel.CASH_DRAWER_CREATE_TRANSACTION,
    readAllTransactionPermission:
        PermissionModel.CASH_DRAWER_READ_ALL_TRANSACTION,
    readOwnTransactionPermission:
        PermissionModel.CASH_DRAWER_READ_OWN_TRANSACTION,
    editAllTransactionPermission:
        PermissionModel.CASH_DRAWER_EDIT_ALL_TRANSACTION,
    editOwnTransactionPermission:
        PermissionModel.CASH_DRAWER_EDIT_OWN_TRANSACTION,
    deleteAllTransactionPermission:
        PermissionModel.CASH_DRAWER_DELETE_ALL_TRANSACTION,
    deleteOwnTransactionPermission:
        PermissionModel.CASH_DRAWER_DELETE_OWN_TRANSACTION,
  ),
  AccountModel(
    id: ACCOUNTS_ID.DEBTORS_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    titleEnglish: 'Debtors',
    titleArabic: 'بدهكاران',
    titlePersian: 'المدينين',
    note: '_',
    createTransactionPermission: null,
    readAllTransactionPermission: PermissionModel.DEBTORS_READ_ALL_TRANSACTION,
    readOwnTransactionPermission: null,
    editAllTransactionPermission: null,
    deleteAllTransactionPermission: null,
  ),
  AccountModel(
    id: ACCOUNTS_ID.LIABILITIES_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Liabilities',
    titleArabic: 'بستانكاران',
    titlePersian: 'الدين الحالي',
    note: '_',
    createTransactionPermission: null,
    readAllTransactionPermission:
        PermissionModel.LIABILITIES_READ_ALL_TRANSACTION,
    readOwnTransactionPermission: null,
    editAllTransactionPermission: null,
    deleteAllTransactionPermission: null,
  ),
];

bool isParent(String accountId) {
  return ACCOUNTS_TREE.any((account) => account.parentId == accountId);
}

List<AccountModel> childs(String accountId) {
  return ACCOUNTS_TREE
      .where((account) => account.parentId == accountId)
      .toList();
}
