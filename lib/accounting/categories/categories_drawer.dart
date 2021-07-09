import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/common/multi_language_text_widget.dart';
import 'package:shop/auth/auth_db_helper.dart';
import 'package:shop/auth/firebase/auth_provider.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/auth/run_code.dart';
import 'package:shop/constants.dart';
import 'package:shop/shared/storage_type.dart';

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
              if (STORAGE_TYPE == StorageType.SQL)
                Provider.of<AuthProviderSQL>(context, listen: false).logout();
              if (STORAGE_TYPE == StorageType.FIREBASE)
                Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.code_rounded),
            title: MultiLanguageTextWidget(
              english: 'Run Code',
              persian: 'اجراى كد',
              arabic: "اجراي كد",
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              runCode();
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.storage_rounded),
            title: MultiLanguageTextWidget(
              english: 'Delete Database',
              persian: 'حذف ديتابيس',
              arabic: "حذف ديتابيس",
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              AuthDB.deleteDB();
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
