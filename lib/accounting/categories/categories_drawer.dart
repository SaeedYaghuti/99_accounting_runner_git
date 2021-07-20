import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/accounting_logic/run_code.dart'
    as AccountRunCode;
import 'package:shop/auth/run_code.dart' as AuthRunCode;
import 'package:shop/accounting/common/multi_language_text_widget.dart';
import 'package:shop/auth/auth_db_helper.dart';
import 'package:shop/auth/firebase/auth_provider.dart';
import 'package:shop/auth/auth_provider_sql.dart';
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
              english: 'Run Accounting Code',
              persian: 'اجراى كد',
              arabic: "اجراي كد",
            ),
            onTap: () {
              AccountRunCode.runCode();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.code_rounded),
            title: MultiLanguageTextWidget(
              english: 'Run Auth Code',
              persian: 'اجراى كد',
              arabic: "اجراي كد",
            ),
            onTap: () async {
              await AuthRunCode.runCode(context);
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.storage_rounded),
            title: MultiLanguageTextWidget(
              english: 'Delete Auth Database',
              persian: 'حذف ديتابيس',
              arabic: "حذف ديتابيس",
            ),
            onTap: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              await AuthDB.deleteDB();
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.storage_outlined),
            title: MultiLanguageTextWidget(
              english: 'Delete Account Database',
              persian: 'حذف ديتابيس',
              arabic: "حذف ديتابيس",
            ),
            onTap: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              await AccountingDB.deleteDB();
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
