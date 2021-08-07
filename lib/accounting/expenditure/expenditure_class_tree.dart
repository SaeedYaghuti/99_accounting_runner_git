import 'package:shop/accounting/accounting_logic/account_ids.dart';

import '../accounting_logic/transaction_class/transaction_classification.dart';

const EXP_CLASS_TREE = const [
  // MAIN => DEFINE AT TRNS_CLASS_TREE
  // TransactionClassification(
  //   id: ExpClassIds.MAIN_EXP_CLASS_ID,
  //   parentId: ExpClassIds.TOP_EXP_CLASS_ID,
  //   accountType: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
  //   titleEnglish: 'Expenses Classifications',
  //   titlePersian: 'طبقه بندى هزينه ها',
  //   titleArabic: 'تصنيف مصاريف',
  //   note: '_',
  // ),
  // GENERAL

  TransactionClassification(
    id: ExpClassIds.GENERAL_EXP_CLASS_ID,
    parentId: ExpClassIds.MAIN_EXP_CLASS_ID,
    accountType: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
    titleEnglish: 'General',
    titlePersian: 'عمومى',
    titleArabic: 'عامة',
    note: '_',
  ),
  // SHOP
  TransactionClassification(
    id: ExpClassIds.SHOP_EXP_CLASS_ID,
    parentId: ExpClassIds.MAIN_EXP_CLASS_ID,
    accountType: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
    titleEnglish: 'Shop',
    titleArabic: 'محل',
    titlePersian: 'فروشگاه',
    note: '_',
  ),
  // SHOP_HOSPITALITY
  TransactionClassification(
    id: ExpClassIds.SHOP_HOSPITALITY_EXP_CLASS_ID,
    parentId: ExpClassIds.SHOP_EXP_CLASS_ID,
    accountType: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
    titleEnglish: 'Hospitality',
    titleArabic: 'ضيافة',
    titlePersian: 'ميزبانى',
    note: '_',
  ),
  // SHOP_BILLS
  TransactionClassification(
    id: ExpClassIds.SHOP_BILLS_EXP_CLASS_ID,
    parentId: ExpClassIds.SHOP_EXP_CLASS_ID,
    accountType: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
    titleEnglish: 'Bills',
    titleArabic: 'قبوض',
    titlePersian: 'قبض',
    note: '_',
  ),
  // SHOP_RENT
  TransactionClassification(
    id: ExpClassIds.SHOP_RENT_EXP_CLASS_ID,
    parentId: ExpClassIds.SHOP_EXP_CLASS_ID,
    accountType: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
    titleEnglish: 'Rent',
    titleArabic: 'ايجار',
    titlePersian: 'اجاره',
    note: '_',
  ),
  // STAFF
  TransactionClassification(
    id: ExpClassIds.STAFF_EXP_CLASS_ID,
    parentId: ExpClassIds.MAIN_EXP_CLASS_ID,
    accountType: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
    titleEnglish: 'Staff',
    titleArabic: 'موظفين',
    titlePersian: 'كاركنان',
    note: '_',
  ),
  // STAFF_SALLARY
  TransactionClassification(
    id: ExpClassIds.STAFF_SALLARY_EXP_CLASS_ID,
    parentId: ExpClassIds.STAFF_EXP_CLASS_ID,
    accountType: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
    titleEnglish: 'Staff Salary',
    titleArabic: 'رواتب',
    titlePersian: 'حقوقق',
    note: '_',
  ),
  // STAFF_REWARD
  TransactionClassification(
    id: ExpClassIds.STAFF_REWARD_EXP_CLASS_ID,
    parentId: ExpClassIds.STAFF_EXP_CLASS_ID,
    accountType: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
    titleEnglish: 'Staff Rewards',
    titleArabic: 'جائزة',
    titlePersian: 'پاداش',
    note: '_',
  ),
  // ADMINISTRATIVE_COST
  TransactionClassification(
    id: ExpClassIds.ADMINISTRATIVE_COST_EXP_CLASS_ID,
    parentId: ExpClassIds.MAIN_EXP_CLASS_ID,
    titleEnglish: 'Administrative Cost',
    accountType: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
    titleArabic: 'مكتب سند',
    titlePersian: 'ادارى',
    note: '_',
  ),
  // POS
  TransactionClassification(
    id: ExpClassIds.POS_EXP_CLASS_ID,
    parentId: ExpClassIds.MAIN_EXP_CLASS_ID,
    accountType: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
    titleEnglish: 'POS',
    titleArabic: 'POS',
    titlePersian: 'POS',
    note: '_',
  ),
];

bool isParent(String tranClassId) {
  return EXP_CLASS_TREE.any((expClass) => expClass.parentId == tranClassId);
}

List<TransactionClassification> childs(String expClassId) {
  return EXP_CLASS_TREE.where((expClass) => expClass.parentId == expClassId).toList();
}

class ExpClassIds {
  static const MAIN_EXP_CLASS_ID = 'EXP_MAIN';
  static const TOP_EXP_CLASS_ID = 'EXP_TOP';
  static const SHOP_EXP_CLASS_ID = 'EXP_SHOP';
  static const GENERAL_EXP_CLASS_ID = 'EXP_GENERAL';
  static const SHOP_HOSPITALITY_EXP_CLASS_ID = 'EXP_SHOP_HOSPITALITY';
  static const SHOP_RENT_EXP_CLASS_ID = 'EXP_SHOP_RENT';
  static const SHOP_BILLS_EXP_CLASS_ID = 'EXP_SHOP_BILLS';
  static const STAFF_EXP_CLASS_ID = 'EXP_STAFF';
  static const STAFF_SALLARY_EXP_CLASS_ID = 'EXP_STAFF_SALLARY';
  static const STAFF_REWARD_EXP_CLASS_ID = 'EXP_STAFF_REWARD';
  static const ADMINISTRATIVE_COST_EXP_CLASS_ID = 'EXP_ADMINISTRATIVE_COST';
  static const POS_EXP_CLASS_ID = 'EXP_POS';
}
