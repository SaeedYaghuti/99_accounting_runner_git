import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/categories/category_model.dart';
import 'package:shop/accounting/categories/sub_categories_screen.dart';
import 'package:shop/accounting/common/multi_language_category_title.dart';
import 'package:shop/accounting/common/supported_language.dart';
import 'package:shop/accounting/environment/environment_provider.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryModel category;
  const CategoryWidget({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Center(
          child: _buildTitle(),
        ),
        decoration: _buildRoundedColorfullBackground(),
      ),
      onTap: () => categoryTapHandler(context),
    );
  }

  BoxDecoration _buildRoundedColorfullBackground() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      gradient: LinearGradient(
        colors: [category.color.withOpacity(0.7), category.color],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  Widget _buildTitle() {
    return MultiLanguageCategoryTitle(
      category: category,
      style: TextStyle(
        color: Colors.white,
        fontSize: 36,
        fontFamily: 'Lato',
      ),
    );
  }

  _buildTextListenToSelectedLanguage() {
    return Consumer<EnvironmentProvider>(
      builder: (ctx, envirenmentProvider, child) => Text(
        envirenmentProvider.selectedLanguage == SuportedLanguage.English
            ? category.titleEnglish
            : envirenmentProvider.selectedLanguage == SuportedLanguage.Persian
                ? category.titlePersian
                : envirenmentProvider.selectedLanguage ==
                        SuportedLanguage.Arabic
                    ? category.titleArabic
                    : 'not supported language', // should change accouding selected language
        style: TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontFamily: 'Lato',
        ),
      ),
    );
  }

  void categoryTapHandler(BuildContext context) {
    if (category.routeName.isEmpty) {
      Navigator.of(context).pushNamed(
        SubCategoriesScreen.routeName,
        arguments: category,
      );
    } else {
      Navigator.of(context).pushNamed(
        category.routeName,
        arguments: category,
      );
    }
  }
}
