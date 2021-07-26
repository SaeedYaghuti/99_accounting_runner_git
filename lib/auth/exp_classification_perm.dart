import 'package:shop/auth/permission_model.dart';

const EXP_CLASSIFICATION_PERMISSIONS = const [
  // ## CASH_DRAWER
  PermissionModel(
    id: PermissionModel.CASH_DRAWER_CREATE_TRANSACTION,
    titleEnglish: PermissionModel.CASH_DRAWER_CREATE_TRANSACTION,
    titlePersian: 'ايجاد سند دخل',
    titleArabic: 'ايجاد سند صندوق',
  ),
  PermissionModel(
    id: PermissionModel.CASH_DRAWER_READ_ALL_TRANSACTION,
    titleEnglish: PermissionModel.CASH_DRAWER_READ_ALL_TRANSACTION,
    titlePersian: 'مشاهده تمام اسناد دخل',
    titleArabic: 'قراة كل اسناد صندوق',
  ),
  PermissionModel(
    id: PermissionModel.CASH_DRAWER_READ_OWN_TRANSACTION,
    titleEnglish: PermissionModel.CASH_DRAWER_READ_OWN_TRANSACTION,
    titlePersian: 'مشاهده اسناد دخل خودم',
    titleArabic: 'قراة اسنادي من صندوق',
  ),
  PermissionModel(
    id: PermissionModel.CASH_DRAWER_EDIT_ALL_TRANSACTION,
    titleEnglish: PermissionModel.CASH_DRAWER_EDIT_ALL_TRANSACTION,
    titlePersian: 'ويرايش تمام اسناد دخل',
    titleArabic: 'اصلاح كل اسناد صندوق',
  ),
  PermissionModel(
    id: PermissionModel.CASH_DRAWER_EDIT_OWN_TRANSACTION,
    titleEnglish: PermissionModel.CASH_DRAWER_EDIT_OWN_TRANSACTION,
    titlePersian: 'ويرايش اسناد دخل خودم',
    titleArabic: 'اصلاح اسنادي من صندوق',
  ),
  PermissionModel(
    id: PermissionModel.CASH_DRAWER_DELETE_ALL_TRANSACTION,
    titleEnglish: PermissionModel.CASH_DRAWER_DELETE_ALL_TRANSACTION,
    titlePersian: 'حذف تمام اسناد دخل',
    titleArabic: 'حذف كل اسناد صندوق',
  ),
  PermissionModel(
    id: PermissionModel.CASH_DRAWER_DELETE_OWN_TRANSACTION,
    titleEnglish: PermissionModel.CASH_DRAWER_DELETE_OWN_TRANSACTION,
    titlePersian: 'حذف اسناد دخل خودم',
    titleArabic: 'حذف اسنادي من صندوق',
  ),
];
