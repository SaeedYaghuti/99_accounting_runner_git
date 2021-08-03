import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/floating_account.dart';
import 'package:shop/accounting/expenditure/expenditure_class_tree.dart';

import '../accounting_logic/transaction_classification.dart';

const FLOAT_ACCOUNT_TREE = const [
  // GENERAL
  FloatingAccount(
    id: TranClassIds.GENERAL_TRAN_CLASS_ID,
    parentId: TranClassIds.TOP_TRAN_CLASS_ID,
    titleEnglish: 'General Transaction Class',
    titlePersian: 'طبقه عمومى',
    titleArabic: 'تصنيف عامة',
    note: 'Use this class when classification is not defined for account',
  ),
  // MAIN_EXPENDITURE
  FloatingAccount(
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
  return FLOAT_ACCOUNT_TREE.any((expClass) => expClass.parentId == tranClassId);
}

List<FloatingAccount> childs(String expClassId) {
  return FLOAT_ACCOUNT_TREE.where((expClass) => expClass.parentId == expClassId).toList();
}

class FloatAccountIds {
  static const TOP_FLOAT_ACCOUNT_ID = 'TOP_FLOAT';
  static const GENERAL_FLOAT_ACCOUNT_ID = 'GENERAL_FLOAT';
  static const SALESMAN_FLOAT_ACCOUNT_ID = 'SALESMAN_FLOAT';
  static const SAEID_FLOAT_ACCOUNT_ID = 'SAEID_FLOAT';
  static const SADI_FLOAT_ACCOUNT_ID = 'SADI_FLOAT';
}
