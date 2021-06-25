import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/db/accounting_db.dart';

class RetailScreen extends StatefulWidget {
  static const routeName = '/sell-point';
  const RetailScreen({Key? key}) : super(key: key);

  @override
  _RetailScreenState createState() => _RetailScreenState();
}

class _RetailScreenState extends State<RetailScreen> {
  @override
  Widget build(BuildContext context) {
    AccountingDB.getData(AccountModel.tableName);
    return Scaffold(
      appBar: AppBar(
        title: Text('Sell Point'),
      ),
      body: Center(
        child: Text('Welcome to sell point'),
      ),
    );
  }
}
