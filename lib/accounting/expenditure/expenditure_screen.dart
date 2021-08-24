import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/classification/classification_form.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/common/flexible_popup_menu_button.dart';
import 'package:shop/accounting/common/multi_language_text_widget.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/auth/has_access.dart';
import 'package:shop/auth/secure_widget.dart';
import 'package:shop/accounting/expenditure/expenditure_screen_form.dart';
import 'package:shop/auth/permission_model.dart';
import 'package:shop/shared/confirm_dialog.dart';
import 'package:shop/exceptions/not_handled_exception.dart';
import 'package:shop/shared/custom_form_fields/form_fields_screen.dart';
import 'package:shop/shared/custom_form_fields/multi_selection_form_field.dart';
import 'package:shop/shared/readible_date.dart';
import 'package:shop/shared/result_status.dart';
import 'package:shop/shared/show_error_dialog.dart';

// import 'package:shop/auth/firebase/auth_provider.dart';
import 'package:shop/auth/auth_provider_sql.dart';

import 'expenditure_model.dart';

class ExpenditureScreen extends StatefulWidget {
  static const String routeName = '/expenditure';
  const ExpenditureScreen({Key? key}) : super(key: key);

  @override
  _ExpenditureScreenState createState() => _ExpenditureScreenState();
}

class _ExpenditureScreenState extends State<ExpenditureScreen> {
  late AuthProviderSQL authProvider;
  Object redrawFormObject = Object();
  List<VoucherModel> vouchers = [];
  VoucherModel? _voucherToShowInForm;
  int? _expenseIdToShowInForm;
  FormDuty? _formDuty;
  late AccountModel expenditurAccount;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    authProvider = Provider.of<AuthProviderSQL>(context, listen: true);
    _vouchersLoadingStart();

    ExpenditureModel.expenditureVouchers(authProvider).then(
      (voucherResults) {
        _vouchersLoadingEnd();
        if (voucherResults == null || voucherResults.isEmpty) {
          return;
        }
        vouchers = voucherResults.cast<VoucherModel>();
      },
    ).catchError((e) {
      _vouchersLoadingEnd();
      showErrorDialog(
        context,
        'ExpenditurScreen',
        '01 | @didChangeDependencies() | #while fetching expenditureVouchers() ',
        e,
      );
      print(e.toString());
    });

    _vouchersLoadingStart();
    AccountModel.fetchAccountById(ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID).then((account) {
      _vouchersLoadingEnd();
      // print(
      //   'EXP_SCN | didChangeDependencies() 02| fetching expenditurAccount | account: $account',
      // );
      expenditurAccount = account!;
    }).catchError((e) {
      _vouchersLoadingEnd();
      showErrorDialog(
        context,
        'ExpenditurScreen',
        '03 | @didChangeDependencies() | #while fetching expenditurAccount',
        e,
      );
      print(e.toString());
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    AccountingDB.getData(AccountModel.tableName);
    return Scaffold(
      appBar: AppBar(
        title: _buildFlexibleTitle(),
        actions: [
          FlexiblePopupMenuButton(),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSecureForm(context),
          _buildDataTable(),
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

  Widget _buildSecureForm(BuildContext context) {
    return SecureWidget(
      authProviderSQL: authProvider,
      anyPermissions: [
        PermissionModel.EXPENDITURE_CREATE_TRANSACTION,
        PermissionModel.EXPENDITURE_EDIT_ALL_TRANSACTION,
        PermissionModel.EXPENDITURE_EDIT_OWN_TRANSACTION,
      ],
      child: Expanded(
        flex: 2,
        child: ExpenditureForm(
          key: ValueKey(redrawFormObject),
          voucher: _voucherToShowInForm,
          expenseId: _expenseIdToShowInForm,
          formDuty: _formDuty ?? FormDuty.CREATE,
          notifyNewVoucher: notifyNewVoucher,
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Expanded(
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
            _vouchersAreLoading ? Center(child: CircularProgressIndicator()) : Container(),
            SizedBox(
              height: 10,
            ),
            // _buildClassificationForm(context),
          ],
        ),
      ),
    );
  } // build

  // Widget _buildMultiSelection(BuildContext context) {
  //   return MyMultiSelectionFormField<Interest>(
  //     decoration: InputDecoration(
  //       labelText: 'Interests',
  //     ),
  //     hint: Text('Select more interests'),
  //     isDense: true,
  //     focusNode: interestsFocusNode,
  //     options: Interest.values,
  //     titleBuilder: (interest) => Text(describeEnum(interest)),
  //     chipLabelBuilder: (interest) => Text(describeEnum(interest)),
  //     initialValues: _formResult.interests!,
  //     validator: (interests) => interests == null || interests.length < 3 ? 'Please select at least 3 interests' : null,
  //     onSaved: (interests) {
  //       _formResult.interests = interests!;
  //     },
  //     onChanged: (_) {
  //       FocusScope.of(context).unfocus();
  //       FocusScope.of(context).requestFocus(interestsFocusNode);
  //     },
  //   );
  // }

  List<DataColumn> _buildTableColumns() {
    return [
      DataColumn(label: Icon(Icons.settings)),
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
        english: 'Tag',
        persian: 'فهرست',
        arabic: 'صنف',
      )),
      DataColumn(
          label: MultiLanguageTextWidget(
        english: 'Float',
        persian: 'شناور',
        arabic: 'سيال',
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

  List<DataRow> _buildTableRows() {
    List<DataRow> dataRows = [];
    vouchers.asMap().forEach(
      (index, voucher) {
        voucher
            // do we have permission for this voucher
            .onlyTransactionsOf(ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID)
            .forEach(
          (expTran) {
            if (expTran == null) {
              return;
            }
            dataRows.add(DataRow(
              cells: [
                _buildEditDeletePopupMenueCell(voucher, expTran.id!),
                DataCell(Text(expTran.amount.toString())),
                DataCell(Text(expTran.note)),
                DataCell(Text(voucher.paidByText())),
                DataCell(Text(expTran.tranClass.titleEnglish)),
                DataCell(Text(expTran.floatAccount.titleEnglish)),
                DataCell(Text(readibleDate(voucher.date))),
                DataCell(Text(expTran.id.toString())),
                DataCell(Text(voucher.id.toString())),
              ],
              selected: _expenseIdToShowInForm == expTran.id,
              onSelectChanged: (isSelected) {
                if (isSelected == null) {
                  return;
                }
                setState(() {
                  if (isSelected) {
                    _expenseIdToShowInForm = expTran.id ?? 0;
                    rebuildExpForm(voucher, expTran.id, FormDuty.CREATE);
                  } else {
                    rebuildExpForm(null, null, null);
                  }
                });
              },
              color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
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
          },
        );
      },
    );
    return dataRows;
  }

  void rebuildExpForm(
    VoucherModel? voucherToShowInForm,
    int? expenseIdToShowInForm,
    FormDuty? duty,
  ) {
    setState(() {
      _voucherToShowInForm = voucherToShowInForm;
      _expenseIdToShowInForm = expenseIdToShowInForm;
      _formDuty = duty;
      redrawFormObject = new Object();
      // form will rebuild
    });
  }

  DataCell _buildEditDeletePopupMenueCell(
    VoucherModel voucher,
    int expTranId,
  ) {
    // check we have access to delete or edit this row of voucher
    Result hasAccessToEdit = hasCredAccessToVoucher(
      authProviderSQL: authProvider,
      voucher: voucher,
      formDuty: FormDuty.EDIT,
    );
    Result hasAccessToDelete = hasCredAccessToVoucher(
      authProviderSQL: authProvider,
      voucher: voucher,
      formDuty: FormDuty.DELETE,
    );

    // we don't have any perm: return block icon
    if (!hasAccessToEdit.outcome && !hasAccessToDelete.outcome) {
      // print(
      //   'EXP_SCR | 33 _buildEditDeletePopupMenueCell() | not have access to \nedit: ${hasAccessToEdit.errorMessage} \n:delete: ${hasAccessToDelete.errorMessage}',
      // );
      return DataCell(Icon(Icons.block_rounded));
    }

    // we have at list one perm:
    return DataCell(
      GestureDetector(
        child: Icon(Icons.more_vert),
        onTapDown: (TapDownDetails details) async {
          rebuildExpForm(
            voucher,
            expTranId,
            FormDuty.CREATE,
          );
          await _showEditDeletePopupMenu(
            offset: details.globalPosition,
            voucher: voucher,
            expTranId: expTranId,
            showEdit: hasAccessToEdit.outcome,
            showDelete: hasAccessToDelete.outcome,
          );
        },
      ),
    );
  }

  _showEditDeletePopupMenu({
    required Offset offset,
    required VoucherModel voucher,
    required int expTranId,
    required bool showEdit,
    required bool showDelete,
  }) async {
    double left = offset.dx;
    double top = offset.dy;
    String? selectedItem = await showMenu<String>(
      elevation: 8.0,
      context: context,
      position: RelativeRect.fromLTRB(left, top, left, top),
      items: [
        if (showEdit)
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
        if (showDelete)
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
      // print('ES 80| you select nothing ...');
      rebuildExpForm(null, null, null);
      return;
    }

    if (selectedItem == "edit") {
      // print('ES 80| you edit ...');
      rebuildExpForm(
        voucher,
        expTranId,
        FormDuty.EDIT,
      );
    } else if (selectedItem == "delete") {
      // print('ES 80| you delete ...');
      var confirmResult = await confirmDialog(
        context: context,
        title: 'Are sure to delete this expense?',
        content: 'This would delete voucher and all it is transactions from database',
        noTitle: 'No',
        yesTitle: 'Delete it!',
      );
      // print('ES 70| confirmResult: $confirmResult');
      if (confirmResult == true) {
        rebuildExpForm(
          voucher,
          expTranId,
          FormDuty.DELETE,
        );
      }
    } else {
      throw NotHandledException('ES 80| ');
    }
  }

  Widget _buildEditDeleteMenu0(VoucherModel? voucher, int? expId) {
    return SecureWidget(
      authProviderSQL: authProvider,
      anyPermissions: [
        PermissionModel.EXPENDITURE_DELETE_ALL_TRANSACTION,
        PermissionModel.EXPENDITURE_DELETE_OWN_TRANSACTION,
        PermissionModel.EXPENDITURE_EDIT_ALL_TRANSACTION,
        PermissionModel.EXPENDITURE_EDIT_OWN_TRANSACTION,
      ],
      child: GestureDetector(
        child: Icon(Icons.more_vert),
        onTapDown: (TapDownDetails details) async {
          rebuildExpForm(
            voucher,
            expId,
            FormDuty.CREATE,
          );
          await _showEditDeletePopupMenu0(
            details.globalPosition,
            voucher,
            expId,
          );
        },
      ),
    );
  }

  _showEditDeletePopupMenu0(
    Offset offset,
    VoucherModel? voucher,
    int? expId,
  ) async {
    double left = offset.dx;
    double top = offset.dy;
    Result hasAccessToEdit = hasCredAccessToVoucher(
      authProviderSQL: authProvider,
      voucher: voucher!,
      formDuty: FormDuty.EDIT,
    );
    Result hasAccessToDelete = hasCredAccessToVoucher(
      authProviderSQL: authProvider,
      voucher: voucher,
      formDuty: FormDuty.DELETE,
    );
    String? selectedItem = await showMenu<String>(
      elevation: 8.0,
      context: context,
      position: RelativeRect.fromLTRB(left, top, left, top),
      items: [
        if (hasAccessToEdit.outcome)
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
        if (hasAccessToDelete.outcome)
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
      // print('ES 80| you select nothing ...');
      rebuildExpForm(null, null, null);
      return;
    }

    if (selectedItem == "edit") {
      // print('ES 80| you edit ...');
      rebuildExpForm(
        voucher,
        expId,
        FormDuty.EDIT,
      );
    } else if (selectedItem == "delete") {
      // print('ES 80| you delete ...');
      var confirmResult = await confirmDialog(
        context: context,
        title: 'Are sure to delete this expense?',
        content: 'This would delete voucher and all it is transactions from database',
        noTitle: 'No',
        yesTitle: 'Delete it!',
      );
      // print('ES 70| confirmResult: $confirmResult');
      if (confirmResult == true) {
        rebuildExpForm(
          voucher,
          expId,
          FormDuty.DELETE,
        );
      }
    } else {
      throw NotHandledException('ES 80| ');
    }
  }

  void notifyNewVoucher() async {
    await reloadVouchers();
    rebuildExpForm(null, null, FormDuty.CREATE);
  }

  Future<void> reloadVouchers() async {
    try {
      _vouchersLoadingStart();
      var fetchedVouchers = await ExpenditureModel.expenditureVouchers(authProvider);

      if (fetchedVouchers.isNotEmpty) {
        setState(() {
          vouchers = fetchedVouchers.cast<VoucherModel>();
        });
      } else {
        setState(() {
          vouchers = [];
        });
      }
      _vouchersLoadingEnd();
    } catch (e) {
      _vouchersLoadingEnd();
      showErrorDialog(
        context,
        'ExpenditurScreen',
        '@reloadVouchers()',
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

  var _vouchersAreLoading = false;

  List<DataRow> _buildTableRows1() {
    List<DataRow> dataRows = [];
    var index = 0;
    for (var voucher in vouchers) {
      index++;
      // how has access to row
      // ReadAll or (ReadOwn && creatorId == authId)
      if (!authProvider.isPermitted(PermissionModel.EXPENDITURE_READ_ALL_TRANSACTION) &&
          authProvider.isPermitted(PermissionModel.EXPENDITURE_READ_OWN_TRANSACTION) &&
          voucher.creatorId != authProvider.authId) {
        // no access to row
        continue;
      }

      voucher.onlyTransactionsOf(ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID).forEach((expTran) {
        if (expTran == null) {
          return;
        }
        dataRows.add(DataRow(
          cells: [
            if (hasAccess(authProviderSQL: authProvider, anyPermissions: [
                  PermissionModel.EXPENDITURE_DELETE_ALL_TRANSACTION,
                  PermissionModel.EXPENDITURE_EDIT_ALL_TRANSACTION,
                ]) ||
                (hasAccess(authProviderSQL: authProvider, anyPermissions: [
                      PermissionModel.EXPENDITURE_DELETE_OWN_TRANSACTION,
                      PermissionModel.EXPENDITURE_EDIT_OWN_TRANSACTION,
                    ]) &&
                    voucher.creatorId == authProvider.authId))
              DataCell(_buildEditDeleteMenu0(voucher, expTran.id))
            else
              DataCell(Icon(Icons.block_rounded)),
            DataCell(Text(expTran.amount.toString())),
            DataCell(Text(expTran.note)),
            DataCell(Text(voucher.paidByText())),
            DataCell(Text(readibleDate(voucher.date))),
            DataCell(Text(expTran.id.toString())),
            DataCell(Text(voucher.id.toString())),
          ],
          selected: _expenseIdToShowInForm == expTran.id,
          onSelectChanged: (isSelected) {
            if (isSelected == null) {
              return;
            }
            setState(() {
              if (isSelected) {
                _expenseIdToShowInForm = expTran.id ?? 0;
                rebuildExpForm(voucher, expTran.id, FormDuty.CREATE);
              } else {
                rebuildExpForm(null, null, null);
              }
            });
          },
          color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
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
    }

    return dataRows;
  }
}
