import 'package:shop/accounting/accounting_logic/account_model.dart';

class AccountsId {
  static const MAIN_ACCOUNT_ID = 'main';
  static const LEDGER_ACCOUNT_ID = 'ledger';
  static const EXPENDITURE_ACCOUNT_ID = 'expenditure';
  static const SALES_ACCOUNT_ID = 'sales';
  static const ASSETS_ACCOUNT_ID = 'assets';
  static const BANKS_ACCOUNT_ID = 'banks';
  static const NBO_ACCOUNT_ID = 'nbo';
  static const PETTY_CASH_ACCOUNT_ID = 'petty-cash';
  static const CASH_DRAWER_ACCOUNT_ID = 'cash-drawer';
  static const DEBTORS_ACCOUNT_ID = 'debtors';
  static const LIABILITIES_ACCOUNT_ID = 'liabilities';
}

const ACCOUNTS_TREE = const [
  AccountModel(
    id: AccountsId.LEDGER_ACCOUNT_ID,
    parentId: AccountsId.MAIN_ACCOUNT_ID,
    titleEnglish: 'Ledger Report',
    titleArabic: 'لجر ريبورت',
    titlePersian: 'گزارش گروه های حسابداری',
    note: '',
  ),
  AccountModel(
    id: AccountsId.SALES_ACCOUNT_ID,
    parentId: AccountsId.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Sales',
    titleArabic: 'مبيعات',
    titlePersian: 'فروش',
    note: '',
  ),
  AccountModel(
    id: AccountsId.EXPENDITURE_ACCOUNT_ID,
    parentId: AccountsId.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Expenditure',
    titleArabic: 'مصاريف',
    titlePersian: 'هزینه ها',
    note: '',
  ),
  AccountModel(
    id: AccountsId.ASSETS_ACCOUNT_ID,
    parentId: AccountsId.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Assets',
    titleArabic: 'اصول',
    titlePersian: 'دارایی ها',
    note: '',
  ),
  AccountModel(
    id: AccountsId.BANKS_ACCOUNT_ID,
    parentId: AccountsId.ASSETS_ACCOUNT_ID,
    titleEnglish: AccountsId.BANKS_ACCOUNT_ID,
    titleArabic: 'بنوك',
    titlePersian: 'بانک ها',
    note: '',
  ),
  AccountModel(
    id: AccountsId.NBO_ACCOUNT_ID,
    parentId: AccountsId.BANKS_ACCOUNT_ID,
    titleEnglish: 'NBO Bank',
    titleArabic: 'بنک عمان الوطني',
    titlePersian: 'بانک ان بی او',
    note: '',
  ),
  AccountModel(
    id: AccountsId.PETTY_CASH_ACCOUNT_ID,
    parentId: AccountsId.ASSETS_ACCOUNT_ID,
    titleEnglish: 'Petty Cash',
    titleArabic: 'بتي كش',
    titlePersian: 'تن خواه',
    note: '',
  ),
  AccountModel(
    id: AccountsId.CASH_DRAWER_ACCOUNT_ID,
    parentId: AccountsId.ASSETS_ACCOUNT_ID,
    titleEnglish: 'Cash Drawer',
    titleArabic: 'صندوق',
    titlePersian: 'صندوق',
    note: '',
  ),
  AccountModel(
    id: AccountsId.DEBTORS_ACCOUNT_ID,
    parentId: AccountsId.ASSETS_ACCOUNT_ID,
    titleEnglish: 'Debtors',
    titleArabic: 'بنک عمان الوطني',
    titlePersian: 'المدينين',
    note: '',
  ),
  AccountModel(
    id: AccountsId.LIABILITIES_ACCOUNT_ID,
    parentId: AccountsId.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Liabilities',
    titleArabic: 'بنک عمان الوطني',
    titlePersian: 'الدين الحالي',
    note: '',
  ),
];
