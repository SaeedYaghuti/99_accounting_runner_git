import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/categories/categories_overview_screen.dart';
import 'package:shop/accounting/categories/sub_categories_screen.dart';
import 'package:shop/accounting/environment/environment_provider.dart';
import 'package:shop/accounting/expenditure/expenditure_screen.dart';
import 'package:shop/accounting/sell_point/sell_point_screen.dart';
import 'package:shop/auth/firebase/auth_provider.dart';
// import 'package:shop/auth/auth_provider.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/auth/auth_screen.dart';
import 'package:shop/constants.dart';
import 'package:shop/shared/custom_form_fields/form_fields_screen.dart';
import 'package:shop/shared/loading_screen.dart';
import 'package:shop/shared/storage_type.dart';
import 'package:shop/shared/test_screen/test_screen.dart';

class AccountingApp extends StatelessWidget {
  const AccountingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => AuthProviderSQL()),
        ChangeNotifierProvider(create: (ctx) => EnvironmentProvider()),
      ],
      child: MaterialApp(
        title: 'Accounting App',
        theme: _buildTheme(),
        home: STORAGE_TYPE == StorageType.FIREBASE
            ? _buildCategoriesOverviewScreenOrAuthFirebase()
            : _buildCategoriesOverviewScreenOrAuthSQL(),
        routes: _buildRoutes(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primarySwatch: Colors.purple,
      accentColor: Colors.deepOrange,
      fontFamily: 'Lato',
    );
  }

  Widget _buildCategoriesOverviewScreenOrAuthSQL() {
    return Consumer<AuthProviderSQL>(
      builder: (ctx, authProvider, child) => authProvider.isAuth ? CategoriesOverviewScreen() : AuthScreen(),
    );
  }

  Widget _buildCategoriesOverviewScreenOrAuthFirebase() {
    return Consumer<AuthProvider>(
      builder: (ctx, authProvider, child) => authProvider.isAuth
          ? CategoriesOverviewScreen()
          : FutureBuilder(
              future: authProvider.tryAutoLogin(),
              builder: (ctx, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting ? LoadingScreen() : AuthScreen(),
            ),
    );
  }

  _buildRoutes() {
    return {
      SubCategoriesScreen.routeName: (ctx) => SubCategoriesScreen(),
      RetailScreen.routeName: (ctx) => RetailScreen(),
      ExpenditureScreen.routeName: (ctx) => ExpenditureScreen(),
      FormFieldScreen.routeName: (ctx) => FormFieldScreen(),
      TestScreen.routeName: (ctx) => TestScreen(),
    };
  }
}
