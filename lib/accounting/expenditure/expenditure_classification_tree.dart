import 'package:shop/auth/permission_model.dart';

import 'expenditure_ classification.dart';

const EXP_CLASS_TREE = const [
  // MAIN
  ExpenditureClassification(
    id: ExpClassIds.MAIN_EXP_CLASS_ID,
    parentId: ExpClassIds.TOP_EXP_CLASS_ID,
    titleEnglish: 'Expenses Classifications',
    titlePersian: 'طبقه بندى هزينه ها',
    titleArabic: 'تصنيف مصاريف',
    note: '_',
  ),
  // GENERAL
  ExpenditureClassification(
    id: ExpClassIds.GENERAL_EXP_CLASS_ID,
    parentId: ExpClassIds.MAIN_EXP_CLASS_ID,
    titleEnglish: 'General',
    titlePersian: 'عمومى',
    titleArabic: 'عامة',
    note: '_',
  ),
  // SHOP
  ExpenditureClassification(
    id: ExpClassIds.SHOP_EXP_CLASS_ID,
    parentId: ExpClassIds.MAIN_EXP_CLASS_ID,
    titleEnglish: 'Shop',
    titleArabic: 'محل',
    titlePersian: 'فروشگاه',
    note: '_',
  ),
  // SHOP_HOSPITALITY
  ExpenditureClassification(
    id: ExpClassIds.SHOP_HOSPITALITY_EXP_CLASS_ID,
    parentId: ExpClassIds.SHOP_EXP_CLASS_ID,
    titleEnglish: 'Hospitality',
    titleArabic: 'ضيافة',
    titlePersian: 'ميزبانى',
    note: '_',
  ),
  // SHOP_BILLS
  ExpenditureClassification(
    id: ExpClassIds.SHOP_BILLS_EXP_CLASS_ID,
    parentId: ExpClassIds.SHOP_EXP_CLASS_ID,
    titleEnglish: 'Bills',
    titleArabic: 'قبوض',
    titlePersian: 'قبض',
    note: '_',
  ),
  // SHOP_RENT
  ExpenditureClassification(
    id: ExpClassIds.SHOP_RENT_EXP_CLASS_ID,
    parentId: ExpClassIds.SHOP_EXP_CLASS_ID,
    titleEnglish: 'Rent',
    titleArabic: 'ايجار',
    titlePersian: 'اجاره',
    note: '_',
  ),
  // STAFF
  ExpenditureClassification(
    id: ExpClassIds.STAFF_EXP_CLASS_ID,
    parentId: ExpClassIds.MAIN_EXP_CLASS_ID,
    titleEnglish: 'Staff',
    titleArabic: 'موظفين',
    titlePersian: 'كاركنان',
    note: '_',
  ),
  // STAFF_SALLARY
  ExpenditureClassification(
    id: ExpClassIds.STAFF_SALLARY_EXP_CLASS_ID,
    parentId: ExpClassIds.STAFF_EXP_CLASS_ID,
    titleEnglish: 'Staff Salary',
    titleArabic: 'رواتب',
    titlePersian: 'حقوقق',
    note: '_',
  ),
  // STAFF_REWARD
  ExpenditureClassification(
    id: ExpClassIds.STAFF_REWARD_EXP_CLASS_ID,
    parentId: ExpClassIds.STAFF_EXP_CLASS_ID,
    titleEnglish: 'Staff Rewards',
    titleArabic: 'جائزة',
    titlePersian: 'پاداش',
    note: '_',
  ),
  // ADMINISTRATIVE_COST
  ExpenditureClassification(
    id: ExpClassIds.ADMINISTRATIVE_COST_EXP_CLASS_ID,
    parentId: ExpClassIds.MAIN_EXP_CLASS_ID,
    titleEnglish: 'Administrative Cost',
    titleArabic: 'مكتب سند',
    titlePersian: 'ادارى',
    note: '_',
  ),
  // POS
  ExpenditureClassification(
    id: ExpClassIds.POS_EXP_CLASS_ID,
    parentId: ExpClassIds.MAIN_EXP_CLASS_ID,
    titleEnglish: 'POS',
    titleArabic: 'POS',
    titlePersian: 'POS',
    note: '_',
  ),
];

bool isParent(String expClassId) {
  return EXP_CLASS_TREE.any((expClass) => expClass.parentId == expClassId);
}

List<ExpenditureClassification> childs(String expClassId) {
  return EXP_CLASS_TREE.where((expClass) => expClass.parentId == expClassId).toList();
}

class ExpClassIds {
  static const MAIN_EXP_CLASS_ID = 'MAIN';
  static const TOP_EXP_CLASS_ID = 'TOP';
  static const SHOP_EXP_CLASS_ID = 'SHOP';
  static const GENERAL_EXP_CLASS_ID = 'GENERAL';
  static const SHOP_HOSPITALITY_EXP_CLASS_ID = 'SHOP_HOSPITALITY';
  static const SHOP_RENT_EXP_CLASS_ID = 'SHOP_RENT';
  static const SHOP_BILLS_EXP_CLASS_ID = 'SHOP_BILLS';
  static const STAFF_EXP_CLASS_ID = 'STAFF';
  static const STAFF_SALLARY_EXP_CLASS_ID = 'STAFF_SALLARY';
  static const STAFF_REWARD_EXP_CLASS_ID = 'STAFF_REWARD';
  static const ADMINISTRATIVE_COST_EXP_CLASS_ID = 'ADMINISTRATIVE_COST';
  static const POS_EXP_CLASS_ID = 'POS';
}
