import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/classification/classification_types.dart';
import 'package:shop/accounting/expenditure/expenditure_class_tree.dart';

import 'transaction_classification.dart';

var TRANS_CLASS_TREE = [
  // SOIL
  // note: parent of root; this class is not defined;

  // ROOT
  TransactionClassification(
    id: ClassIds.ROOT_CLASS_ID,
    parentId: ClassIds.SOIL_CLASS_ID,
    classType: ClassificationTypes.ROOT_TYPE,
    titleEnglish: 'Root Transaction Class',
    titlePersian: 'طبقه پایه',
    titleArabic: 'تصنيف اساسی',
    note: 'Never use this class; It is only for having valid parent class for General tran class',
  ),
  // NOT_SPECIFIED
  TransactionClassification(
    id: ClassIds.NOT_SPECIFIED_CLASS_ID,
    parentId: ClassIds.ROOT_CLASS_ID,
    classType: ClassificationTypes.NOT_SPECIFIED_TYPE,
    titleEnglish: 'Not Specified Transaction Class',
    titlePersian: 'طبقه مشخص نشده',
    titleArabic: 'غير محدد',
    note: 'Use this class when classification is not specified',
  ),
  // EXPENDITURE_ROOT
  TransactionClassification(
    id: ExpClassIds.EXP_ROOT_CLASS_ID,
    parentId: ClassIds.ROOT_CLASS_ID,
    classType: ClassificationTypes.EXPENDITURE_TYPE,
    titleEnglish: 'Root Expenses Classifications',
    titlePersian: 'طبقه بندى هزينه ها',
    titleArabic: 'تصنيف مصاريف',
    note: 'Parent of all expenditure classes',
  ),
];

bool isParent(String tranClassId) {
  return TRANS_CLASS_TREE.any((expClass) => expClass.parentId == tranClassId);
}

List<TransactionClassification> childs(String expClassId) {
  return TRANS_CLASS_TREE.where((expClass) => expClass.parentId == expClassId).toList();
}

class ClassIds {
  static const SOIL_CLASS_ID = 'SOIL_TRAN';
  static const ROOT_CLASS_ID = 'ROOT_TRAN';
  static const NOT_SPECIFIED_CLASS_ID = 'NOT_SPECIFIED';
}
