import 'package:flutter/material.dart';
import 'package:shop/accounting/account/transaction_model.dart';
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
    TransactionModel.allExpences().then(
      (result) {
        _loadingEnd();
        expenses = result;
        print('EDT10| allExpences() result >');
        print(expenses);
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
      rows: [
        DataRow(
          cells: [
            DataCell(Text('3.75')),
            DataCell(Text('Nescfee')),
            DataCell(Text('nbo')),
            DataCell(Text('today')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('1.2')),
            DataCell(Text('Mask')),
            DataCell(Text('cash-draw')),
            DataCell(Text('24/05/2021')),
          ],
        ),
      ],
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
