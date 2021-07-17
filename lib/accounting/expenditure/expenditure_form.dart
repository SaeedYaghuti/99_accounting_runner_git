import 'dart:async';

import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/run_code.dart';
// import 'package:shop/auth/run_code.dart';

import 'package:provider/provider.dart';
import 'package:shop/accounting/accounting_logic/account_dropdown_menu.dart';
import 'package:shop/accounting/common/expandble_panel.dart';
import 'package:shop/accounting/expenditure/payer_account_info.dart';
import 'package:shop/auth/auth_db_helper.dart';
import 'package:shop/auth/auth_model_sql.dart';
import 'package:shop/auth/auth_provider_sql.dart';

import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/environment/environment_provider.dart';
import 'package:shop/accounting/expenditure/expenditure_model.dart';
import 'package:shop/exceptions/not_handled_exception.dart';
import 'package:shop/shared/show_error_dialog.dart';
import 'expenditure_form_fields.dart';

class ExpenditureForm extends StatefulWidget {
  final VoucherModel? voucher;
  final int? expenseId;
  final FormDuty formDuty;
  final Function notifyNewVoucher;

  const ExpenditureForm({
    Key? key,
    this.voucher,
    this.expenseId,
    required this.formDuty,
    required this.notifyNewVoucher,
  }) : super(key: key);

  @override
  _ExpenditureFormState createState() => _ExpenditureFormState();
}

class _ExpenditureFormState extends State<ExpenditureForm> {
  late AuthProviderSQL authProviderSQL;
  var _fields = ExpenditurFormFields();

  @override
  void initState() {
    _fields.formDuty = widget.formDuty;
    _fields.date = DateTime.now();
    _fields.paidBy = ExpenditurFormFields.expenditureExample.paidBy;

    switch (_fields.formDuty) {
      case FormDuty.READ:
      case FormDuty.CREATE:
        print('EF | init_state | form rebuild for READ or CREATE ...');
        if (EnvironmentProvider.initializeExpenditureForm) {
          _fields = ExpenditurFormFields.expenditureExample;
        }
        break;
      case FormDuty.DELETE:
        print('EF | init_state | form rebuild for DELETE');
        if (widget.voucher == null) return;
        loadingStart();
        widget.voucher!.deleteMeFromDB().then((deleteResult) {
          loadingEnd();
          print('EF 66| deleteResult: $deleteResult');
          widget.notifyNewVoucher();
        }).catchError((e) {
          loadingEnd();
          showErrorDialog(
            context,
            'voucher .deleteMeFromDB()',
            'ExpenditureForm at initState while deleting a voucher happend error:',
            e,
          );
        });
        break;
      case FormDuty.EDIT:
        // print('EF | init_state | EDIT ');
        if (widget.voucher!.transactions.length > 2) {
          print(
            'EF 02| we can not show voucher with more than two transactions in this form ...',
          );
          _fields.formDuty = FormDuty.CREATE;
          // maybe show money_movement form
          // ...
        }
        // print('EXP_FRM init_state| EDIT | voucher to edite');
        // print(widget.voucher!);

        var debitTransaction = widget.voucher!.transactions.firstWhere(
          (tran) => tran!.isDebit,
        );

        var creditTransaction = widget.voucher!.transactions.firstWhere(
          (tran) => !tran!.isDebit,
        );
        AccountModel.fetchAccountById(debitTransaction!.accountId)
            .then((paidByAccount) {
          _fields = ExpenditurFormFields(
            id: creditTransaction!.id,
            amount: creditTransaction.amount,
            paidBy: paidByAccount,
            note: creditTransaction.note,
            date: creditTransaction.date,
            // tag: creditTransaction.tag,
          );
          print('EXP_FRM init_state| EDIT 03| prepared _expenditureFormFields');
          print(_fields);
          setState(() {});
        }).catchError((e) {
          print(
            'EXP_FRM initState 01| @ catchError while catching account ${debitTransaction.accountId} from db e: $e',
          );
          // exit from edit_mode
          _fields.formDuty = FormDuty.CREATE;
        });

        // _selectedDate = creditTransaction.date;
        break;
      default:
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    authProviderSQL = Provider.of<AuthProviderSQL>(context, listen: true);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    print('***');
    print('EXP_FRM build() | current satate ...');
    print('_expenditureFormFields: $_fields');
    print('***');
    return Container(
      width: 1200,
      padding: EdgeInsets.all(16),
      child: Form(
        key: _fields.formKey,
        child: Container(
          width: 1200,
          child: ListView(
            children: [
              _buildAmount(context),
              SizedBox(height: 20, width: 20),
              _buildNote(context),
              SizedBox(height: 20, width: 20),
              _buildPaidBy(context),
              SizedBox(height: 20, width: 20),
              _buildDatePickerButton(context),
              SizedBox(height: 20, width: 20),
              _buildSubmitButtons(context),
              SizedBox(height: 20, width: 20),
              TextButton(
                onPressed: () {
                  AccountingDB.deleteDB();
                  AuthDB.deleteDB();
                },
                child: Text('DELETE DB'),
              ),
              SizedBox(height: 20, width: 20),
              TextButton(
                onPressed: runCode,
                child: Text('RUN QUERY'),
              ),
            ],
          ),
        ),
      ),
    );
  } // build

  Widget _buildAmount(BuildContext context) {
    // print('EXP_FRM | _buildAmount | run ...');
    return TextFormField(
      decoration: _buildInputDecoration('Amount'),
      style: _buildTextStyle(),
      focusNode: _fields.amountFocusNode,
      controller: _fields.amountController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_fields.noteFocusNode);
      },
      validator: _fields.validateAmount,
      onSaved: (amount) {
        _fields.amount = double.parse(amount!);
      },
    );
  }

  Widget _buildNote(BuildContext context) {
    // fields = _expenditureFormFields;
    return TextFormField(
      decoration: _buildInputDecoration('Note'),
      style: _buildTextStyle(),
      maxLines: 2,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.next,
      controller: _fields.noteController,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_fields.paidByFocusNode);
      },
      validator: _fields.validateNote,
      onSaved: (note) {
        // print('titleField.onSaved: titleField: $titleField');
        _fields.note = note;
      },
    );
  }

  Widget _buildPaidBy(BuildContext context) {
    return OutlinedButton.icon(
      focusNode: _fields.paidByFocusNode,
      onPressed: _pickAccount,
      icon: Icon(
        Icons.account_balance_outlined,
        color: Theme.of(context).primaryColor,
      ),
      label: Text(
        _fields.paidBy?.titleEnglish ?? 'SELECT ACCOUNT',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildDatePickerButton(BuildContext context) {
    return OutlinedButton.icon(
      focusNode: _fields.dateFocusNode,
      onPressed: pickDate,
      icon: Icon(
        Icons.date_range_rounded,
        color: Theme.of(context).primaryColor,
      ),
      label: Text(
        _buildTextForDatePicker(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSubmitButtons(BuildContext context) {
    switch (_fields.formDuty) {
      case FormDuty.DELETE:
      case FormDuty.READ:
      case FormDuty.CREATE:
        print('_buildSubmitButtons 01| Button: Create');
        return _buildButton(
          context,
          'Create',
          Colors.green,
          () async {
            await _saveForm(
              () => ExpenditureModel.createExpenditureInDB(
                _fields,
              ),
            );
          },
        );
      // do: we should clear form data after create
      case FormDuty.EDIT:
        print('_buildSubmitButtons 02| Buttons: Save & Cancel');
        return Column(
          children: [
            _buildButton(
              context,
              'Save Changes',
              Colors.green,
              () async {
                _saveForm(
                  () => ExpenditureModel.updateVoucher(
                    widget.voucher!,
                    _fields,
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            _buildButton(
              context,
              'Cancel Editing',
              Colors.grey,
              () {
                setState(() {
                  _fields.formDuty = FormDuty.CREATE;
                  _fields = ExpenditurFormFields(
                    amount: 0,
                    note: '',
                    date: DateTime.now(),
                    paidBy: ExpenditurFormFields.expenditureExample.paidBy,
                  );
                });
              },
            ),
          ],
        );
      default:
        throw NotHandledException('EF 40| _buildSubmitButtons');
    }
  }

  Future<void> _saveForm(Function dbOperationHandler) async {
    if (_fields.formKey.currentState == null) {
      print('EF20| Warn: _form.currentState == null');
      return;
    }
    final isValid = _fields.formKey.currentState!.validate();
    if (!isValid) {
      print('EF21| Warn: some of form feilds are not valid;');
      return;
    }
    _fields.formKey.currentState!.save(); // run all onSaved method

    // add/edit expences in db
    // mod: new product creation
    if (true) {
      loadingStart();
      try {
        // save expences in database
        print(
          'EF23| @ _saveForm() | _expenditureFormFields: $_fields',
        );
        // await ExpenditureModel.createExpenditureInDB(_expenditureFormFields);
        await dbOperationHandler();
        // notify expenditur-screen to rebuild data-table
        widget.notifyNewVoucher();
        loadingEnd();
      } catch (e) {
        loadingEnd();
        showErrorDialog(
          context,
          'Error while _saveForm',
          'source: createExpenditureInDB <EF22>',
          e,
        );
      }
    }
    // mod: updating product
    // ...
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    Color color,
    Function function,
  ) {
    return OutlinedButton(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 26,
          // wordSpacing: 2.0,
          letterSpacing: 0.7,
          color: Colors.white,
        ),
      ),
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
            EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
        backgroundColor: MaterialStateProperty.all(color),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: color),
          ),
        ),
      ),
      onPressed: () => function(),
    );
  }

  void _pickAccount() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('SELECT ACCOUNT THAT PAID:'),
            children: [
              AccountDropdownMenu(
                authProvider: authProviderSQL,
                formDuty: _fields.formDuty,
                unwantedAccountIds: [
                  ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
                ],
                expandedAccountIds: [
                  ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
                ],
                tapHandler: (AccountModel tappedAccount) {
                  print(
                    'ExpForm paidBy tapHandler| tapped of ${tappedAccount.titleEnglish}',
                  );
                  Navigator.of(context).pop();
                  setState(() {
                    _fields.paidBy = tappedAccount;
                  });
                },
              ),
            ],
          );
        });
  }

  void pickDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((date) {
      setState(() {
        _fields.date = date;
      });
    });
  }

  void initializeForm(
    VoucherModel? voucherToShowInForm,
    int? expenseIdToShowInForm,
    FormDuty formDuty,
  ) {
    setState(() {
      if (voucherToShowInForm == null || expenseIdToShowInForm == null) {
        print('EF 01| we need form for create new voucher ...');
        _fields.formDuty = FormDuty.CREATE;
        if (EnvironmentProvider.initializeExpenditureForm) {
          // _expenditureFormFields = ExpenditurFormFields.expenditureExample;
          // _selectedDate = ExpenditurFormFields.expenditureExample.date;
          _fields.date = ExpenditurFormFields.expenditureExample.date;
        }
      } else if (voucherToShowInForm.transactions.length > 2) {
        print(
          'EF 02| we can not show voucher with more than two transactions in this form ...',
        );
        _fields.formDuty = FormDuty.CREATE;
        // maybe show money_movement form
        // ...
      } else {
        // we don't use form to read data
        print(
          'EF 03| we need form read an existing voucher ...',
        );
        _fields.formDuty = FormDuty.READ;
        var debitTransaction = voucherToShowInForm.transactions
            .firstWhere((tran) => tran!.isDebit);
        var creditTransaction = voucherToShowInForm.transactions
            .firstWhere((tran) => !tran!.isDebit);
        AccountModel.fetchAccountById(debitTransaction!.accountId).then((acc) {
          _fields = ExpenditurFormFields(
            id: creditTransaction!.id,
            amount: creditTransaction.amount,
            paidBy: acc,
            note: creditTransaction.note,
            date: creditTransaction.date,
            // tag: creditTransaction.tag,
          );
        }).catchError((e) {
          print(
            'EXP_FRM initializeForm 04| e in fetching account: ${debitTransaction.accountId} e: $e',
          );
        });
      }
    });
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      border: OutlineInputBorder(),
      labelText: labelText,
      labelStyle: TextStyle(
        color: Colors.black,
        fontSize: 26,
      ),
      hintStyle: TextStyle(
        color: Colors.black,
      ),
      // hintText: 'number',
      // helperText: 'paid amount',
      // counterText: '0.0',
      // prefixIcon: Icon(Icons.money_outlined),
      // icon: Icon(Icons.monetization_on_rounded),
      // suffixIcon: Icon(Icons.account_balance_outlined),
      // prefix: Text('Prefix:'),
    );
  }

  TextStyle _buildTextStyle() {
    return TextStyle(
      fontSize: 23,
      color: Colors.black,
    );
  }

  bool isToday(DateTime date) {
    var now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return true;
    }
    return false;
  }

  String _buildTextForDatePicker() {
    if (_fields.date == null) {
      return 'SELECT A DAY';
    }
    if (isToday(_fields.date!)) {
      return 'Today';
    }
    return '${_fields.date!.day}/${_fields.date!.month}/${_fields.date!.year}';
    // if (_selectedDate == null) {
    //   return 'SELECT A DAY';
    // }
    // if (isToday(_selectedDate!)) {
    //   return 'Today';
    // }
    // return '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
  }

  @override
  void dispose() {
    // _priceFocusNode.dispose();
    // _descriptionFocusNode.dispose();
    // _imageURLCotroller.dispose();
    // _imageURLFocusNode.removeListener(_updateImageUrl);
    // _imageURLFocusNode.dispose();
    super.dispose();
  }

  var _isLoading = false;

  void loadingStart() {
    setState(() {
      _isLoading = true;
    });
  }

  void loadingEnd() {
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildListViewMeduim(BuildContext context) {
    return AccountDropdownMenu(
      authProvider: authProviderSQL,
      formDuty: _fields.formDuty,
      expandedAccountIds: [
        // ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
        // ACCOUNTS_ID.BANKS_ACCOUNT_ID,
      ],
      tapHandler: (AccountModel tappedAccount) {
        print(
            'ExpForm paidBy tapHandler| tapped of ${tappedAccount.titleEnglish}');
      },
    );
    // return Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       Row(
    //         children: <Widget>[
    //           Expanded(
    //             child: RaisedButton(
    //               onPressed: () {
    //                 Navigator.push(
    //                   context,
    //                   MaterialPageRoute(
    //                     builder: (BuildContext context) => AccountDropdownMenu(
    //                       authProvider: authProviderSQL,
    //                       formDuty: _formDuty,
    //                       expandedAccountIds: [
    //                         ACCOUNTS_ID.ASSETS_ACCOUNT_ID,
    //                         ACCOUNTS_ID.BANKS_ACCOUNT_ID,
    //                       ],
    //                     ),
    //                   ),
    //                 );
    //               },
    //               child: Text('Account Dropdown Menu'),
    //             ),
    //           ),
    //         ],
    //       ),
    //       Row(
    //         children: <Widget>[
    //           Expanded(
    //             child: RaisedButton(
    //               onPressed: () {
    //                 Navigator.push(
    //                     context,
    //                     MaterialPageRoute(
    //                         builder: (BuildContext context) =>
    //                             Expansionpanel()));
    //               },
    //               child: Text('ExpansionPanel'),
    //             ),
    //           ),
    //         ],
    //       )
    //     ]);
  }
}

enum FormDuty {
  READ,
  CREATE,
  EDIT,
  DELETE,
}
