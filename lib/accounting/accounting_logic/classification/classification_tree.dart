import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/expenditure/expenditure_class_tree.dart';

import 'transaction_classification.dart';

var TRANS_CLASS_TREE = [
  // ROOT
  TransactionClassification(
    id: TranClassIds.ROOT_TRAN_CLASS_ID,
    parentId: TranClassIds.ROOT_PARENT_TRAN_CLASS_ID,
    accountType: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Root Transaction Class',
    titlePersian: 'طبقه پایه',
    titleArabic: 'تصنيف اساسی',
    note: 'Never use this class; It is only for having valid parent class for General tran class',
  ),
  // GENERAL
  TransactionClassification(
    id: TranClassIds.GENERAL_TRAN_CLASS_ID,
    parentId: TranClassIds.ROOT_TRAN_CLASS_ID,
    accountType: ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
    titleEnglish: 'General Transaction Class',
    titlePersian: 'طبقه عمومى',
    titleArabic: 'تصنيف عامة',
    note: 'Use this class when classification is not defined for account',
  ),
  // MAIN_EXPENDITURE
  TransactionClassification(
    id: ExpClassIds.MAIN_EXP_CLASS_ID,
    parentId: ExpClassIds.TOP_EXP_CLASS_ID,
    accountType: ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
    titleEnglish: 'Expenses Classifications',
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

class TranClassIds {
  static const ROOT_PARENT_TRAN_CLASS_ID = 'ROOT_PARENT_TRAN';
  static const ROOT_TRAN_CLASS_ID = 'ROOT_TRAN';
  static const GENERAL_TRAN_CLASS_ID = 'GENERAL_TRAN';
}
