import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/categories/category_model.dart';
import 'package:shop/accounting/expenditure/expenditure_screen.dart';
import 'package:shop/accounting/sell_point/sell_point_screen.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/auth/permission_model.dart';
import 'package:shop/shared/custom_form_fields/form_fields_screen.dart';

const CATEGORIES_TREE = const [
  CategoryModel(
    id: 'sell-point',
    titleEnglish: 'Sell Point',
    titlePersian: 'فروش',
    titleArabic: 'مبيعات',
    color: Colors.green,
    parentId: 'root',
    requiredPermission: PermissionModel.SELL_POINT_CATEGORY,
  ),
  CategoryModel(
    id: 'expences',
    titleEnglish: 'Expences',
    titlePersian: 'هزينه',
    titleArabic: 'مصاريف',
    color: Colors.pink,
    parentId: 'root',
    routeName: ExpenditureScreen.routeName,
    requiredPermission: PermissionModel.EXPENDITURE_CATEGORY,
  ),
  CategoryModel(
    id: 'purchas',
    titleEnglish: 'Purchase',
    titlePersian: 'خريد',
    titleArabic: 'مشتريات',
    color: Colors.orange,
    parentId: 'root',
    requiredPermission: PermissionModel.PURCHAS_CATEGORY,
  ),
  CategoryModel(
    id: 'items',
    titleEnglish: 'Items',
    titlePersian: 'اجناس',
    titleArabic: 'بضاعة',
    color: Colors.grey,
    parentId: 'root',
    requiredPermission: PermissionModel.ITEM_CATEGORY,
  ),
  CategoryModel(
    id: 'money-movement',
    titleEnglish: 'Money Movement',
    titlePersian: 'دريافتى و برداختي',
    titleArabic: 'حركة مالية',
    color: Colors.purple,
    parentId: 'root',
    requiredPermission: PermissionModel.MONEY_MOVEMENT_CATEGORY,
  ),
  CategoryModel(
    id: 'reports',
    titleEnglish: 'Reports',
    titlePersian: 'كزارش',
    titleArabic: 'تقارير',
    color: Colors.blue,
    parentId: 'root',
    requiredPermission: PermissionModel.REPORT_CATEGORY,
  ),
  CategoryModel(
    id: 'accounts',
    titleEnglish: 'Accounts',
    titlePersian: 'حساب هاى مالى',
    titleArabic: 'نقاط المالية',
    color: Colors.brown,
    parentId: 'root',
    requiredPermission: PermissionModel.ACCOUNT_CATEGORY,
  ),
  CategoryModel(
    id: 'retail',
    titleEnglish: 'Retail',
    titlePersian: 'تك فروشي',
    titleArabic: 'بيع بالجزء',
    color: Colors.blueGrey,
    parentId: 'sell-point',
    routeName: RetailScreen.routeName,
    requiredPermission: PermissionModel.RETAIL_CATEGORY,
  ),
  CategoryModel(
    id: 'wholesale',
    titleEnglish: 'Wholesale',
    titlePersian: 'عمده فروشي',
    titleArabic: 'بيع بالجملة',
    color: Colors.greenAccent,
    parentId: 'sell-point',
    requiredPermission: PermissionModel.WHOLESALE_CATEGORY,
  ),
  CategoryModel(
    id: 'manage-items',
    titleEnglish: 'Manage Items',
    titlePersian: 'مدبريت اجناس',
    titleArabic: 'تصليح اقلام',
    color: Colors.purple,
    parentId: 'items',
    requiredPermission: PermissionModel.MONEY_MOVEMENT_CATEGORY,
  ),
  CategoryModel(
    id: 'item-summery',
    titleEnglish: 'Items Summery',
    titlePersian: 'تاريخجه محصولات',
    titleArabic: 'حركة اقلام',
    color: Colors.deepOrange,
    parentId: 'items',
    requiredPermission: PermissionModel.ITEM_SUMMERY_CATEGORY,
  ),
  CategoryModel(
    id: 'test_screen',
    titleEnglish: 'Test Screen',
    titlePersian: 'آزمايش',
    titleArabic: ' امتحان',
    color: Colors.deepOrange,
    parentId: 'root',
    // TODO: defined Permitted
    requiredPermission: PermissionModel.SELL_POINT_CATEGORY,
    routeName: FormFieldsScreen.routeName,
  ),
];

List<CategoryModel> getSubcategoriesOf(BuildContext context, String parentId) {
  // print('CAT_TREES getSubcats 01| run ...');
  var authProvider = Provider.of<AuthProviderSQL>(
    context,
    listen: true,
  );

  // print('CAT_TREES getSubcats 02| authProvider.userId: ${authProvider.userId}');
  return CATEGORIES_TREE
      .where((category) => category.parentId == parentId && authProvider.isPermitted(category.requiredPermission))
      .toList();
}
