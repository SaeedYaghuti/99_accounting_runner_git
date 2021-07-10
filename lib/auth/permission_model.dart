class PermissionModel {
  final String id;
  final String titleEnglish;
  final String titlePersian;
  final String titleArabic;
  final String note;

  const PermissionModel({
    required this.id,
    required this.titleEnglish,
    required this.titlePersian,
    required this.titleArabic,
    this.note = '',
  });

  static const String tableName = 'permissions';
  static const String column1Id = 'permission_id';
  static const String column2TitleEnglish = 'permission_title_english';
  static const String column3TitlePersian = 'permission_title_persian';
  static const String column4TitleArabic = 'permission_title_arabic';
  static const String column5Note = 'permission_note';

  static const String QUERY_CREATE_PERMISSION_TABLE =
      '''CREATE TABLE $tableName (
    $column1Id TEXT PRIMARY KEY, 
    $column2TitleEnglish TEXT, 
    $column3TitlePersian TEXT, 
    $column4TitleArabic TEXT, 
    $column5Note TEXT
  )''';

  Map<String, Object> toMap() {
    return {
      column1Id: id,
      column2TitleEnglish: titleEnglish,
      column3TitlePersian: titlePersian,
      column4TitleArabic: titleArabic,
      column5Note: note,
    };
  }

  String toString() {
    return '''
    $column1Id: $id, 
    $column2TitleEnglish: $titleEnglish,
    $column3TitlePersian: $titlePersian,
    $column4TitleArabic: $titleArabic,
    $column5Note: $note,
    ''';
  }

  // nobody have this perm
  static const String LEDGER_CREATE_X = 'LEDGER_CREATE_X';
  static const String LEDGER_READ_ALL = 'LEDGER_READ_ALL';

  // nobody have this perm
  static const String SALES_CREATE_X = 'SALES_CREATE_X';
  static const String SALES_READ_ALL = 'LEDGER_READ_ALL';

  static const String EXPENDITURE_CATEGORY = 'EXPENDITURE_CATEGORY';
  static const String EXPENDITURE_CREATE = 'EXPENDITURE_CREATE';
  static const String EXPENDITURE_READ_ALL = 'EXPENDITURE_READ_ALL';
  static const String EXPENDITURE_READ_OWN = 'EXPENDITURE_READ_OWN';
  static const String EXPENDITURE_EDIT_ALL = 'EXPENDITURE_EDIT_ALL';
  static const String EXPENDITURE_EDIT_OWN = 'EXPENDITURE_EDIT_OWN';
  static const String EXPENDITURE_DELETE_ALL = 'EXPENDITURE_DELETE_ALL';
  static const String EXPENDITURE_DELETE_OWN = 'EXPENDITURE_DELETE_OWN';

  // nobody have this perm
  static const String ASSETS_CREATE_X = 'ASSETS_CREATE_X';
  static const String ASSETS_READ_ALL = 'ASSETS_READ_ALL';

  // nobody have this perm
  static const String BANKS_CREATE_X = 'BANKS_CREATE_X';
  static const String BANKS_READ_ALL = 'BANKS_READ_ALL';

  static const String NBO_CREATE = 'NBO_CREATE';
  static const String NBO_READ_ALL = 'NBO_READ_ALL';
  static const String NBO_READ_OWN = 'NBO_READ_OWN';
  static const String NBO_EDIT_ALL = 'NBO_EDIT_ALL';
  static const String NBO_EDIT_OWN = 'NBO_EDIT_OWN';
  static const String NBO_DELETE_ALL = 'NBO_DELETE_ALL';
  static const String NBO_DELETE_OWN = 'NBO_DELETE_OWN';

  static const String PETTY_CASH_CREATE = 'PETTY_CASH_CREATE';
  static const String PETTY_CASH_READ_ALL = 'PETTY_CASH_READ_ALL';
  static const String PETTY_CASH_READ_OWN = 'PETTY_CASH_READ_OWN';
  static const String PETTY_CASH_EDIT_ALL = 'PETTY_CASH_EDIT_ALL';
  static const String PETTY_CASH_EDIT_OWN = 'PETTY_CASH_EDIT_OWN';
  static const String PETTY_CASH_DELETE_ALL = 'PETTY_CASH_DELETE_ALL';
  static const String PETTY_CASH_DELETE_OWN = 'PETTY_CASH_DELETE_OWN';

  static const String CASH_DRAWER_CREATE = 'CASH_DRAWER_CREATE';
  static const String CASH_DRAWER_READ_ALL = 'CASH_DRAWER_READ_ALL';
  static const String CASH_DRAWER_READ_OWN = 'CASH_DRAWER_READ_OWN';
  static const String CASH_DRAWER_EDIT_ALL = 'CASH_DRAWER_EDIT_ALL';
  static const String CASH_DRAWER_EDIT_OWN = 'CASH_DRAWER_EDIT_OWN';
  static const String CASH_DRAWER_DELETE_ALL = 'CASH_DRAWER_DELETE_ALL';
  static const String CASH_DRAWER_DELETE_OWN = 'CASH_DRAWER_DELETE_OWN';

  // nobody have this perm
  static const String DEBTORS_CREATE_X = 'DEBTORS_CREATE_X';
  static const String DEBTORS_READ_ALL = 'DEBTORS_READ_ALL';

  // nobody have this perm
  static const String LIABILITIES_CREATE_X = 'LIABILITIES_CREATE_X';
  static const String LIABILITIES_READ_ALL = 'LIABILITIES_READ_ALL';

  static const String SELL_POINT_CATEGORY = 'SELL_POINT_CATEGORY';

  static const String RETAIL_CATEGORY = 'RETAIL_CATEGORY';
  static const String RETAIL_CREATE = 'RETAIL_CREATE';
  static const String RETAIL_READ_ALL = 'RETAIL_READ_ALL';
  static const String RETAIL_READ_OWN = 'RETAIL_READ_OWN';
  static const String RETAIL_EDIT_ALL = 'RETAIL_EDIT_ALL';
  static const String RETAIL_EDIT_OWN = 'RETAIL_EDIT_OWN';
  static const String RETAIL_DELETE_ALL = 'RETAIL_DELETE_ALL';
  static const String RETAIL_DELETE_OWN = 'RETAIL_DELETE_OWN';

  static const String WHOLESALE_CATEGORY = 'WHOLESALE_CATEGORY';
  static const String WHOLESALE_CREATE = 'WHOLESALE_CREATE';
  static const String WHOLESALE_READ_ALL = 'WHOLESALE_READ_ALL';
  static const String WHOLESALE_READ_OWN = 'WHOLESALE_READ_OWN';
  static const String WHOLESALE_EDIT_ALL = 'WHOLESALE_EDIT_ALL';
  static const String WHOLESALE_EDIT_OWN = 'WHOLESALE_EDIT_OWN';
  static const String WHOLESALE_DELETE_ALL = 'WHOLESALE_DELETE_ALL';
  static const String WHOLESALE_DELETE_OWN = 'WHOLESALE_DELETE_OWN';

  static const String PURCHAS_CATEGORY = 'PURCHAS_CATEGORY';
  static const String PURCHAS_CREATE = 'PURCHAS_CREATE';
  static const String PURCHAS_READ_ALL = 'PURCHAS_READ_ALL';
  static const String PURCHAS_READ_OWN = 'PURCHAS_READ_OWN';
  static const String PURCHAS_EDIT_ALL = 'PURCHAS_EDIT_ALL';
  static const String PURCHAS_EDIT_OWN = 'PURCHAS_EDIT_OWN';
  static const String PURCHAS_DELETE_ALL = 'PURCHAS_DELETE_ALL';
  static const String PURCHAS_DELETE_OWN = 'PURCHAS_DELETE_OWN';

  static const String ITEM_CATEGORY = 'ITEM_CATEGORY';
  static const String ITEM_CREATE = 'ITEM_CREATE';
  static const String ITEM_READ_ALL = 'ITEM_READ_ALL';
  static const String ITEM_READ_OWN = 'ITEM_READ_OWN';
  static const String ITEM_EDIT_ALL = 'ITEM_EDIT_ALL';
  static const String ITEM_EDIT_OWN = 'ITEM_EDIT_OWN';
  static const String ITEM_DELETE_ALL = 'ITEM_DELETE_ALL';
  static const String ITEM_DELETE_OWN = 'ITEM_DELETE_OWN';

  static const String MONEY_MOVEMENT_CATEGORY = 'MONEY_MOVEMENT_CATEGORY';
  static const String MONEY_MOVEMENT_CREATE = 'MONEY_MOVEMENT_CREATE';
  static const String MONEY_MOVEMENT_READ_ALL = 'MONEY_MOVEMENT_READ_ALL';
  static const String MONEY_MOVEMENT_READ_OWN = 'MONEY_MOVEMENT_READ_OWN';
  static const String MONEY_MOVEMENT_EDIT_ALL = 'MONEY_MOVEMENT_EDIT_ALL';
  static const String MONEY_MOVEMENT_EDIT_OWN = 'MONEY_MOVEMENT_EDIT_OWN';
  static const String MONEY_MOVEMENT_DELETE_ALL = 'MONEY_MOVEMENT_DELETE_ALL';
  static const String MONEY_MOVEMENT_DELETE_OWN = 'MONEY_MOVEMENT_DELETE_OWN';

  static const String REPORT_CATEGORY = 'REPORT_CATEGORY';
  static const String REPORT_READ_ALL = 'REPORT_READ_ALL';

  static const String ACCOUNT_CATEGORY = 'ACCOUNT_CATEGORY';
  static const String ACCOUNT_CREATE = 'ACCOUNT_CREATE';
  static const String ACCOUNT_READ_ALL = 'ACCOUNT_READ_ALL';
  static const String ACCOUNT_READ_OWN = 'ACCOUNT_READ_OWN';
  static const String ACCOUNT_EDIT_ALL = 'ACCOUNT_EDIT_ALL';
  static const String ACCOUNT_EDIT_OWN = 'ACCOUNT_EDIT_OWN';
  static const String ACCOUNT_DELETE_ALL = 'ACCOUNT_DELETE_ALL';
  static const String ACCOUNT_DELETE_OWN = 'ACCOUNT_DELETE_OWN';

  static const String ITEM_SUMMERY_CATEGORY = 'ITEM_SUMMERY_CATEGORY';
}
