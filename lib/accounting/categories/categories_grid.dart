import 'package:flutter/material.dart';
import 'package:shop/accounting/categories/categories_tree.dart';
import 'package:shop/accounting/categories/category_model.dart';
import 'package:shop/accounting/categories/category_widget.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 30,
        mainAxisSpacing: 30,
      ),
      children: getSubcategoryOf('root')
          .map((category) => CategoryWidget(category: category))
          .toList(),
    );
  }

  List<CategoryModel> getSubcategoryOf(String parentId) {
    return CATEGORIES_TREE
        .where((category) => category.parentId == parentId)
        .toList();
  }
}
