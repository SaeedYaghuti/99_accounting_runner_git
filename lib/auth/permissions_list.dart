import 'package:shop/auth/permission_model.dart';

const PERMISSIONS_LIST = const [
  // ## EXPENDITURE
  PermissionModel(
    id: PermissionModel.EXPENDITURE_CATEGORY,
    titleEnglish: PermissionModel.EXPENDITURE_CATEGORY,
    titlePersian: 'گروه هزینه ها',
    titleArabic: 'مصاريف',
  ),
  PermissionModel(
    id: PermissionModel.EXPENDITURE_CREATE,
    titleEnglish: PermissionModel.EXPENDITURE_CREATE,
    titlePersian: 'ایجاد هزینه',
    titleArabic: 'تحديث مصاريف',
  ),
  PermissionModel(
    id: PermissionModel.EXPENDITURE_READ_ALL,
    titleEnglish: PermissionModel.EXPENDITURE_READ_ALL,
    titlePersian: 'مشاهده تمام هزینه ها',
    titleArabic: 'قراه كل مصاريف',
  ),
  PermissionModel(
    id: PermissionModel.EXPENDITURE_READ_OWN,
    titleEnglish: PermissionModel.EXPENDITURE_READ_OWN,
    titlePersian: 'مشاهده هزینه های خودم',
    titleArabic: 'قراه مصاريفي',
  ),
  PermissionModel(
    id: PermissionModel.EXPENDITURE_EDIT_ALL,
    titleEnglish: PermissionModel.EXPENDITURE_EDIT_ALL,
    titlePersian: 'اصلاح تمام هزینه ها',
    titleArabic: 'تصليح كل مصاريف',
  ),
  PermissionModel(
    id: PermissionModel.EXPENDITURE_EDIT_OWN,
    titleEnglish: PermissionModel.EXPENDITURE_EDIT_OWN,
    titlePersian: 'اصلاح هزینه های خودم',
    titleArabic: 'تصليح مصاريفي',
  ),
  PermissionModel(
    id: PermissionModel.EXPENDITURE_DELETE_ALL,
    titleEnglish: PermissionModel.EXPENDITURE_DELETE_ALL,
    titlePersian: 'حذف تمام هزینه ها',
    titleArabic: 'حذف كل مصاريف',
  ),
  PermissionModel(
    id: PermissionModel.EXPENDITURE_DELETE_OWN,
    titleEnglish: PermissionModel.EXPENDITURE_DELETE_OWN,
    titlePersian: 'حذف هزینه های خودم',
    titleArabic: 'حذف مصاريفي',
  ),

  // ## SELL_POINT
  PermissionModel(
    id: PermissionModel.SELL_POINT_CATEGORY,
    titleEnglish: PermissionModel.SELL_POINT_CATEGORY,
    titlePersian: 'گروه فروش',
    titleArabic: 'بیع',
  ),

  // ## RETAIL
  PermissionModel(
    id: PermissionModel.RETAIL_CATEGORY,
    titleEnglish: PermissionModel.RETAIL_CATEGORY,
    titlePersian: 'خرده فروشي',
    titleArabic: 'بيع جزئي',
  ),
  PermissionModel(
    id: PermissionModel.RETAIL_CREATE,
    titleEnglish: PermissionModel.RETAIL_CREATE,
    titlePersian: 'ايجاد فروش خرده',
    titleArabic: 'ايجاد بيع جزئي',
  ),
  PermissionModel(
    id: PermissionModel.RETAIL_READ_ALL,
    titleEnglish: PermissionModel.RETAIL_READ_ALL,
    titlePersian: 'مشاهده تمام فروش خرد',
    titleArabic: 'قراة كل بيع جزئي',
  ),
  PermissionModel(
    id: PermissionModel.RETAIL_READ_OWN,
    titleEnglish: PermissionModel.RETAIL_READ_OWN,
    titlePersian: 'مشاهده فروش خرد خودم',
    titleArabic: 'قراة بيع جزء انا',
  ),
  PermissionModel(
    id: PermissionModel.RETAIL_EDIT_ALL,
    titleEnglish: PermissionModel.RETAIL_EDIT_ALL,
    titlePersian: 'اصلاح تمام فروش خرد',
    titleArabic: 'اصلاح جميع بيع جزء',
  ),
  PermissionModel(
    id: PermissionModel.RETAIL_EDIT_OWN,
    titleEnglish: PermissionModel.RETAIL_EDIT_OWN,
    titlePersian: 'اصلاح فروش خرد خودم',
    titleArabic: 'اصلاح بيع جزء انا',
  ),
  PermissionModel(
    id: PermissionModel.RETAIL_DELETE_ALL,
    titleEnglish: PermissionModel.RETAIL_DELETE_ALL,
    titlePersian: 'حذف تمام فروش خرد',
    titleArabic: 'حذف تمام بيع جزء',
  ),
  PermissionModel(
    id: PermissionModel.RETAIL_DELETE_OWN,
    titleEnglish: PermissionModel.RETAIL_DELETE_OWN,
    titlePersian: 'حذف فروش خرد خودم',
    titleArabic: 'حذف بيع جزء انا',
  ),

  // ## WHOLESALE
  PermissionModel(
    id: PermissionModel.WHOLESALE_CATEGORY,
    titleEnglish: PermissionModel.WHOLESALE_CATEGORY,
    titlePersian: 'عمده فروشي',
    titleArabic: 'بيع عمده',
  ),
  PermissionModel(
    id: PermissionModel.WHOLESALE_CREATE,
    titleEnglish: PermissionModel.WHOLESALE_CREATE,
    titlePersian: 'ايجاد فروش عمده',
    titleArabic: 'ايجاد بيع جملة',
  ),
  PermissionModel(
    id: PermissionModel.WHOLESALE_READ_ALL,
    titleEnglish: PermissionModel.WHOLESALE_READ_ALL,
    titlePersian: 'مشاهده تمام فروش عمده',
    titleArabic: 'قراة كل بيع جملة',
  ),
  PermissionModel(
    id: PermissionModel.WHOLESALE_READ_OWN,
    titleEnglish: PermissionModel.WHOLESALE_READ_OWN,
    titlePersian: 'مشاهده فروش عمده خودم',
    titleArabic: 'قراة بيع جملة انا',
  ),
  PermissionModel(
    id: PermissionModel.WHOLESALE_EDIT_ALL,
    titleEnglish: PermissionModel.WHOLESALE_EDIT_ALL,
    titlePersian: 'اصلاح تمام فروش عمده',
    titleArabic: 'اصلاح كل بيع جملة',
  ),
  PermissionModel(
    id: PermissionModel.WHOLESALE_EDIT_OWN,
    titleEnglish: PermissionModel.WHOLESALE_EDIT_OWN,
    titlePersian: 'اصلاح فروش عمده خودم',
    titleArabic: 'اصلاح بيع جملة انا',
  ),
  PermissionModel(
    id: PermissionModel.WHOLESALE_DELETE_ALL,
    titleEnglish: PermissionModel.WHOLESALE_DELETE_ALL,
    titlePersian: 'حذف تمام فروش عمده',
    titleArabic: 'حذف كل بيع جملة',
  ),
  PermissionModel(
    id: PermissionModel.WHOLESALE_DELETE_OWN,
    titleEnglish: PermissionModel.WHOLESALE_DELETE_OWN,
    titlePersian: 'حذف فروش عمده خودم',
    titleArabic: 'حذف بيع جملة انا',
  ),

  // ## PURCHAS
  PermissionModel(
    id: PermissionModel.PURCHAS_CATEGORY,
    titleEnglish: PermissionModel.PURCHAS_CATEGORY,
    titlePersian: 'خريد',
    titleArabic: 'شراء',
  ),
  PermissionModel(
    id: PermissionModel.PURCHAS_CREATE,
    titleEnglish: PermissionModel.PURCHAS_CREATE,
    titlePersian: 'ايجاد فاكتور خريد',
    titleArabic: 'ايجاد فواتير شراء',
  ),
  PermissionModel(
    id: PermissionModel.PURCHAS_READ_ALL,
    titleEnglish: PermissionModel.PURCHAS_READ_ALL,
    titlePersian: 'مشاهده تمام فاكتور خريد',
    titleArabic: 'قراة كل فواتير شراء',
  ),
  PermissionModel(
    id: PermissionModel.PURCHAS_READ_OWN,
    titleEnglish: PermissionModel.PURCHAS_READ_OWN,
    titlePersian: 'مشاهده فاكتور خريد خودم',
    titleArabic: 'قراءة فواتير شراء حالي',
  ),
  PermissionModel(
    id: PermissionModel.PURCHAS_EDIT_ALL,
    titleEnglish: PermissionModel.PURCHAS_EDIT_ALL,
    titlePersian: 'اصلاح تمام فاكتور خريد',
    titleArabic: 'اصلاح كل فواتير شراء',
  ),
  PermissionModel(
    id: PermissionModel.PURCHAS_EDIT_OWN,
    titleEnglish: PermissionModel.PURCHAS_EDIT_OWN,
    titlePersian: 'اصلاح فاكتور خريد خودم',
    titleArabic: 'اصلاح فواتير شراء حالي',
  ),
  PermissionModel(
    id: PermissionModel.PURCHAS_DELETE_ALL,
    titleEnglish: PermissionModel.PURCHAS_DELETE_ALL,
    titlePersian: 'حذف تمام فاكتور خريد',
    titleArabic: 'حذف كل فواتير شراء',
  ),
  PermissionModel(
    id: PermissionModel.PURCHAS_DELETE_OWN,
    titleEnglish: PermissionModel.PURCHAS_DELETE_OWN,
    titlePersian: 'حذف فاكتور خريد خودم',
    titleArabic: 'حذف فواتير شراء حالي',
  ),

  // ## ITEM
  PermissionModel(
    id: PermissionModel.ITEM_CATEGORY,
    titleEnglish: PermissionModel.ITEM_CATEGORY,
    titlePersian: 'اجناس',
    titleArabic: 'اجناس',
  ),
  PermissionModel(
    id: PermissionModel.ITEM_CREATE,
    titleEnglish: PermissionModel.ITEM_CREATE,
    titlePersian: 'ايجاد جنس',
    titleArabic: 'ايجاد صنف',
  ),
  PermissionModel(
    id: PermissionModel.ITEM_READ_ALL,
    titleEnglish: PermissionModel.ITEM_READ_ALL,
    titlePersian: 'مشاهده تمام اجناس',
    titleArabic: 'قراة كل اصناف',
  ),
  PermissionModel(
    id: PermissionModel.ITEM_READ_OWN,
    titleEnglish: PermissionModel.ITEM_READ_OWN,
    titlePersian: 'مشاهده اجناس خودم',
    titleArabic: 'قراءة اصناف حالي',
  ),
  PermissionModel(
    id: PermissionModel.ITEM_EDIT_ALL,
    titleEnglish: PermissionModel.ITEM_EDIT_ALL,
    titlePersian: 'اصلاح تمام اجناس',
    titleArabic: 'اصلاح كل اصناف',
  ),
  PermissionModel(
    id: PermissionModel.ITEM_EDIT_OWN,
    titleEnglish: PermissionModel.ITEM_EDIT_OWN,
    titlePersian: 'اصلاح اجناس خودم',
    titleArabic: 'اصلاح اصناف حالي',
  ),
  PermissionModel(
    id: PermissionModel.ITEM_DELETE_ALL,
    titleEnglish: PermissionModel.ITEM_DELETE_ALL,
    titlePersian: 'حذف تمام اجناس',
    titleArabic: 'حذف كل اصناف',
  ),
  PermissionModel(
    id: PermissionModel.ITEM_DELETE_OWN,
    titleEnglish: PermissionModel.ITEM_DELETE_OWN,
    titlePersian: 'حذف اجناس خودم',
    titleArabic: 'حذف اصناف حالي',
  ),

  // ## MONEY_MOVEMENT
  PermissionModel(
    id: PermissionModel.MONEY_MOVEMENT_CATEGORY,
    titleEnglish: PermissionModel.MONEY_MOVEMENT_CATEGORY,
    titlePersian: 'گردش های مالی',
    titleArabic: 'حركات مالية',
  ),
  PermissionModel(
    id: PermissionModel.MONEY_MOVEMENT_CREATE,
    titleEnglish: PermissionModel.MONEY_MOVEMENT_CREATE,
    titlePersian: 'ايجاد گردش های مالی',
    titleArabic: 'ايجاد حركات مالية',
  ),
  PermissionModel(
    id: PermissionModel.MONEY_MOVEMENT_READ_ALL,
    titleEnglish: PermissionModel.MONEY_MOVEMENT_READ_ALL,
    titlePersian: 'مشاهده تمام گردش های مالی',
    titleArabic: 'قراة كل حركات مالية',
  ),
  PermissionModel(
    id: PermissionModel.MONEY_MOVEMENT_READ_OWN,
    titleEnglish: PermissionModel.MONEY_MOVEMENT_READ_OWN,
    titlePersian: 'مشاهده گردش های مالی خودم',
    titleArabic: 'قراءة حركات مالية حالي',
  ),
  PermissionModel(
    id: PermissionModel.MONEY_MOVEMENT_EDIT_ALL,
    titleEnglish: PermissionModel.MONEY_MOVEMENT_EDIT_ALL,
    titlePersian: 'اصلاح تمام گردش های مالی',
    titleArabic: 'اصلاح كل حركات مالية',
  ),
  PermissionModel(
    id: PermissionModel.MONEY_MOVEMENT_EDIT_OWN,
    titleEnglish: PermissionModel.MONEY_MOVEMENT_EDIT_OWN,
    titlePersian: 'اصلاح گردش های مالی خودم',
    titleArabic: 'اصلاح حركات مالية حالي',
  ),
  PermissionModel(
    id: PermissionModel.MONEY_MOVEMENT_DELETE_ALL,
    titleEnglish: PermissionModel.MONEY_MOVEMENT_DELETE_ALL,
    titlePersian: 'حذف تمام گردش های مالی',
    titleArabic: 'حذف كل حركات مالية',
  ),
  PermissionModel(
    id: PermissionModel.MONEY_MOVEMENT_DELETE_OWN,
    titleEnglish: PermissionModel.MONEY_MOVEMENT_DELETE_OWN,
    titlePersian: 'حذف گردش های مالی خودم',
    titleArabic: 'حذف حركات مالية حالي',
  ),

  // ## REPORT
  PermissionModel(
    id: PermissionModel.REPORT_CATEGORY,
    titleEnglish: PermissionModel.REPORT_CATEGORY,
    titlePersian: 'گزارش ها',
    titleArabic: 'تقارير',
  ),
  PermissionModel(
    id: PermissionModel.REPORT_READ_ALL,
    titleEnglish: PermissionModel.REPORT_READ_ALL,
    titlePersian: 'مشاهده تمام گزارش ها',
    titleArabic: 'قراة كل تقارير',
  ),

  // ## ACCOUNT
  PermissionModel(
    id: PermissionModel.ACCOUNT_CATEGORY,
    titleEnglish: PermissionModel.ACCOUNT_CATEGORY,
    titlePersian: 'حساب های مالی',
    titleArabic: 'حسابات مالية',
  ),
  PermissionModel(
    id: PermissionModel.ACCOUNT_CREATE,
    titleEnglish: PermissionModel.ACCOUNT_CREATE,
    titlePersian: 'ايجاد حساب های مالی',
    titleArabic: 'ايجاد حسابات مالية',
  ),
  PermissionModel(
    id: PermissionModel.ACCOUNT_READ_ALL,
    titleEnglish: PermissionModel.ACCOUNT_READ_ALL,
    titlePersian: 'مشاهده تمام حساب های مالی',
    titleArabic: 'قراة كل حسابات مالية',
  ),
  PermissionModel(
    id: PermissionModel.ACCOUNT_READ_OWN,
    titleEnglish: PermissionModel.ACCOUNT_READ_OWN,
    titlePersian: 'مشاهده حساب های مالی خودم',
    titleArabic: 'قراءة حسابات مالية حالي',
  ),
  PermissionModel(
    id: PermissionModel.ACCOUNT_EDIT_ALL,
    titleEnglish: PermissionModel.ACCOUNT_EDIT_ALL,
    titlePersian: 'اصلاح تمام حساب های مالی',
    titleArabic: 'اصلاح كل حسابات مالية',
  ),
  PermissionModel(
    id: PermissionModel.ACCOUNT_EDIT_OWN,
    titleEnglish: PermissionModel.ACCOUNT_EDIT_OWN,
    titlePersian: 'اصلاح حساب های مالی خودم',
    titleArabic: 'اصلاح حسابات مالية حالي',
  ),
  PermissionModel(
    id: PermissionModel.ACCOUNT_DELETE_ALL,
    titleEnglish: PermissionModel.ACCOUNT_DELETE_ALL,
    titlePersian: 'حذف تمام حساب های مالی',
    titleArabic: 'حذف كل حسابات مالية',
  ),
  PermissionModel(
    id: PermissionModel.ACCOUNT_DELETE_OWN,
    titleEnglish: PermissionModel.ACCOUNT_DELETE_OWN,
    titlePersian: 'حذف حساب های مالی خودم',
    titleArabic: 'حذف حسابات مالية حالي',
  ),

  // ## ITEM_SUMMERY
  PermissionModel(
    id: PermissionModel.ITEM_SUMMERY_CATEGORY,
    titleEnglish: PermissionModel.ITEM_SUMMERY_CATEGORY,
    titlePersian: 'سابقه اجناس',
    titleArabic: 'سابقة اجناس',
  ),
];
