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
  ),
  AccountModel(
    id: ACCOUNTS_ID.SALES_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Sales',
    titleArabic: 'مبيعات',
    titlePersian: 'فروش',
    note: '',
  ),
  AccountModel(
    id: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Expenditure',
    titleArabic: 'مصاريف',
    titlePersian: 'هزینه ها',
    note: '',
  ),
  AccountModel(
    id: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Assets',
    titleArabic: 'اصول',
    titlePersian: 'دارایی ها',
    note: '',
  ),
  AccountModel(
    id: ACCOUNTS_ID.BANKS_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    titleEnglish: ACCOUNTS_ID.BANKS_ACCOUNT_ID,
    titleArabic: 'بنوك',
    titlePersian: 'بانک ها',
    note: '',
  ),
  AccountModel(
    id: ACCOUNTS_ID.NBO_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.BANKS_ACCOUNT_ID,
    titleEnglish: 'NBO Bank',
    titleArabic: 'بنک عمان الوطني',
    titlePersian: 'بانک ان بی او',
    note: '',
  ),
  AccountModel(
    id: ACCOUNTS_ID.PETTY_CASH_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    titleEnglish: 'Petty Cash',
    titleArabic: 'بتي كش',
    titlePersian: 'تن خواه',
    note: '',
  ),
  AccountModel(
    id: ACCOUNTS_ID.CASH_DRAWER_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    titleEnglish: 'Cash Drawer',
    titleArabic: 'صندوق',
    titlePersian: 'صندوق',
    note: '',
  ),
  AccountModel(
    id: ACCOUNTS_ID.DEBTORS_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    titleEnglish: 'Debtors',
    titleArabic: 'بنک عمان الوطني',
    titlePersian: 'المدينين',
    note: '',
  ),
  AccountModel(
    id: ACCOUNTS_ID.LIABILITIES_ACCOUNT_ID,
    parentId: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Liabilities',
    titleArabic: 'بنک عمان الوطني',
    titlePersian: 'الدين الحالي',
    note: '',
  ),
];
