import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/common/multi_language_text_widget.dart';
import 'package:shop/auth/firebase/auth_provider.dart';
import 'package:shop/auth/local/auth_provider_sql.dart';

class CategoriesDrawer extends StatelessWidget {
  const CategoriesDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: MultiLanguageTextWidget(
              english: 'Accounting',
              persian: 'حسابدارى',
              arabic: "تدقيق مالية",
            ),
            automaticallyImplyLeading: false, // don't show hambergerbutton
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: MultiLanguageTextWidget(
              english: 'Logout',
              persian: 'خروج',
              arabic: "خروج",
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<AuthProviderSQL>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
