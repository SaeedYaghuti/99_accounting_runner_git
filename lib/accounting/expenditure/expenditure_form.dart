import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_management.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/environment/environment_provider.dart';
import 'package:shop/accounting/expenditure/expenditure_model.dart';
import 'package:shop/shared/show_error_dialog.dart';

import 'expenditure_form_fields.dart';

class ExpenditureForm extends StatefulWidget {
  const ExpenditureForm({Key? key}) : super(key: key);

  @override
  _ExpenditureFormState createState() => _ExpenditureFormState();
}

class _ExpenditureFormState extends State<ExpenditureForm> {
  final _form = GlobalKey<FormState>();
  final _amountFocusNode = FocusNode();
  final _noteFocusNode = FocusNode();
  final _paidByFocusNode = FocusNode();
  final _dateFocusNode = FocusNode();
  var _expenditureFormFields = ExpenditurFormFields();
  DateTime? _selectedDate;
  var _isLoading = false;

  @override
  void initState() {
    if (EnvironmentProvider.initializeExpenditureForm) {
      initializeForm();
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
        autovalidate: true,
        child: Container(
          width: 1200,
          // height: 300,
          child: ListView(
            // scrollDirection: Axis.horizontal,
            children: [
              _buildAmount(context),
              SizedBox(height: 20, width: 20),
              _buildNote(context),
              SizedBox(height: 20, width: 20),
              _buildPaidBy(context),
              SizedBox(height: 20, width: 20),
              _buildDatePicker2(context),
              SizedBox(height: 20, width: 20),
              _buildSaveButton(context),
              SizedBox(height: 20, width: 20),
              TextButton(
                onPressed: AccountingDB.deleteDB,
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

  Widget _buildDatePicker2(BuildContext context) {
    return OutlineButton.icon(
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

  Widget _buildDatePicker(BuildContext context) {
    return Container(
      height: 150,
      width: 100,
      child: Row(
        children: [
          Expanded(
            child: _selectedDate == null
                ? const Text(
                    'DATE NOT CHOOSEN',
                    style: TextStyle(fontSize: 16),
                  )
                : Text(
                    'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
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
        onPressed: _saveForm,
        child: Text(
          'SAVE',
          style: TextStyle(fontSize: 30),
        ),
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(
            vertical: 8,
          ),
        ),
      ),
    );
  }

  void _saveForm() {
    if (_form.currentState == null) {
      print('EF20| Warn: _form.currentState == null');
      return;
    }
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      print('EF21| Warn: some of form feilds are not valid;');
      return;
    }
    _form.currentState!.save(); // run onSaved method

    // add/edit expences in db
    // mod: new product creation
    if (true) {
      startLoading();
      try {
        // save expences in database
        ExpenditureModel.createExpenditureInDB(_expenditureFormFields);
        endLoading();
      } catch (e) {
        endLoading();
        showErrorDialog(
          context,
          'Error while addProduct',
          'source: ProductFormScreen.dart <PFS_L>',
          e,
        );
      }
    }
    // mod: updating product
    // ...
  }

  void pickDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((date) {
      setState(() {
        _selectedDate = date;
        _expenditureFormFields.date = date;
      });
    });
  }

  void initializeForm() {
    _expenditureFormFields = ExpenditurFormFields.expenditureExample;
    _selectedDate = _expenditureFormFields.date;
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

  void runCode() async {
    // await VoucherModel.fetchAllVouchers();
    // await TransactionModel.allTransactions();
    // await TransactionModel.allTranJoinVch();
    // await TransactionModel.allTranJoinVchForAccount('expenditure');
    // await VoucherManagement.createVoucher();
    await VoucherModel.maxVoucherNumber();
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
    if (_selectedDate == null) {
      return 'SELECT A DAY';
    }
    if (isToday(_selectedDate!)) {
      return 'Today';
    }
    return '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
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

  void startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void endLoading() {
    setState(() {
      _isLoading = false;
    });
  }
}
