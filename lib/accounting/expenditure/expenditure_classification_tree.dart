import 'package:shop/auth/permission_model.dart';

import 'expenditure_ classification.dart';

const EXP_CLASS_TREE = const [
  ExpenditureClassification(
    id: ExpClassIds.MAIN_EXP_CLASS,
    parentId: ExpClassIds.TOP_EXP_CLASS,
    titleEnglish: 'Expenses Classifications',
    titleArabic: 'لجر ريبورت',
    titlePersian: 'گزارش گروه های حسابداری',
    note: '_',
    createTransactionPermission: null,
    readAllTransactionPermission: PermissionModel.LEDGER_READ_ALL_TRANSACTION,
    readOwnTransactionPermission: null,
    editAllTransactionPermission: null,
    deleteAllTransactionPermission: null,
  ),
  ExpenditureClassification(
    id: ExpClassIds.EXPENDITURE_ACCOUNT_ID,
    parentId: ExpClassIds.LEDGER_ACCOUNT_ID,
    titleEnglish: 'Expenditure',
    titleArabic: 'مصاريف',
    titlePersian: 'هزینه ها',
    note: '_',
    createTransactionPermission: PermissionModel.EXPENDITURE_CREATE_TRANSACTION,
    readAllTransactionPermission:
        PermissionModel.EXPENDITURE_READ_ALL_TRANSACTION,
    readOwnTransactionPermission:
        PermissionModel.EXPENDITURE_READ_OWN_TRANSACTION,
    editAllTransactionPermission:
        PermissionModel.EXPENDITURE_EDIT_ALL_TRANSACTION,
    editOwnTransactionPermission:
        PermissionModel.EXPENDITURE_EDIT_OWN_TRANSACTION,
    deleteAllTransactionPermission:
        PermissionModel.EXPENDITURE_DELETE_ALL_TRANSACTION,
    deleteOwnTransactionPermission:
        PermissionModel.EXPENDITURE_DELETE_OWN_TRANSACTION,
  ),
];

bool isParent(String expClassId) {
  return EXP_CLASS_TREE.any((expClass) => expClass.parentId == expClassId);
}

List<ExpenditureClassification> childs(String expClassId) {
  return EXP_CLASS_TREE
      .where((expClass) => expClass.parentId == expClassId)
      .toList();
}

class ExpClassIds {
  static const MAIN_EXP_CLASS = 'MAIN';
  static const TOP_EXP_CLASS = 'TOP';
  static const SHOP_EXP_CLASS = 'SHOP';
  static const GENERAL_EXP_CLASS = 'GENERAL';
  static const SHOP_HOSPITALITY_EXP_CLASS = 'SHOP_HOSPITALITY';
  static const SHOP_RENT_EXP_CLASS = 'SHOP_RENT';
  static const STAFF_EXP_CLASS = 'STAFF';
  static const STAFF_SALLARY_EXP_CLASS = 'STAFF_SALLARY';
  static const STAFF_REWARD_EXP_CLASS = 'STAFF_REWARD';
  static const ADMINISTRATIVE_COST_EXP_CLASS = 'ADMINISTRATIVE_COST';
  static const POS_EXP_CLASS = 'POS';
}
