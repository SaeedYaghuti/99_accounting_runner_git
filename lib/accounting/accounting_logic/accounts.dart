import 'package:shop/accounting/accounting_logic/account_model.dart';

class AccountsId {
  static const MAIN_ID = 'main';
  static const LEDGER_ID = 'ledger';
  static const EXPENDITURE_ID = 'expenditure';
  static const SALES_ID = 'sales';
  static const ASSETS_ID = 'assets';
  static const BANKS_ID = 'banks';
  static const NBO_ID = 'nbo';
  static const PETTY_CASH_ID = 'petty-cash';
  static const CASH_DRAWER_ID = 'cash-drawer';
  static const DEBTORS_ID = 'debtors';
  static const LIABILITIES_ID = 'liabilities';
}

const ACCOUNTS_TREE = const [
  AccountModel(
    id: AccountsId.LEDGER_ID,
    parentId: AccountsId.MAIN_ID,
    titleEnglish: 'Ledger Report',
    titleArabic: 'لجر ريبورت',
    titlePersian: 'گزارش گروه های حسابداری',
    note: '',
  ),
  AccountModel(
    id: AccountsId.SALES_ID,
    parentId: AccountsId.LEDGER_ID,
    titleEnglish: 'Sales',
    titleArabic: 'مبيعات',
    titlePersian: 'فروش',
    note: '',
  ),
  AccountModel(
    id: AccountsId.EXPENDITURE_ID,
    parentId: AccountsId.LEDGER_ID,
    titleEnglish: 'Expenditure',
    titleArabic: 'مصاريف',
    titlePersian: 'هزینه ها',
    note: '',
  ),
  AccountModel(
    id: AccountsId.ASSETS_ID,
    parentId: AccountsId.LEDGER_ID,
    titleEnglish: 'Assets',
    titleArabic: 'اصول',
    titlePersian: 'دارایی ها',
    note: '',
  ),
  AccountModel(
    id: AccountsId.BANKS_ID,
    parentId: AccountsId.ASSETS_ID,
    titleEnglish: AccountsId.BANKS_ID,
    titleArabic: 'بنوك',
    titlePersian: 'بانک ها',
    note: '',
  ),
  AccountModel(
    id: AccountsId.NBO_ID,
    parentId: AccountsId.BANKS_ID,
    titleEnglish: 'NBO Bank',
    titleArabic: 'بنک عمان الوطني',
    titlePersian: 'بانک ان بی او',
    note: '',
  ),
  AccountModel(
    id: AccountsId.PETTY_CASH_ID,
    parentId: AccountsId.ASSETS_ID,
    titleEnglish: 'Petty Cash',
    titleArabic: 'بتي كش',
    titlePersian: 'تن خواه',
    note: '',
  ),
  AccountModel(
    id: AccountsId.CASH_DRAWER_ID,
    parentId: AccountsId.ASSETS_ID,
    titleEnglish: 'Cash Drawer',
    titleArabic: 'صندوق',
    titlePersian: 'صندوق',
    note: '',
  ),
  AccountModel(
    id: AccountsId.DEBTORS_ID,
    parentId: AccountsId.ASSETS_ID,
    titleEnglish: 'Debtors',
    titleArabic: 'بنک عمان الوطني',
    titlePersian: 'المدينين',
    note: '',
  ),
  AccountModel(
    id: AccountsId.LIABILITIES_ID,
    parentId: AccountsId.LEDGER_ID,
    titleEnglish: 'Liabilities',
    titleArabic: 'بنک عمان الوطني',
    titlePersian: 'الدين الحالي',
    note: '',
  ),
];
