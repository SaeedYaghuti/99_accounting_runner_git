import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/common/flexible_popup_menu_button.dart';
import 'package:shop/accounting/common/multi_language_text_widget.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/expenditure/expenditure_data_table.dart';
import 'package:shop/accounting/expenditure/expenditure_form.dart';
import 'package:shop/accounting/expenditure/expenditure_tag.dart';
import 'package:shop/shared/readible_date.dart';
import 'package:shop/shared/show_error_dialog.dart';

import 'expenditure_model.dart';

class ExpenditureScreen extends StatefulWidget {
  static const String routeName = '/expenditure';
  const ExpenditureScreen({Key? key}) : super(key: key);

  @override
  _ExpenditureScreenState createState() => _ExpenditureScreenState();
}

class _ExpenditureScreenState extends State<ExpenditureScreen> {
  Object redrawObject = Object();
  List<VoucherModel> vouchers = [];
  int? _selectedExpenseId;

  var _vouchersAreLoading = false;

  @override
  void initState() {
    _vouchersLoadingStart();
    ExpenditureModel.expenditureVouchers().then(
      (voucherResults) {
        _vouchersLoadingEnd();
        // print('EDT01 | initState recived vouchers:');
        // print(vouchers);
        vouchers = voucherResults;
      },
    ).catchError((e) {
      _vouchersLoadingEnd();
      showErrorDialog(
        context,
        'ExpenditurDataTable',
        '@initState() #allExpences()',
        e,
      );
      print(e.toString());
    });
    super.initState();
  }

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
            child: ExpenditureForm(expenseCreationHandler),
          ),
          Expanded(
            flex: 8,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DataTable(
                    showCheckboxColumn: false,
                    dataTextStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    headingTextStyle: TextStyle(
                      fontSize: 24,
                      color: Colors.purple,
                    ),
                    sortAscending: true,
                    dividerThickness: 2,
                    columns: _buildTableColumns(),
                    rows: _buildTableRows(),
                  ),
                  SizedBox(height: 10),
                  _vouchersAreLoading
                      ? CircularProgressIndicator()
                      : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } // build

  Widget _buildFlexibleTitle() {
    return MultiLanguageTextWidget(
      english: 'Expences',
      persian: 'هزینه ها',
      arabic: 'مصاريف',
    );
  }

  List<DataRow> _buildTableRows() {
    List<DataRow> dataRows = [];
    vouchers.asMap().forEach((index, voucher) {
      voucher
          .accountTransactions(ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID)
          .forEach((exp) {
        if (exp == null) {
          return;
        }
        dataRows.add(DataRow(
          cells: [
            DataCell(Text(exp.amount.toString())),
            DataCell(Text(exp.note)),
            DataCell(Text(voucher.paidBy())),
            DataCell(Text(readibleDate(voucher.date))),
            DataCell(Text(exp.id.toString())),
            DataCell(Text(voucher.id.toString())),
          ],
          selected: _selectedExpenseId == exp.id,
          onSelectChanged: (isSelected) {
            if (isSelected == null) {
              return;
            }
            setState(() {
              if (isSelected) {
                _selectedExpenseId = exp.id ?? 0;
                // notify form to show expense data
                // ...
              } else {
                _selectedExpenseId = 0;
              }
            });
          },
          color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            // All rows will have the same selected color.
            if (states.contains(MaterialState.selected)) {
              // return Theme.of(context).colorScheme.primary.withOpacity(0.08);
              return Theme.of(context).accentColor.withOpacity(0.5);
            }
            // Even rows will have a grey color.
            if (index.isEven) {
              // return Colors.grey.withOpacity(0.3);
              return Theme.of(context).primaryColor.withOpacity(0.1);
            }
            return null; // Use default value for other states and odd rows.
          }),
        ));
      });
    });
    return dataRows;
  }

  List<DataColumn> _buildTableColumns() {
    return [
      DataColumn(
        label: MultiLanguageTextWidget(
          english: 'Amount',
          persian: 'مبلغ',
          arabic: 'مبلغ',
        ),
        numeric: true,
      ),
      DataColumn(
          label: MultiLanguageTextWidget(
        english: 'Note',
        persian: 'توضیحات',
        arabic: 'شرح',
      )),
      DataColumn(
          label: MultiLanguageTextWidget(
        english: 'Paid By',
        persian: 'پرداخت کننده',
        arabic: 'دافع',
      )),
      DataColumn(
          label: MultiLanguageTextWidget(
        english: 'Date',
        persian: 'تاریخ',
        arabic: 'تاریخ',
      )),
      DataColumn(
          label: FittedBox(
        child: MultiLanguageTextWidget(
          english: 'Tran',
          persian: 'تراکنش',
          arabic: 'ایصال',
        ),
      )),
      DataColumn(
          label: FittedBox(
        child: MultiLanguageTextWidget(
          english: 'Voucher',
          persian: 'سند',
          arabic: 'سند',
        ),
      )),
    ];
  }

  void expenseCreationHandler() {
    reloadExpenseVouchers();
  }

  void reloadExpenseVouchers() async {
    try {
      _vouchersLoadingStart();
      var fetchedVouchers = await ExpenditureModel.expenditureVouchers();
      setState(() {
        vouchers = fetchedVouchers;
      });
      _vouchersLoadingEnd();
    } catch (e) {
      _vouchersLoadingEnd();
      showErrorDialog(
        context,
        'ExpenditurDataTable',
        '@initState() #allExpences()',
        e,
      );
      print(e.toString());
    }
  }

  void _vouchersLoadingStart() {
    setState(() {
      _vouchersAreLoading = true;
    });
  }

  void _vouchersLoadingEnd() {
    setState(() {
      _vouchersAreLoading = false;
    });
  }
}
