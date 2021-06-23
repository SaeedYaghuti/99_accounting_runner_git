import 'package:flutter/material.dart';
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
  final expenditureExample = ExpenditurFormFields.expenditureExample;
  DateTime? selectedDate;
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _form,
        autovalidate: true,
        child: ListView(
          children: [
            _buildAmount(context),
            SizedBox(height: 20),
            _buildNote(context),
            SizedBox(height: 20),
            _buildPaidBy(context),
            SizedBox(height: 20),
            _buildDatePicker(context),
            SizedBox(height: 20),
            _buildSaveButton(context),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  } // build

  Widget _buildAmount(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Amount',
        labelStyle: TextStyle(
          fontSize: 30,
        ),
        // hintText: 'number',
        // helperText: 'paid amount',
        // counterText: '0.0',
        // prefixIcon: Icon(Icons.money_outlined),
        // icon: Icon(Icons.monetization_on_rounded),
        // suffixIcon: Icon(Icons.account_balance_outlined),
        // prefix: Text('Prefix:'),
      ),
      focusNode: _amountFocusNode,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      initialValue: (expenditureExample.amount != null)
          ? expenditureExample.amount.toString()
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
        expenditureExample.amount = double.parse(amount!);
      },
    );
  }

  Widget _buildNote(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Note',
        // hintText: 'text',
        // helperText: 'what did you buy',
        // counterText: '0.0',
        // prefixIcon: Icon(Icons.money_outlined),
        // icon: Icon(Icons.monetization_on_rounded),
        // suffixIcon: Icon(Icons.account_balance_outlined),
        // prefix: Text('Prefix:'),
      ),
      maxLines: 2,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.next,
      initialValue: expenditureExample.note.toString(),
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
        expenditureExample.note = note;
      },
    );
  }

  Widget _buildPaidBy(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Paid by',
        // hintText: 'text',
        // helperText: 'what did you buy',
        // counterText: '0.0',
        // prefixIcon: Icon(Icons.money_outlined),
        // icon: Icon(Icons.monetization_on_rounded),
        // suffixIcon: Icon(Icons.account_balance_outlined),
        // prefix: Text('Prefix:'),
      ),
      keyboardType: TextInputType.multiline,
      initialValue: expenditureExample.paidBy,
      focusNode: _paidByFocusNode,
      validator: (paidBy) {
        if (paidBy == null || paidBy.isEmpty) {
          return 'paidBy should not be empty';
        }
        return null;
      },
      onSaved: (paidBy) {
        // print('title-field.onSaved: descriptionField: $descriptionField');
        expenditureExample.paidBy = paidBy;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Container(
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: selectedDate == null
                ? const Text('DATE NOT CHOOSEN')
                : Text(
                    'Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  ),
          ),
          TextButton(
            onPressed: pickDate,
            child: Text(
              'SELECT ANOTHER DATE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return TextButton(
      onPressed: _saveForm,
      child: Text(
        'SAVE',
        style: TextStyle(fontSize: 22),
      ),
      style: TextButton.styleFrom(primary: Theme.of(context).primaryColor),
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
        // ...
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
        selectedDate = date;
        expenditureExample.date = date;
      });
    });
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
