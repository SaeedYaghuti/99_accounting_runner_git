import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/common/supported_language.dart';
import 'package:shop/accounting/environment/environment_provider.dart';

class FlexiblePopupMenuButton extends StatefulWidget {
  const FlexiblePopupMenuButton({Key? key}) : super(key: key);

  @override
  _FlexiblePopupMenuButtonState createState() =>
      _FlexiblePopupMenuButtonState();
}

class _FlexiblePopupMenuButtonState extends State<FlexiblePopupMenuButton> {
  @override
  Widget build(BuildContext context) {
    var environmentProvider =
        Provider.of<EnvironmentProvider>(context, listen: true);
    var _selectedLanguage = environmentProvider.selectedLanguage;
    return PopupMenuButton(
      icon: _buildPopupIcon(_selectedLanguage),
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

  Widget _buildPopupIcon(SuportedLanguage _selectedLanguage) {
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
}
