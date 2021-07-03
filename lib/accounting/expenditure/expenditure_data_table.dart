import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/accounts_tree.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/common/multi_language_text_widget.dart';
import 'package:shop/accounting/expenditure/expenditure_model.dart';
import 'package:shop/shared/readible_date.dart';
import 'package:shop/shared/show_error_dialog.dart';

class ExpenditurDataTable extends StatefulWidget {
  const ExpenditurDataTable({Key? key}) : super(key: key);

  @override
  _ExpenditurDataTableState createState() => _ExpenditurDataTableState();
}

class _ExpenditurDataTableState extends State<ExpenditurDataTable> {
  List<VoucherModel> vouchers = [];
  int? _selectedExpenseId;

  var _isLoading = false;

  @override
  void initState() {
    _loadingStart();
    ExpenditureModel.expenditureVouchers().then(
      (voucherResults) {
        _loadingEnd();
        // print('EDT01 | initState recived vouchers:');
        // print(vouchers);
        vouchers = voucherResults;
      },
    ).catchError((e) {
      _loadingEnd();
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
    return DataTable(
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
            DataCell(Text(voucher.paidByText())),
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
          label: MultiLanguageTextWidget(
        english: 'Tran ID',
        persian: 'شناسه تراکنش',
        arabic: 'رقم ایصال',
      )),
      DataColumn(
          label: MultiLanguageTextWidget(
        english: 'Voucher ID',
        persian: 'شناسه سند',
        arabic: 'رقم سند',
      )),
    ];
  }

  void _loadingStart() {
    setState(() {
      _isLoading = true;
    });
  }

  void _loadingEnd() {
    setState(() {
      _isLoading = false;
    });
  }
}
