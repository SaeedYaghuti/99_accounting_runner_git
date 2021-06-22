import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/categories/categories_tree.dart';
import 'package:shop/accounting/categories/category_model.dart';
import 'package:shop/accounting/common/multi_language_category_title.dart';
import 'package:shop/accounting/common/multi_language_text_widget.dart';
import 'package:shop/accounting/common/supported_language.dart';
import 'package:shop/accounting/environment/environment_provider.dart';

import 'categories_grid.dart';

class SubCategoriesScreen extends StatefulWidget {
  static const routeName = '/sub-categories-screen';
  const SubCategoriesScreen({Key? key}) : super(key: key);

  @override
  _SubCategoriesScreenState createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  String? categoryId;
  CategoryModel? category;
  var _selectedLanguage = SuportedLanguage.English;
  var _isFresh = true;
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var environmenProvider =
        Provider.of<EnvironmentProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(),
        actions: [
          _buildPopupMenuButton(environmenProvider),
        ],
      ),
      // drawer: ,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : CategoriesGrid(category!.id),
    );
  }

  Widget _buildTitle() {
    return MultiLanguageCategoryTitle(
      category: category!,
      style: Theme.of(context).textTheme.headline3,
    );
  }

  Widget _buildPopupMenuButton(EnvironmentProvider environmentProvider) {
    return PopupMenuButton(
      icon: _buildPopupIcon(),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          child: Text('English'),
          value: SuportedLanguage.English,
        ),
        PopupMenuItem(
          child: Text('فارسى'),
          value: SuportedLanguage.Persian,
        ),
        PopupMenuItem(
          child: Text('عربي'),
          value: SuportedLanguage.Arabic,
        ),
      ],
      onSelected: (SuportedLanguage selectedLanguage) {
        setState(() {
          _selectedLanguage = selectedLanguage;
          environmentProvider.setLanguage(selectedLanguage);
        });
      },
    );
  }

  Widget _buildPopupIcon() {
    return Container(
      // width: 50,
      // height: 80,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        border: Border.all(color: Theme.of(context).accentColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _selectedLanguage == SuportedLanguage.English
            ? 'A'
            : _selectedLanguage == SuportedLanguage.Persian
                ? 'ف'
                : _selectedLanguage == SuportedLanguage.Arabic
                    ? 'ع'
                    : 'X',
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    if (_isFresh) {
      category = ModalRoute.of(context)?.settings.arguments as CategoryModel?;
    }
    super.didChangeDependencies();
  }

  void _loadingStart() {
    setState(() {
      _isLoading = true;
    });
  }

  void _loadingEnd() {
    setState(() {
      _isLoading = false;
    });
  }
}
