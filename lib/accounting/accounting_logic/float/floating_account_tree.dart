import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/float/floating_account.dart';
import 'package:shop/accounting/expenditure/expenditure_class_tree.dart';

const FLOAT_ACCOUNT_TREE = const [
  // Root
  FloatingAccount(
    id: FloatAccountIds.ROOT_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.TOP_FLOAT_ACCOUNT_ID,
    isNode: false,
    titleEnglish: 'Root Floating Account',
    titlePersian: 'شناور ريشه',
    titleArabic: 'سيال اساسي',
    note: 'This is root float account for all other float account',
  ),
  // NOT_SPECIFIED
  FloatingAccount(
    id: FloatAccountIds.NOT_SPECIFIED_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.ROOT_FLOAT_ACCOUNT_ID,
    isNode: false,
    titleEnglish: 'Not Specified Floating Account',
    titlePersian: 'شناور عمومى',
    titleArabic: 'سيال عامة',
    note: 'Use this class when float account is not need for transaction',
  ),
  // SALESMAN
  FloatingAccount(
    id: FloatAccountIds.SALESMAN_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.ROOT_FLOAT_ACCOUNT_ID,
    isNode: true,
    titleEnglish: 'Salesman',
    titlePersian: 'شناور فروشنده ها',
    titleArabic: 'سيال بائعين',
    note: 'Salesman floating account',
  ),
  // SAEID
  FloatingAccount(
    id: FloatAccountIds.SAEID_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.SALESMAN_FLOAT_ACCOUNT_ID,
    isNode: false,
    titleEnglish: 'Saeid',
    titlePersian: 'شناور سعيد ',
    titleArabic: 'سيال سعيد',
    note: 'Saeid floating account',
  ),
  // SADI
  FloatingAccount(
    id: FloatAccountIds.SADI_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.SALESMAN_FLOAT_ACCOUNT_ID,
    isNode: false,
    titleEnglish: 'Sadi',
    titlePersian: 'شناور سعدي ',
    titleArabic: 'سيال سعدي',
    note: 'Sadi floating account',
  ),
  // NOT_SPECIFIED_SALESMAN
  FloatingAccount(
    id: FloatAccountIds.NOT_SPECIFIED_SALESMAN_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.SALESMAN_FLOAT_ACCOUNT_ID,
    isNode: false,
    titleEnglish: 'Not Specified Salesman',
    titlePersian: 'شناور عمومى',
    titleArabic: 'سيال عامة',
    note: 'Use this class when salesman float account is not need for transaction',
  ),
  // CAR
  FloatingAccount(
    id: FloatAccountIds.CAR_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.ROOT_FLOAT_ACCOUNT_ID,
    isNode: true,
    titleEnglish: 'Car',
    titlePersian: 'شناور فروشنده ها',
    titleArabic: 'سيال بائعين',
    note: 'Salesman floating account',
  ),
  // AVALON_12_CAR
  FloatingAccount(
    id: FloatAccountIds.AVALON_12_CAR_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.CAR_FLOAT_ACCOUNT_ID,
    isNode: false,
    titleEnglish: 'Avalon 12',
    titlePersian: 'شناور عمومى',
    titleArabic: 'سيال عامة',
    note: 'Use this class when salesman float account is not need for transaction',
  ),
  // MAXIMA_55_CAR
  FloatingAccount(
    id: FloatAccountIds.MAXIMA_55_CAR_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.CAR_FLOAT_ACCOUNT_ID,
    isNode: false,
    titleEnglish: 'Maxima 55',
    titlePersian: 'شناور عمومى',
    titleArabic: 'سيال عامة',
    note: 'Use this class when salesman float account is not need for transaction',
  ),
  // NOT_SPECIFIED_CAR
  FloatingAccount(
    id: FloatAccountIds.NOT_SPECIFIED_CAR_FLOAT_ACCOUNT_ID,
    parentId: FloatAccountIds.CAR_FLOAT_ACCOUNT_ID,
    isNode: false,
    titleEnglish: 'Not Specified Car',
    titlePersian: 'شناور عمومى',
    titleArabic: 'سيال عامة',
    note: 'Use this class when salesman float account is not need for transaction',
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
  static const NOT_SPECIFIED_FLOAT_ACCOUNT_ID = 'NOT_SPECIFIED_FLOAT';

  static const SALESMAN_FLOAT_ACCOUNT_ID = 'SALESMAN_FLOAT';
  static const NOT_SPECIFIED_SALESMAN_FLOAT_ACCOUNT_ID = 'NOT_SPECIFIED_SALESMAN_FLOAT';
  static const SAEID_FLOAT_ACCOUNT_ID = 'SAEID_FLOAT';
  static const SADI_FLOAT_ACCOUNT_ID = 'SADI_FLOAT';

  static const CAR_FLOAT_ACCOUNT_ID = 'CAR_FLOAT';
  static const NOT_SPECIFIED_CAR_FLOAT_ACCOUNT_ID = 'NOT_SPECIFIED_CAR_FLOAT';
  static const AVALON_12_CAR_FLOAT_ACCOUNT_ID = 'AVALON_12_FLOAT';
  static const MAXIMA_55_CAR_FLOAT_ACCOUNT_ID = 'MAXIMA_55_FLOAT';
}
