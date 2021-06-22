import 'package:flutter/material.dart';
import 'package:shop/accounting/categories/category_model.dart';

const CATEGORIES_TREE = const [
  CategoryModel(
    id: 'sell-point',
    titleEnglish: 'Sell Point',
    titlePersian: 'فروش',
    titleArabic: 'مبيعات',
    color: Colors.green,
    parentId: 'root',
  ),
  CategoryModel(
    id: 'expences',
    titleEnglish: 'Expences',
    titlePersian: 'هزينه',
    titleArabic: 'مصاريف',
    color: Colors.pink,
    parentId: 'root',
  ),
  CategoryModel(
    id: 'purchas',
    titleEnglish: 'Purchase',
    titlePersian: 'خريد',
    titleArabic: 'مشتريات',
    color: Colors.orange,
    parentId: 'root',
  ),
  CategoryModel(
    id: 'items',
    titleEnglish: 'Items',
    titlePersian: 'اجناس',
    titleArabic: 'بضاعة',
    color: Colors.grey,
    parentId: 'root',
  ),
  CategoryModel(
    id: 'money-movement',
    titleEnglish: 'Money Movement',
    titlePersian: 'دريافتى و برداختي',
    titleArabic: 'حركة مالية',
    color: Colors.purple,
    parentId: 'root',
  ),
  CategoryModel(
    id: 'reports',
    titleEnglish: 'Reports',
    titlePersian: 'كزارش',
    titleArabic: 'تقارير',
    color: Colors.blue,
    parentId: 'root',
  ),
  CategoryModel(
    id: 'accounts',
    titleEnglish: 'Accounts',
    titlePersian: 'حساب هاى مالى',
    titleArabic: 'نقاط المالية',
    color: Colors.brown,
    parentId: 'root',
  ),
  CategoryModel(
    id: 'retail',
    titleEnglish: 'Retail',
    titlePersian: 'تك فروشي',
    titleArabic: 'بيع بالجزء',
    color: Colors.blueGrey,
    parentId: 'sell-point',
  ),
  CategoryModel(
    id: 'wholesale',
    titleEnglish: 'Wholesale',
    titlePersian: 'عمده فروشي',
    titleArabic: 'بيع بالجملة',
    color: Colors.greenAccent,
    parentId: 'sell-point',
  ),
  CategoryModel(
    id: 'manage-items',
    titleEnglish: 'Manage Items',
    titlePersian: 'مدبريت اجناس',
    titleArabic: 'تصليح اقلام',
    color: Colors.purple,
    parentId: 'items',
  ),
  CategoryModel(
    id: 'item-summery',
    titleEnglish: 'Items Summery',
    titlePersian: 'تاريخجه محصولات',
    titleArabic: 'حركة اقلام',
    color: Colors.deepOrange,
    parentId: 'items',
  ),
];

List<CategoryModel> getSubcategoriesOf(String parentId) {
  return CATEGORIES_TREE
      .where((category) => category.parentId == parentId)
      .toList();
}
