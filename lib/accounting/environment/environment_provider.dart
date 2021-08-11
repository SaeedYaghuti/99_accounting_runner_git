import 'package:flutter/material.dart';
import 'package:shop/accounting/common/supported_language.dart';

class EnvironmentProvider with ChangeNotifier {
  SuportedLanguage _selectedLanguage = SuportedLanguage.English;

  void setLanguage(SuportedLanguage language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  SuportedLanguage get selectedLanguage {
    return _selectedLanguage;
  }

  static const initializeExpenditureForm = false;
  static const initializeTransClassForm = false;
}
