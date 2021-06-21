import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/auth/auth_provider.dart';
import 'package:shop/auth/auth_screen.dart';
import 'package:shop/shared/loading_screen.dart';

class AccountingApp extends StatelessWidget {
  const AccountingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Accounting App',
        theme: _buildTheme(),
        home: _buildCategoriesOverviewScreenOrAuth(),
      ),
    );
  }

  Widget _buildCategoriesOverviewScreenOrAuth() {
    return Consumer<AuthProvider>(
      builder: (ctx, authProvider, child) => authProvider.isAuth
          ? Text('CategoryScreen')
          : FutureBuilder(
              future: authProvider.tryAutoLogin(),
              builder: (ctx, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? LoadingScreen()
                      : AuthScreen(),
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
}
