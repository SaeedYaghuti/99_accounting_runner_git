import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/categories/category_model.dart';
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
          child: _buildTextListenToSelectedLanguage(),
        ),
        decoration: _buildRoundedColorfullBackground(),
      ),
      onTap: () => categoryTapHandler(context),
    );
  }

  void categoryTapHandler(BuildContext context) {
    print('Tap on Category event!');
    // Navigator.of(context).pushNamed(SubcategoriesOverviewScreen.routeName, arguments: {'id', category.id, 'title': category.titleEnglish,);
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
}
