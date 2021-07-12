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
    note: '',
    createTransactionPermissionsAny: [
      PermissionModel.LEDGER_CREATE_TRANSACTION_X
    ],
    readTransactionPermissionsAny: [
      PermissionModel.LEDGER_READ_ALL_TRANSACTION
    ],
    editTransactionPermissionsAny: [],
    deleteTransactionPermissionsAny: [],
  ),
  AccountModel(
    id: ACCOUNTS_ID.SALES_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Sales',
    titleArabic: 'مبيعات',
    titlePersian: 'فروش',
    note: '',
    createTransactionPermissionsAny: [
      PermissionModel.SALES_CREATE_TRANSACTION_X
    ],
    readTransactionPermissionsAny: [PermissionModel.SALES_READ_ALL_TRANSACTION],
    editTransactionPermissionsAny: [],
    deleteTransactionPermissionsAny: [],
  ),
  AccountModel(
    id: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Expenditure',
    titleArabic: 'مصاريف',
    titlePersian: 'هزینه ها',
    note: '',
    createTransactionPermissionsAny: [
      PermissionModel.EXPENDITURE_CREATE_TRANSACTION,
    ],
    readTransactionPermissionsAny: [
      PermissionModel.EXPENDITURE_READ_ALL_TRANSACTION,
      PermissionModel.EXPENDITURE_READ_OWN_TRANSACTION,
    ],
    editTransactionPermissionsAny: [
      PermissionModel.EXPENDITURE_EDIT_ALL_TRANSACTION,
      PermissionModel.EXPENDITURE_EDIT_OWN_TRANSACTION,
    ],
    deleteTransactionPermissionsAny: [
      PermissionModel.EXPENDITURE_DELETE_ALL_TRANSACTION,
      PermissionModel.EXPENDITURE_DELETE_OWN_TRANSACTION,
    ],
  ),
  AccountModel(
    id: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Assets',
    titleArabic: 'اصول',
    titlePersian: 'دارایی ها',
    note: '',
    createTransactionPermissionsAny: [
      PermissionModel.ASSETS_CREATE_TRANSACTION_X
    ],
    readTransactionPermissionsAny: [
      PermissionModel.ASSETS_READ_ALL_TRANSACTION
    ],
    editTransactionPermissionsAny: [],
    deleteTransactionPermissionsAny: [],
  ),
  AccountModel(
    id: ACCOUNTS_ID.BANKS_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    titleEnglish: ACCOUNTS_ID.BANKS_ACCOUNT_ID,
    titleArabic: 'بنوك',
    titlePersian: 'بانک ها',
    note: '',
    createTransactionPermissionsAny: [
      PermissionModel.BANKS_CREATE_TRANSACTION_X
    ],
    readTransactionPermissionsAny: [PermissionModel.BANKS_READ_ALL_TRANSACTION],
    editTransactionPermissionsAny: [],
    deleteTransactionPermissionsAny: [],
  ),
  AccountModel(
    id: ACCOUNTS_ID.NBO_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.BANKS_ACCOUNT_ID,
    titleEnglish: 'NBO Bank',
    titleArabic: 'بنک عمان الوطني',
    titlePersian: 'بانک ان بی او',
    note: '',
    createTransactionPermissionsAny: [
      PermissionModel.NBO_CREATE_TRANSACTION,
    ],
    readTransactionPermissionsAny: [
      PermissionModel.NBO_READ_ALL_TRANSACTION,
      PermissionModel.NBO_READ_OWN_TRANSACTION,
    ],
    editTransactionPermissionsAny: [
      PermissionModel.NBO_EDIT_ALL_TRANSACTION,
      PermissionModel.NBO_EDIT_OWN_TRANSACTION,
    ],
    deleteTransactionPermissionsAny: [
      PermissionModel.NBO_DELETE_ALL_TRANSACTION,
      PermissionModel.NBO_DELETE_OWN_TRANSACTION,
    ],
  ),
  AccountModel(
    id: ACCOUNTS_ID.PETTY_CASH_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    titleEnglish: 'Petty Cash',
    titleArabic: 'بتي كش',
    titlePersian: 'تن خواه',
    note: '',
    createTransactionPermissionsAny: [
      PermissionModel.PETTY_CASH_CREATE_TRANSACTION,
    ],
    readTransactionPermissionsAny: [
      PermissionModel.PETTY_CASH_READ_ALL_TRANSACTION,
      PermissionModel.PETTY_CASH_READ_OWN_TRANSACTION,
    ],
    editTransactionPermissionsAny: [
      PermissionModel.PETTY_CASH_EDIT_ALL_TRANSACTION,
      PermissionModel.PETTY_CASH_EDIT_OWN_TRANSACTION,
    ],
    deleteTransactionPermissionsAny: [
      PermissionModel.PETTY_CASH_DELETE_ALL_TRANSACTION,
      PermissionModel.PETTY_CASH_DELETE_OWN_TRANSACTION,
    ],
  ),
  AccountModel(
    id: ACCOUNTS_ID.CASH_DRAWER_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    titleEnglish: 'Cash Drawer',
    titleArabic: 'صندوق',
    titlePersian: 'صندوق',
    note: '',
    createTransactionPermissionsAny: [
      PermissionModel.CASH_DRAWER_CREATE_TRANSACTION,
    ],
    readTransactionPermissionsAny: [
      PermissionModel.CASH_DRAWER_READ_ALL_TRANSACTION,
      PermissionModel.CASH_DRAWER_READ_OWN_TRANSACTION,
    ],
    editTransactionPermissionsAny: [
      PermissionModel.CASH_DRAWER_EDIT_ALL_TRANSACTION,
      PermissionModel.CASH_DRAWER_EDIT_OWN_TRANSACTION,
    ],
    deleteTransactionPermissionsAny: [
      PermissionModel.CASH_DRAWER_DELETE_ALL_TRANSACTION,
      PermissionModel.CASH_DRAWER_DELETE_OWN_TRANSACTION,
    ],
  ),
  AccountModel(
    id: ACCOUNTS_ID.DEBTORS_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    titleEnglish: 'Debtors',
    titleArabic: 'بدهكاران',
    titlePersian: 'المدينين',
    note: '',
    createTransactionPermissionsAny: [
      PermissionModel.DEBTORS_CREATE_TRANSACTION_X
    ],
    readTransactionPermissionsAny: [
      PermissionModel.DEBTORS_READ_ALL_TRANSACTION
    ],
    editTransactionPermissionsAny: [],
    deleteTransactionPermissionsAny: [],
  ),
  AccountModel(
    id: ACCOUNTS_ID.LIABILITIES_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Liabilities',
    titleArabic: 'بستانكاران',
    titlePersian: 'الدين الحالي',
    note: '',
    createTransactionPermissionsAny: [
      PermissionModel.LIABILITIES_CREATE_TRANSACTION_X
    ],
    readTransactionPermissionsAny: [
      PermissionModel.LIABILITIES_READ_ALL_TRANSACTION
    ],
    editTransactionPermissionsAny: [],
    deleteTransactionPermissionsAny: [],
  ),
];
