import 'package:flutter/material.dart';
import 'package:shop/accounting/account/account_model.dart';
import 'package:shop/accounting/db/accounting_db.dart';

class SellPoint extends StatefulWidget {
  static const routeName = '/sell-point';
  const SellPoint({Key? key}) : super(key: key);

  @override
  _SellPointState createState() => _SellPointState();
}

class _SellPointState extends State<SellPoint> {
  @override
  Widget build(BuildContext context) {
    AccountingDB.getData(AccountModel.tableName);
    return Container(
      child: Text('Welcome to sell point'),
    );
  }
}
