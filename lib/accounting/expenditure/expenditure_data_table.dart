import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/accounts.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
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
  var _isLoading = false;

  int? _selectedExpenseId;

  @override
  void initState() {
    _loadingStart();
    ExpenditureModel.expenditureVouchers().then(
      (voucherResults) {
        _loadingEnd();
        print('EDT01 | initState recived vouchers:');
        print(vouchers);
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
      columns: [
        DataColumn(
          label: Text('Amount'),
          numeric: true,
        ),
        DataColumn(label: Text('Note')),
        DataColumn(label: Text('Paid By')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Tran-Id')),
        DataColumn(label: Text('Voucher-Id')),
      ],
      rows: vouchersDataRow(),
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
    );
  }

  List<DataRow> vouchersDataRow() {
    List<DataRow> dataRows = [];
    vouchers.asMap().forEach((index, voucher) {
      voucher
          .accountTransactions(AccountsId.EXPENDITURE_ACCOUNT_ID)
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
