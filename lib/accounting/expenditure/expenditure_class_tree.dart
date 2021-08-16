import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/classification/classification_tree.dart';
import 'package:shop/accounting/accounting_logic/classification/classification_types.dart';
import 'package:shop/accounting/accounting_logic/classification/transaction_classification.dart';

const EXP_CLASS_TREE = const [
  // SOIL
  // note: parent of root; this class is not defined;

  // ROOT
  // TransactionClassification(
  //   id: TranClassIds.ROOT_TRAN_CLASS_ID,
  //   parentId: TranClassIds.SOIL_TRAN_CLASS_ID,
  //   classType: ClassificationTypes.ROOT_TYPE,
  //   titleEnglish: 'Root Transaction Class',
  //   titlePersian: 'طبقه پایه',
  //   titleArabic: 'تصنيف اساسی',
  //   note: 'Never use this class; It is only for having valid parent class for General tran class',
  // ),
  // NOT_SPECIFIED
  // TransactionClassification(
  //   id: TranClassIds.NOT_SPECIFIED_TRAN_CLASS_ID,
  //   parentId: TranClassIds.ROOT_TRAN_CLASS_ID,
  //   classType: ClassificationTypes.NOT_SPECIFIED_TYPE,
  //   titleEnglish: 'Not Specified Transaction Class',
  //   titlePersian: 'طبقه مشخص نشده',
  //   titleArabic: 'غير محدد',
  //   note: 'Use this class when classification is not specified',
  // ),
  // EXPENDITURE_ROOT
  // TransactionClassification(
  //   id: ExpClassIds.EXP_ROOT_CLASS_ID,
  //   parentId: ClassIds.ROOT_CLASS_ID,
  //   classType: ClassificationTypes.EXPENDITURE_TYPE,
  //   titleEnglish: 'Root Expenses Classifications',
  //   titlePersian: 'طبقه بندى هزينه ها',
  //   titleArabic: 'تصنيف مصاريف',
  //   note: 'Parent of all expenditure classes',
  // ),

  // NOT_SPECIFIED
  TransactionClassification(
    id: ExpClassIds.EXP_NOT_SPECIFIED_CLASS_ID,
    parentId: ExpClassIds.EXP_ROOT_CLASS_ID,
    classType: ClassificationTypes.EXPENDITURE_TYPE,
    titleEnglish: 'Not Specified',
    titlePersian: 'طبقه مشخص نشده',
    titleArabic: 'غير محدد',
    note: '_',
  ),
  // SHOP
  TransactionClassification(
    id: ExpClassIds.EXP_SHOP_CLASS_ID,
    parentId: ExpClassIds.EXP_ROOT_CLASS_ID,
    classType: ClassificationTypes.EXPENDITURE_TYPE,
    titleEnglish: 'Shop',
    titleArabic: 'محل',
    titlePersian: 'فروشگاه',
    note: '_',
  ),
  // SHOP_HOSPITALITY
  TransactionClassification(
    id: ExpClassIds.EXP_SHOP_HOSPITALITY_CLASS_ID,
    parentId: ExpClassIds.EXP_SHOP_CLASS_ID,
    classType: ClassificationTypes.EXPENDITURE_TYPE,
    titleEnglish: 'Hospitality',
    titleArabic: 'ضيافة',
    titlePersian: 'ميزبانى',
    note: '_',
  ),
  // SHOP_BILLS
  TransactionClassification(
    id: ExpClassIds.EXP_SHOP_BILLS_CLASS_ID,
    parentId: ExpClassIds.EXP_SHOP_CLASS_ID,
    classType: ClassificationTypes.EXPENDITURE_TYPE,
    titleEnglish: 'Bills',
    titleArabic: 'قبوض',
    titlePersian: 'قبض',
    note: '_',
  ),
  // SHOP_RENT
  TransactionClassification(
    id: ExpClassIds.EXP_SHOP_RENT_CLASS_ID,
    parentId: ExpClassIds.EXP_SHOP_CLASS_ID,
    classType: ClassificationTypes.EXPENDITURE_TYPE,
    titleEnglish: 'Rent',
    titleArabic: 'ايجار',
    titlePersian: 'اجاره',
    note: '_',
  ),
  // STAFF
  TransactionClassification(
    id: ExpClassIds.EXP_STAFF_CLASS_ID,
    parentId: ExpClassIds.EXP_ROOT_CLASS_ID,
    classType: ClassificationTypes.EXPENDITURE_TYPE,
    titleEnglish: 'Staff',
    titleArabic: 'موظفين',
    titlePersian: 'كاركنان',
    note: '_',
  ),
  // STAFF_SALLARY
  TransactionClassification(
    id: ExpClassIds.EXP_STAFF_SALLARY_CLASS_ID,
    parentId: ExpClassIds.EXP_STAFF_CLASS_ID,
    classType: ClassificationTypes.EXPENDITURE_TYPE,
    titleEnglish: 'Staff Salary',
    titleArabic: 'رواتب',
    titlePersian: 'حقوقق',
    note: '_',
  ),
  // STAFF_REWARD
  TransactionClassification(
    id: ExpClassIds.EXP_STAFF_REWARD_CLASS_ID,
    parentId: ExpClassIds.EXP_STAFF_CLASS_ID,
    classType: ClassificationTypes.EXPENDITURE_TYPE,
    titleEnglish: 'Staff Rewards',
    titleArabic: 'جائزة',
    titlePersian: 'پاداش',
    note: '_',
  ),
  // ADMINISTRATIVE_COST
  TransactionClassification(
    id: ExpClassIds.EXP_ADMINISTRATIVE_COST_CLASS_ID,
    parentId: ExpClassIds.EXP_ROOT_CLASS_ID,
    titleEnglish: 'Administrative Cost',
    classType: ClassificationTypes.EXPENDITURE_TYPE,
    titleArabic: 'مكتب سند',
    titlePersian: 'ادارى',
    note: '_',
  ),
  // POS
  TransactionClassification(
    id: ExpClassIds.EXP_POS_CLASS_ID,
    parentId: ExpClassIds.EXP_ROOT_CLASS_ID,
    classType: ClassificationTypes.EXPENDITURE_TYPE,
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
  static const EXP_ROOT_CLASS_ID = 'EXP_ROOT';
  static const EXP_SHOP_CLASS_ID = 'EXP_SHOP';
  static const EXP_NOT_SPECIFIED_CLASS_ID = 'EXP_NOT_SPECIFIED';
  static const EXP_SHOP_HOSPITALITY_CLASS_ID = 'EXP_SHOP_HOSPITALITY';
  static const EXP_SHOP_RENT_CLASS_ID = 'EXP_SHOP_RENT';
  static const EXP_SHOP_BILLS_CLASS_ID = 'EXP_SHOP_BILLS';
  static const EXP_STAFF_CLASS_ID = 'EXP_STAFF';
  static const EXP_STAFF_SALLARY_CLASS_ID = 'EXP_STAFF_SALLARY';
  static const EXP_STAFF_REWARD_CLASS_ID = 'EXP_STAFF_REWARD';
  static const EXP_ADMINISTRATIVE_COST_CLASS_ID = 'EXP_ADMINISTRATIVE_COST';
  static const EXP_POS_CLASS_ID = 'EXP_POS';
}
