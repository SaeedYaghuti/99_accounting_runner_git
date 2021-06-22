import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/categories/category_model.dart';
import 'package:shop/accounting/common/supported_language.dart';
import 'package:shop/accounting/environment/environment_provider.dart';

class MultiLanguageCategoryTitle extends StatelessWidget {
  final CategoryModel category;
  final TextStyle? style;
  const MultiLanguageCategoryTitle({
    Key? key,
    required this.category,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EnvironmentProvider>(
      builder: (ctx, envProvider, child) => Text(
        _buildTitle(envProvider),
        style: style,
      ),
    );
  }

  String _buildTitle(EnvironmentProvider envProvider) {
    switch (envProvider.selectedLanguage) {
      case SuportedLanguage.English:
        return category.titleEnglish;
      case SuportedLanguage.Persian:
        return category.titlePersian;
      case SuportedLanguage.Arabic:
        return category.titleArabic;
      default:
        return 'MLTW01| not suported language';
    }
  }
}
