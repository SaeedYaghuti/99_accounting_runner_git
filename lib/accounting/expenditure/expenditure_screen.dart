import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/common/flexible_popup_menu_button.dart';
import 'package:shop/accounting/common/multi_language_text_widget.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/expenditure/expenditure_form.dart';
import 'package:shop/shared/confirm_dialog.dart';
import 'package:shop/shared/not_handled_exception.dart';
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
  VoucherModel? _voucherToShowInForm;
  int? _expenseIdToShowInForm;
  FormDuty? _formDuty;

  var _vouchersAreLoading = false;

  @override
  void initState() {
    _vouchersLoadingStart();
    ExpenditureModel.expenditureVouchers().then(
      (voucherResults) {
        _vouchersLoadingEnd();
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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FORM
          Expanded(
            flex: 2,
            child: ExpenditureForm(
              key: ValueKey(redrawObject),
              voucher: _voucherToShowInForm,
              expenseId: _expenseIdToShowInForm,
              formDuty: _formDuty ?? FormDuty.CREATE,
              notifyNewVoucher: notifyNewVoucher,
            ),
          ),
          // DATA TABLE
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
                      ? Center(child: CircularProgressIndicator())
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

  List<DataColumn> _buildTableColumns() {
    return [
      DataColumn(
        label: Icon(Icons.settings),
      ),
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

  void notifyNewVoucher() {
    reloadVouchers();
  }

  void voucherSelectionHandler(
    VoucherModel? voucherToShowInForm,
    int? expenseIdToShowInForm,
    FormDuty? duty,
  ) {
    setState(() {
      _voucherToShowInForm = voucherToShowInForm;
      _expenseIdToShowInForm = expenseIdToShowInForm;
      _formDuty = duty;
      redrawObject = new Object();
    });
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
            DataCell(_buildEditDeleteMenu(voucher, exp.id)),
            DataCell(Text(exp.amount.toString())),
            DataCell(Text(exp.note)),
            DataCell(Text(voucher.paidByText())),
            DataCell(Text(readibleDate(voucher.date))),
            DataCell(Text(exp.id.toString())),
            DataCell(Text(voucher.id.toString())),
          ],
          selected: _expenseIdToShowInForm == exp.id,
          onSelectChanged: (isSelected) {
            if (isSelected == null) {
              return;
            }
            setState(() {
              if (isSelected) {
                _expenseIdToShowInForm = exp.id ?? 0;
                voucherSelectionHandler(voucher, exp.id, FormDuty.CREATE);
              } else {
                voucherSelectionHandler(null, null, null);
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

  Widget _buildEditDeleteMenu(VoucherModel? voucher, int? expId) {
    return GestureDetector(
      child: Icon(Icons.more_vert),
      onTapDown: (TapDownDetails details) {
        voucherSelectionHandler(
          voucher,
          expId,
          FormDuty.READ,
        );
        double left = details.globalPosition.dx;
        double top = details.globalPosition.dy;
        _showEditDeletePopupMenu(details.globalPosition, voucher, expId);
      },
    );
  }

  _showEditDeletePopupMenu(
    Offset offset,
    VoucherModel? voucher,
    int? expId,
  ) async {
    double left = offset.dx;
    double top = offset.dy;
    String? selectedItem = await showMenu<String>(
      elevation: 8.0,
      context: context,
      position: RelativeRect.fromLTRB(left, top, left, top),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.edit,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Text(
                'Edit',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          value: 'edit',
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.delete,
                color: Colors.pinkAccent,
              ),
              SizedBox(width: 10),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.pinkAccent,
                ),
              ),
            ],
          ),
          value: 'delete',
        ),
      ],
    );
    if (selectedItem == null) {
      print('ES 80| you select nothing ...');
      voucherSelectionHandler(null, null, null);
      return;
    }

    if (selectedItem == "edit") {
      print('ES 80| you edit ...');
      voucherSelectionHandler(
        voucher,
        expId,
        FormDuty.EDIT,
      );
    } else if (selectedItem == "delete") {
      print('ES 80| you delete ...');
      var confirmResult = await confirmDialog(
        context: context,
        title: 'Are sure to delete this expense?',
        content:
            'This would delete voucher and all it is transactions from database',
        noTitle: 'No',
        yesTitle: 'Delete it!',
      );
      print('ES 70| confirmResult: $confirmResult');
      if (confirmResult == true) {
        voucherSelectionHandler(
          voucher,
          expId,
          FormDuty.DELETE,
        );
      }
    } else {
      throw NotHandledException('ES 80| ');
    }
  }

  void reloadVouchers() async {
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
