import 'dart:ui';

class CategoryModel {
  final String id;
  final String titleEnglish;
  final String titlePersian;
  final String titleArabic;
  final Color color;
  final String parentId;
  final String routeName;
  final String requiredPermission;
  // final Icon icon;
  // final String imageUrl;
  const CategoryModel({
    required this.id,
    required this.titleEnglish,
    required this.titlePersian,
    required this.titleArabic,
    required this.color,
    required this.parentId,
    required this.requiredPermission,
    this.routeName = '',
  });
}
