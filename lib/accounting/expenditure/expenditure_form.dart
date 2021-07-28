import 'dart:async';

import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/run_code.dart';
// import 'package:shop/auth/run_code.dart';

import 'package:provider/provider.dart';
import 'package:shop/accounting/accounting_logic/account_dropdown_menu.dart';
import 'package:shop/accounting/accounting_logic/transaction_classification.dart';
import 'package:shop/accounting/expenditure/expenditure_classification_tree.dart';
import 'package:shop/auth/auth_db_helper.dart';
import 'package:shop/auth/auth_provider_sql.dart';

import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/environment/environment_provider.dart';
import 'package:shop/accounting/expenditure/expenditure_model.dart';
import 'package:shop/auth/has_access.dart';
import 'package:shop/exceptions/not_handled_exception.dart';
import 'package:shop/shared/show_error_dialog.dart';
import 'expenditure_dropdown_menu.dart';
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
  var _formDuty = FormDuty.CREATE;
  var _didChangeRun = false;

  @override
  void initState() {
    _formDuty = widget.formDuty;
    _fields.date = DateTime.now();
    _fields.resetState = resetState;
    super.initState();
  }

  void resetState() {
    setState(() {
      print('called resetState()');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didChangeRun) return;

    authProviderSQL = Provider.of<AuthProviderSQL>(context, listen: true);
    _fields.authId = authProviderSQL.authId;
    _fields.paidBy = hasAccess(
            authProviderSQL: authProviderSQL,
            vitalPermissions: [ExpenditurFormFields.expenditureExample.paidBy?.createTransactionPermission])
        ? ExpenditurFormFields.expenditureExample.paidBy
        : null;
    _fields.expClass = ExpenditurFormFields.expenditureExample.expClass;
    switch (widget.formDuty) {
      case FormDuty.READ:
      case FormDuty.CREATE:
        initStateCreate();
        break;
      case FormDuty.DELETE:
        initStateDelete();
        break;
      case FormDuty.EDIT:
        initStateEdit();
        break;
      default:
    }
    _didChangeRun = true;
  }

  void initStateCreate() {
    // print('EF | init_state | form rebuild for READ or CREATE ...');
    if (EnvironmentProvider.initializeExpenditureForm) {
      _fields = ExpenditurFormFields.expenditureExample;
    }
  }

  void initStateDelete() {
    // print('EF | init_state | form rebuild for DELETE');
    if (widget.voucher == null) return;
    loadingStart();
    widget.voucher!.deleteMeFromDB(authProviderSQL).then((deleteResult) {
      loadingEnd();
      // print('EF 66| deleteResult: $deleteResult');
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
  }

  void initStateEdit() {
    // print('EF | init_state | EDIT ');
    // print(widget.voucher);
    if (widget.voucher!.transactions.length > 2) {
      print(
        'EF 02| we can not show voucher with more than two transactions in this form ...',
      );
      _formDuty = FormDuty.CREATE;
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
    AccountModel.fetchAccountById(debitTransaction!.accountId).then((paidByAccount) {
      _fields.id = creditTransaction!.id;
      _fields.amount = creditTransaction.amount;
      _fields.paidBy = paidByAccount;
      _fields.note = creditTransaction.note;
      _fields.date = creditTransaction.date;
      // _fields.expClass = creditTransaction.?expClass;

      // print('EXP_FRM init_state| EDIT 03| prepared _expenditureFormFields');
      // print(_fields);
      setState(() {});
    }).catchError((e) {
      print(
        'EXP_FRM initState 01| @ catchError while catching account ${debitTransaction.accountId} from db e: $e',
      );
      // exit from edit_mode
      _formDuty = FormDuty.CREATE;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
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
              _buildExpClass(context),
              SizedBox(height: 20, width: 20),
              _buildDatePickerButton(context),
              SizedBox(height: 20, width: 20),
              _buildSubmitButtons(context),
              SizedBox(height: 20, width: 20),
              _buildDeleteDB(context),
              SizedBox(height: 20, width: 20),
              _buildRunCode(context),
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
        _fields.amount = double.tryParse(amount ?? '');
      },
    );
  }

  Widget _buildNote(BuildContext context) {
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
      style: OutlinedButton.styleFrom(
        primary: _fields.hasErrorPaidBy ? Colors.white : Theme.of(context).primaryColor,
        backgroundColor: _fields.hasErrorPaidBy ? Colors.pinkAccent : Colors.white,
      ),
      onPressed: () {
        _pickAccount();
        FocusScope.of(context).requestFocus(_fields.dateFocusNode);
      },
      icon: Icon(
        Icons.account_balance_outlined,
        // color: Theme.of(context).primaryColor,
      ),
      label: Text(
        _fields.paidBy?.titleEnglish ?? 'SELECT ACCOUNT',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          // color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildExpClass(BuildContext context) {
    return OutlinedButton.icon(
      focusNode: _fields.expClassFocusNode,
      style: OutlinedButton.styleFrom(
        primary: _fields.hasErrorExpClass ? Colors.white : Theme.of(context).primaryColor,
        backgroundColor: _fields.hasErrorExpClass ? Colors.pinkAccent : Colors.white,
      ),
      onPressed: () {
        _pickExpClass();
        FocusScope.of(context).requestFocus(_fields.dateFocusNode);
      },
      icon: Icon(
        Icons.shopping_cart,
        // color: Theme.of(context).primaryColor,
      ),
      label: Text(
        _fields.expClass?.titleEnglish ?? 'SELECT EXPENCE CLASS',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          // color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildDatePickerButton(BuildContext context) {
    return OutlinedButton.icon(
      focusNode: _fields.dateFocusNode,
      style: OutlinedButton.styleFrom(
        primary: _fields.hasErrorDate ? Colors.white : Theme.of(context).primaryColor,
        backgroundColor: _fields.hasErrorDate ? Colors.pinkAccent : Colors.white,
      ),
      onPressed: () {
        pickDate();
        FocusScope.of(context).requestFocus(_fields.dateFocusNode);
      },
      icon: Icon(
        Icons.date_range_rounded,
        // color: Theme.of(context).primaryColor,
      ),
      label: Text(
        _buildTextForDatePicker(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          // color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSubmitButtons(BuildContext context) {
    switch (_formDuty) {
      case FormDuty.DELETE:
      case FormDuty.READ:
      case FormDuty.CREATE:
        // print('_buildSubmitButtons 01| Button: Create');
        return _buildButton(
          context,
          'Create',
          Colors.green,
          () async {
            await _saveForm(
              () => ExpenditureModel.createExpenditureInDB(
                authProviderSQL,
                _fields,
              ),
            );
          },
        );
      // do: we should clear form data after create
      case FormDuty.EDIT:
        // print('_buildSubmitButtons 02| Buttons: Save & Cancel');
        return Column(
          children: [
            _buildButton(
              context,
              'Save Changes',
              Colors.green,
              () {
                _saveForm(
                  () async {
                    try {
                      await ExpenditureModel.updateVoucher(
                        widget.voucher!,
                        _fields,
                        authProviderSQL,
                      );
                    } catch (e) {
                      showErrorDialog(
                        context,
                        'UpdateVoucher',
                        'while updating voucher an error accoured',
                        e,
                      );
                    }
                  },
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
                  _formDuty = FormDuty.CREATE;
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

  Widget _buildDeleteDB(BuildContext context) {
    return TextButton(
      onPressed: () {
        AccountingDB.deleteDB();
        AuthDB.deleteDB();
      },
      child: Text('DELETE DB'),
    );
  }

  Widget _buildRunCode(BuildContext context) {
    return TextButton(
      onPressed: runCode,
      child: Text('RUN QUERY'),
    );
  }

  Future<void> _saveForm(Function dbOperationHandler) async {
    final isValid = _fields.validate();
    if (!isValid.outcome) {
      print('EF21| Warn: ${isValid.errorMessage}');
      return;
    }
    _fields.formKey.currentState!.save(); // run all onSaved method
    loadingStart();
    try {
      await dbOperationHandler();
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
        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
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
                formDuty: _formDuty,
                unwantedAccountIds: [
                  ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID,
                ],
                expandedAccountIds: [
                  ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
                ],
                tapHandler: (AccountModel tappedAccount) {
                  // print(
                  //   'ExpForm paidBy tapHandler| tapped of ${tappedAccount.titleEnglish}',
                  // );
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

  void _pickExpClass() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('SELECT EXPENDITURE CLASS:'),
            children: [
              ExpClassDropdownMenu(
                expandedExpClassIds: [
                  ExpClassIds.MAIN_EXP_CLASS_ID,
                  ExpClassIds.SHOP_EXP_CLASS_ID,
                  ExpClassIds.STAFF_EXP_CLASS_ID,
                ],
                unwantedExpClassIds: [],
                tapHandler: (TransactionClassification tappedExpClass) {
                  Navigator.of(context).pop();
                  setState(() {
                    _fields.expClass = tappedExpClass;
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
        if (date == null) {
          _fields.date = DateTime.now();
        } else {
          _fields.date = date;
        }
      });
    });
  }

  void initializeForm(VoucherModel? voucherToShowInForm, int? expenseIdToShowInForm) {
    // Exp_Form called without passing voucher: means we are in create mode
    if (voucherToShowInForm == null || expenseIdToShowInForm == null) {
      print('EF 01| we need form for create new voucher ...');
      _formDuty = FormDuty.CREATE;
      if (EnvironmentProvider.initializeExpenditureForm) {
        // _expenditureFormFields = ExpenditurFormFields.expenditureExample;
        // _selectedDate = ExpenditurFormFields.expenditureExample.date;
        _fields.date = ExpenditurFormFields.expenditureExample.date;
      }
      setState(() {});
      return;
    }

    // Exp_Form called with voucher that contains 3 trans or more: we can not show in this simple form
    if (voucherToShowInForm.transactions.length > 2) {
      print(
        'EF 02| we can not show voucher with more than two transactions in this form ...',
      );
      _formDuty = FormDuty.CREATE;
      // show money_movement form
      // ...
      setState(() {});
      return;
    }

    // we want to edit voucher in form; we don't have read mode for voucher in form
    _formDuty = FormDuty.EDIT;
    var debitTransaction = voucherToShowInForm.transactions.firstWhere((tran) => tran!.isDebit);
    var creditTransaction = voucherToShowInForm.transactions.firstWhere((tran) => !tran!.isDebit);
    AccountModel.fetchAccountById(debitTransaction!.accountId).then(
      (acc) {
        _fields = ExpenditurFormFields(
          id: creditTransaction!.id,
          amount: creditTransaction.amount,
          paidBy: acc,
          note: creditTransaction.note,
          date: creditTransaction.date,
          // tag: creditTransaction.tag,
        );
        setState(() {});
      },
    ).catchError((e) {
      print(
        'EXP_FRM initializeForm 04| e in fetching account: ${debitTransaction.accountId} e: $e',
      );
      _formDuty = FormDuty.CREATE;
      setState(() {});
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
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
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

  var _isLoading = false;
}

enum FormDuty {
  READ, // currntly we don't have action for read
  CREATE,
  EDIT,
  DELETE,
}
