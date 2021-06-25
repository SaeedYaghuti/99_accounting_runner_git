import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/common/flexible_popup_menu_button.dart';
import 'package:shop/accounting/common/multi_language_text_widget.dart';
import 'package:shop/accounting/db/accounting_db.dart';
import 'package:shop/accounting/expenditure/expenditure_data_table.dart';
import 'package:shop/accounting/expenditure/expenditure_form.dart';
import 'package:shop/accounting/expenditure/expenditure_tag.dart';

class ExpenditureScreen extends StatefulWidget {
  static const String routeName = '/expenditure';
  const ExpenditureScreen({Key? key}) : super(key: key);

  @override
  _ExpenditureScreenState createState() => _ExpenditureScreenState();
}

class _ExpenditureScreenState extends State<ExpenditureScreen> {
  @override
  Widget build(BuildContext context) {
    AccountingDB.getData(AccountModel.tableName);
    return Scaffold(
      appBar: AppBar(
        title: _buildFlexibleTitle(),
        actions: [FlexiblePopupMenuButton()],
      ),
      // drawer: ,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: ExpenditureForm(),
          ),
          Expanded(
            flex: 8,
            child: ExpenditurDataTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildFlexibleTitle() {
    return MultiLanguageTextWidget(
      english: 'Expences',
      persian: 'هزینه ها',
      arabic: 'مصاريف',
    );
  }
}
