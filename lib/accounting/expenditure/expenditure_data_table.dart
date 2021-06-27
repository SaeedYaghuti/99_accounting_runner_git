import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/accounts.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/shared/readible_date.dart';
import 'package:shop/shared/show_error_dialog.dart';

class ExpenditurDataTable extends StatefulWidget {
  const ExpenditurDataTable({Key? key}) : super(key: key);

  @override
  _ExpenditurDataTableState createState() => _ExpenditurDataTableState();
}

class _ExpenditurDataTableState extends State<ExpenditurDataTable> {
  List<TransactionModel> expenses = [];
  var _isLoading = false;

  @override
  void initState() {
    _loadingStart();
    TransactionModel.allExpencesVoucher().then(
      (result) {
        _loadingEnd();
        print('EDT01 | allTranJoinVchForAccount result');
        print(result);
        print(result[0][VoucherModel.tableName] as VoucherModel);
        print(result[0][TransactionModel.transactionTableName]
            as TransactionModel);
        // expenses = result;
        // print('EDT10| allExpences() result >');
        // print(expenses);
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

  void initState1() {
    _loadingStart();
    TransactionModel.allExpences().then(
      (result) {
        _loadingEnd();
        expenses = result;
        // print('EDT10| allExpences() result >');
        // print(expenses);
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
      ],
      rows: expenses
          .map((exp) => DataRow(
                cells: [
                  DataCell(Text(exp.amount.toString())),
                  DataCell(Text(exp.note)),
                  DataCell(Text('paid by _')),
                  DataCell(Text(readibleDate(exp.date))),
                ],
              ))
          .toList(),
    );
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
