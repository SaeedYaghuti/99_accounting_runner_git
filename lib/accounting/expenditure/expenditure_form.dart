import 'dart:async';

// import 'package:shop/accounting/accounting_logic/run_code.dart';
import 'package:provider/provider.dart';
import 'package:shop/auth/auth_db_helper.dart';
import 'package:shop/auth/auth_model_sql.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/auth/run_code.dart';

import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/environment/environment_provider.dart';
import 'package:shop/accounting/expenditure/expenditure_model.dart';
import 'package:shop/shared/not_handled_exception.dart';
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
  FormDuty _formDuty = FormDuty.CREATE;
  final _form = GlobalKey<FormState>();
  final _amountFocusNode = FocusNode();
  final _noteFocusNode = FocusNode();
  final _paidByFocusNode = FocusNode();
  final _dateFocusNode = FocusNode();
  var _expenditureFormFields = ExpenditurFormFields(
    paidBy: ACCOUNTS_ID.CASH_DRAWER_ACCOUNT_ID,
  );
  var _isLoading = false;

  @override
  void initState() {
    // _selectedDate = DateTime.now();
    _expenditureFormFields.date = DateTime.now();
    _formDuty = widget.formDuty;

    switch (_formDuty) {
      case FormDuty.READ:
      case FormDuty.CREATE:
        print('EF | init_state | form rebuild for READ or CREATE ...');
        if (EnvironmentProvider.initializeExpenditureForm) {
          _expenditureFormFields = ExpenditurFormFields.expenditureExample;
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
        print('EF | init_state | form rebuild for EDITE');
        if (widget.voucher!.transactions.length > 2) {
          print(
            'EF 02| we can not show voucher with more than two transactions in this form ...',
          );
          _formDuty = FormDuty.CREATE;
          // maybe show money_movement form
          // ...
        }
        var debitTransaction =
            widget.voucher!.transactions.firstWhere((tran) => tran!.isDebit);
        var creditTransaction =
            widget.voucher!.transactions.firstWhere((tran) => !tran!.isDebit);
        _expenditureFormFields = ExpenditurFormFields(
          id: creditTransaction!.id,
          amount: creditTransaction.amount,
          // do: accountId should be sync with list of PaidByAccounts
          paidBy: debitTransaction!.accountId,
          note: creditTransaction.note,
          date: creditTransaction.date,
          // tag: creditTransaction.tag,
        );
        // _selectedDate = creditTransaction.date;
        break;
      default:
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1200,
      padding: EdgeInsets.all(16),
      child: Form(
        key: _form,
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
              // _buildSaveButton(context),
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
    return TextFormField(
      decoration: _buildInputDecoration('Amount'),
      style: _buildTextStyle(),
      focusNode: _amountFocusNode,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      initialValue: (_expenditureFormFields.amount != null)
          ? _expenditureFormFields.amount.toString()
          : '',
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_noteFocusNode);
      },
      validator: (amount) {
        if (amount == null || amount.isEmpty) {
          return 'amount should not be empty';
        }
        var num = double.tryParse(amount);
        if (num == null) {
          return 'amount should be valid number';
        }
        if (num <= 0) {
          return 'amount should be greater than Zero';
        }
        return null;
      },
      onSaved: (amount) {
        // print('title-field.onSaved: amount: $amount');
        _expenditureFormFields.amount = double.parse(amount!);
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
      initialValue: _expenditureFormFields.note ?? '',
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_paidByFocusNode);
      },
      validator: (note) {
        if (note == null || note.isEmpty) {
          return 'Note should not be empty';
        }
        return null;
      },
      onSaved: (note) {
        // print('titleField.onSaved: titleField: $titleField');
        _expenditureFormFields.note = note;
      },
    );
  }

  Widget _buildPaidBy(BuildContext context) {
    return FormField<String>(
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: _buildInputDecoration('Paid By'),
          isEmpty: _expenditureFormFields.paidBy == '',
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              focusNode: _paidByFocusNode,
              value: _expenditureFormFields.paidBy,
              isDense: true,
              onChanged: (String? newValue) {
                setState(() {
                  _expenditureFormFields.paidBy =
                      newValue ?? ACCOUNTS_ID.CASH_DRAWER_ACCOUNT_ID;
                  state.didChange(newValue);
                });
              },
              items: payerAccounts.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: _buildTextStyle(),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePickerButton(BuildContext context) {
    return OutlinedButton.icon(
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
    switch (_formDuty) {
      case FormDuty.DELETE:
      case FormDuty.READ:
      case FormDuty.CREATE:
        return _buildButton(
          context,
          'Create',
          Colors.green,
          () async {
            await _saveForm(
              () => ExpenditureModel.createExpenditureInDB(
                  _expenditureFormFields),
            );
          },
        );
      case FormDuty.EDIT:
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
                    _expenditureFormFields,
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
                  _formDuty = FormDuty.CREATE;
                  _expenditureFormFields = ExpenditurFormFields(
                    amount: 0,
                    note: '',
                    date: DateTime.now(),
                    paidBy: ACCOUNTS_ID.CASH_DRAWER_ACCOUNT_ID,
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
    if (_form.currentState == null) {
      print('EF20| Warn: _form.currentState == null');
      return;
    }
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      print('EF21| Warn: some of form feilds are not valid;');
      return;
    }
    _form.currentState!.save(); // run all onSaved method

    // add/edit expences in db
    // mod: new product creation
    if (true) {
      loadingStart();
      try {
        // save expences in database
        print(
          'EF23| @ _saveForm() | _expenditureFormFields: $_expenditureFormFields',
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

  void pickDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((date) {
      setState(() {
        // _selectedDate = date;
        _expenditureFormFields.date = date;
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
        _formDuty = FormDuty.CREATE;
        if (EnvironmentProvider.initializeExpenditureForm) {
          // _expenditureFormFields = ExpenditurFormFields.expenditureExample;
          // _selectedDate = ExpenditurFormFields.expenditureExample.date;
          _expenditureFormFields.date =
              ExpenditurFormFields.expenditureExample.date;
        }
      } else if (voucherToShowInForm.transactions.length > 2) {
        print(
          'EF 02| we can not show voucher with more than two transactions in this form ...',
        );
        _formDuty = FormDuty.CREATE;
        // maybe show money_movement form
        // ...
      } else {
        print(
          'EF 03| we need form read an existing voucher ...',
        );
        _formDuty = FormDuty.READ;
        var debitTransaction = voucherToShowInForm.transactions
            .firstWhere((tran) => tran!.isDebit);
        var creditTransaction = voucherToShowInForm.transactions
            .firstWhere((tran) => !tran!.isDebit);
        _expenditureFormFields = ExpenditurFormFields(
          id: creditTransaction!.id,
          amount: creditTransaction.amount,
          // do: accountId should be sync with list of PaidByAccounts
          paidBy: debitTransaction!.accountId,
          note: creditTransaction.note,
          date: creditTransaction.date,
          // tag: creditTransaction.tag,
        );
        // _selectedDate = creditTransaction.date;
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
    if (_expenditureFormFields.date == null) {
      return 'SELECT A DAY';
    }
    if (isToday(_expenditureFormFields.date!)) {
      return 'Today';
    }
    return '${_expenditureFormFields.date!.day}/${_expenditureFormFields.date!.month}/${_expenditureFormFields.date!.year}';
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

  Widget _buildPaidBy0(BuildContext context) {
    return TextFormField(
      decoration: _buildInputDecoration('Paid By ...'),
      style: _buildTextStyle(),
      keyboardType: TextInputType.multiline,
      initialValue: _expenditureFormFields.paidBy,
      focusNode: _paidByFocusNode,
      validator: (paidBy) {
        if (paidBy == null || paidBy.isEmpty) {
          return 'paidBy should not be empty';
        }
        return null;
      },
      onSaved: (paidBy) {
        // print('title-field.onSaved: descriptionField: $descriptionField');
        _expenditureFormFields.paidBy = paidBy;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Container(
      height: 150,
      width: 100,
      child: Row(
        children: [
          Expanded(
            // child: _selectedDate == null
            child: _expenditureFormFields.date == null
                ? const Text(
                    'DATE NOT CHOOSEN',
                    style: TextStyle(fontSize: 16),
                  )
                : Text(
                    // 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    'Date: ${_expenditureFormFields.date!.day}/${_expenditureFormFields.date!.month}/${_expenditureFormFields.date!.year}',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
          TextButton(
            onPressed: pickDate,
            child: Text(
              'CHANGE DATE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: 50,
      child: ElevatedButton(
        child: Text(
          _formDuty == FormDuty.CREATE ? 'CREATE' : 'READ',
          style: TextStyle(fontSize: 30),
        ),
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(
            vertical: 8,
          ),
        ),
        onPressed: () => _saveForm,
      ),
    );
  }

  Widget _buildButtonElevatedRectangle(
    BuildContext context,
    String text,
    Color color,
    Function function,
  ) {
    return ElevatedButton(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 26,
          wordSpacing: 2.0,
          letterSpacing: 2.0,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: color,
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 6,
        ),
      ),
      onPressed: () => function(),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    String text,
    Color color,
    Widget icon,
    Function onPressed,
  ) {
    return ElevatedButton.icon(
      icon: icon,
      label: Text(
        text,
        style: TextStyle(
          fontSize: 26,
          letterSpacing: 2.0,
          wordSpacing: 2.0,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: color,
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 6,
        ),
      ),
      onPressed: () => onPressed(),
    );
  }
}

enum FormDuty {
  READ,
  CREATE,
  EDIT,
  DELETE,
}

/*
HELP FORM DATA FLOW
1# by selection in data-table form re-build
2# 
*/
