class ACCOUNTS_ID {
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

var payerAccounts = [
  // ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID, // expenditure can not pay for expenditure
  // ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
  ACCOUNTS_ID.CASH_DRAWER_ACCOUNT_ID,
  ACCOUNTS_ID.NBO_ACCOUNT_ID,
  ACCOUNTS_ID.PETTY_CASH_ACCOUNT_ID,
  ACCOUNTS_ID.SALES_ACCOUNT_ID,
  ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
  ACCOUNTS_ID.BANKS_ACCOUNT_ID,
  ACCOUNTS_ID.DEBTORS_ACCOUNT_ID,
  ACCOUNTS_ID.LIABILITIES_ACCOUNT_ID,
];
