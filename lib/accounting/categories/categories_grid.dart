import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/categories/categories_tree.dart';
import 'package:shop/accounting/categories/category_model.dart';
import 'package:shop/accounting/categories/category_widget.dart';
import 'package:shop/auth/auth_provider_sql.dart';

class CategoriesGrid extends StatelessWidget {
  final String parentId;
  const CategoriesGrid(
    this.parentId, {
    Key? key,
  }) : super(key: key);

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
      children: getSubcategoriesOf(context, parentId)
          .map((category) => CategoryWidget(category: category))
          .toList(),
    );
  }
}
