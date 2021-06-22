import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/common/supported_language.dart';
import 'package:shop/accounting/environment/environment_provider.dart';

class MultiLanguageTextWidget extends StatelessWidget {
  final String english;
  final String persian;
  final String arabic;
  final TextStyle? style;
  const MultiLanguageTextWidget({
    Key? key,
    required this.english,
    required this.persian,
    required this.arabic,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EnvironmentProvider>(
      builder: (ctx, envProvider, child) => Text(
        _buildString(envProvider),
        style: style,
      ),
    );
  }

  String _buildString(EnvironmentProvider envProvider) {
    switch (envProvider.selectedLanguage) {
      case SuportedLanguage.English:
        return english;
      case SuportedLanguage.Persian:
        return persian;
      case SuportedLanguage.Arabic:
        return arabic;
      default:
        return 'MLTW01| not suported language';
    }
  }
}
