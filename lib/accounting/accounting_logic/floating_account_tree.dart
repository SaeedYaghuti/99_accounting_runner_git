import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/floating_account.dart';
import 'package:shop/accounting/expenditure/expenditure_class_tree.dart';

import '../accounting_logic/transaction_classification.dart';

const FLOAT_ACCOUNT_TREE = const [
  // Root
  FloatingAccount(
    id: FloatAccountIds.ROOT_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.TOP_FLOAT_ACCOUNT_ID,
    titleEnglish: 'Root Floating Account',
    titlePersian: 'شناور ريشه',
    titleArabic: 'سيال اساسي',
    note: 'This is root float account for all other float account',
  ),
  // GENERAL
  FloatingAccount(
    id: FloatAccountIds.GENERAL_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.ROOT_FLOAT_ACCOUNT_ID,
    titleEnglish: 'General Floating Account',
    titlePersian: 'شناور عمومى',
    titleArabic: 'سيال عامة',
    note: 'Use this class when float account is not need for transaction',
  ),
  // SALESMAN
  FloatingAccount(
    id: FloatAccountIds.SALESMAN_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.ROOT_FLOAT_ACCOUNT_ID,
    titleEnglish: 'Salesman',
    titlePersian: 'شناور فروشنده ها',
    titleArabic: 'سيال بائعين',
    note: 'Salesman floating account',
  ),
  // SAEID
  FloatingAccount(
    id: FloatAccountIds.SAEID_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.SALESMAN_FLOAT_ACCOUNT_ID,
    titleEnglish: 'Saeid',
    titlePersian: 'شناور سعيد ',
    titleArabic: 'سيال سعيد',
    note: 'Saeid floating account',
  ),
  // SADI
  FloatingAccount(
    id: FloatAccountIds.SADI_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.SALESMAN_FLOAT_ACCOUNT_ID,
    titleEnglish: 'Sadi',
    titlePersian: 'شناور سعدي ',
    titleArabic: 'سيال سعدي',
    note: 'Sadi floating account',
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
  static const ROOT_FLOAT_ACCOUNT_ID = 'ROOT_FLOAT';
  static const GENERAL_FLOAT_ACCOUNT_ID = 'GENERAL_FLOAT';
  static const SALESMAN_FLOAT_ACCOUNT_ID = 'SALESMAN_FLOAT';
  static const SAEID_FLOAT_ACCOUNT_ID = 'SAEID_FLOAT';
  static const SADI_FLOAT_ACCOUNT_ID = 'SADI_FLOAT';
}
