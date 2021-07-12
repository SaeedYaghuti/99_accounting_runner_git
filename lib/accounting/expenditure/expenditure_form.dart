import 'dart:async';

import 'package:shop/accounting/accounting_logic/run_code.dart';
// import 'package:shop/auth/run_code.dart';

import 'package:provider/provider.dart';
import 'package:shop/auth/auth_db_helper.dart';
import 'package:shop/auth/auth_model_sql.dart';
import 'package:shop/auth/auth_provider_sql.dart';

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
              _buildListViewMeduim(context),
              // TextButton(
              //   onPressed: () {
              //     AccountingDB.deleteDB();
              //     AuthDB.deleteDB();
              //   },
              //   child: Text('DELETE DB'),
              // ),
              // SizedBox(height: 20, width: 20),
              // TextButton(
              //   onPressed: runCode,
              //   child: Text('RUN QUERY'),
              // ),
              // SizedBox(height: 20, width: 20),
              // Container(
              //   width: 300,
              //   height: 300,
              //   child: _buildExpandbleListView(context),
              // ),
              // SizedBox(height: 20, width: 20),
              // Container(
              //   width: 300,
              //   height: 500,
              //   child: ListView.builder(
              //     itemBuilder: (BuildContext context, int index) {
              //       return ExpandableListView(title: "Title $index");
              //     },
              //     itemCount: 5,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  } // build

  Widget _buildListViewMeduim(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                Expansiontile()));
                  },
                  child: Text('ExpansionTile'),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                Expansionpanel()));
                  },
                  child: Text('ExpansionPanel'),
                ),
              ),
            ],
          )
        ]);
  }

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

  Widget _buildExpandbleListView(BuildContext context) {
    return ListView.builder(
      itemCount: vehicles.length,
      itemBuilder: (context, i) {
        return new ExpansionTile(
          title: new Text(
            vehicles[i].title,
            style: new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
          children: <Widget>[
            new Column(
              children: _buildExpandableContent(vehicles[i]),
            ),
          ],
        );
      },
    );
  }

  _buildExpandableContent(Vehicle vehicle) {
    List<Widget> columnContent = [];

    for (String content in vehicle.contents)
      columnContent.add(
        new ListTile(
          title: new Text(
            content,
            style: new TextStyle(fontSize: 18.0),
          ),
          leading: new Icon(vehicle.icon),
        ),
      );

    return columnContent;
  }

  List<Vehicle> vehicles = [
    new Vehicle(
      'Bike',
      ['Vehicle no. 1', 'Vehicle no. 2', 'Vehicle no. 7', 'Vehicle no. 10'],
      Icons.motorcycle,
    ),
    new Vehicle(
      'Cars',
      ['Vehicle no. 3', 'Vehicle no. 4', 'Vehicle no. 6'],
      Icons.directions_car,
    ),
  ];

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

class Vehicle {
  final String title;
  List<String> contents = [];
  final IconData icon;

  Vehicle(this.title, this.contents, this.icon);
}

class ExpandableListView extends StatefulWidget {
  final String title;

  const ExpandableListView({Key? key, required this.title}) : super(key: key);

  @override
  _ExpandableListViewState createState() => new _ExpandableListViewState();
}

class _ExpandableListViewState extends State<ExpandableListView> {
  bool expandFlag = false;

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.symmetric(vertical: 1.0),
      child: new Column(
        children: <Widget>[
          new Container(
            color: Colors.blue,
            padding: new EdgeInsets.symmetric(horizontal: 5.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new IconButton(
                    icon: new Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: new BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: new Center(
                        child: new Icon(
                          expandFlag
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        expandFlag = !expandFlag;
                      });
                    }),
                new Text(
                  widget.title,
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                )
              ],
            ),
          ),
          new ExpandableContainer(
              expanded: expandFlag,
              child: new ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return new Container(
                    decoration: new BoxDecoration(
                        border: new Border.all(width: 1.0, color: Colors.grey),
                        color: Colors.black),
                    child: new ListTile(
                      title: new Text(
                        "Cool $index",
                        style: new TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      leading: new Icon(
                        Icons.local_pizza,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                itemCount: 15,
              ))
        ],
      ),
    );
  }
}

class ExpandableContainer extends StatelessWidget {
  final bool expanded;
  final double collapsedHeight;
  final double expandedHeight;
  final Widget child;

  ExpandableContainer({
    required this.child,
    this.collapsedHeight = 0.0,
    this.expandedHeight = 300.0,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return new AnimatedContainer(
      duration: new Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: screenWidth,
      height: expanded ? expandedHeight : collapsedHeight,
      child: new Container(
        child: child,
        decoration: new BoxDecoration(
            border: new Border.all(width: 1.0, color: Colors.blue)),
      ),
    );
  }
}

class Expansiontile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Expansion Tile'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20.0),
            ExpansionTile(
              title: Text(
                "Title",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              children: <Widget>[
                ExpansionTile(
                  title: Text(
                    'Sub title',
                  ),
                  children: <Widget>[
                    ListTile(
                      title: Text('data'),
                    )
                  ],
                ),
                ListTile(
                  title: Text('data'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*
HELP FORM DATA FLOW
1# by selection in data-table form re-build
2# 
*/

class Expansionpanel extends StatefulWidget {
  Expansionpaneltate createState() => Expansionpaneltate();
}

class NewItem {
  bool isExpanded;
  final String header;
  final Widget body;
  final Icon iconpic;
  NewItem(this.isExpanded, this.header, this.body, this.iconpic);
}

class Expansionpaneltate extends State<Expansionpanel> {
  List<NewItem> items = <NewItem>[
    NewItem(
        false, // isExpanded ?
        'Header', // header
        Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(children: <Widget>[
              Text('data'),
              Text('data'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('data'),
                  Text('data'),
                  Text('data'),
                ],
              ),
              Radio(value: null, groupValue: null, onChanged: null)
            ])), // body
        Icon(Icons.image) // iconPic
        ),
  ];
  ListView? List_Criteria;
  Widget build(BuildContext context) {
    List_Criteria = ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                items[index].isExpanded = !items[index].isExpanded;
              });
            },
            children: items.map((NewItem item) {
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                      leading: item.iconpic,
                      title: Text(
                        item.header,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ));
                },
                isExpanded: item.isExpanded,
                body: item.body,
              );
            }).toList(),
          ),
        ),
      ],
    );
    Scaffold scaffold = Scaffold(
      appBar: AppBar(
        title: Text("ExpansionPanelList"),
      ),
      body: List_Criteria,
    );
    return scaffold;
  }
}
