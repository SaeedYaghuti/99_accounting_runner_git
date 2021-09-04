import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/classification/transaction_classification.dart';
import 'package:shop/accounting/accounting_logic/float_dropdown_menu.dart';
import 'package:shop/accounting/accounting_logic/floating_account.dart';
import 'package:shop/accounting/accounting_logic/floating_account_tree.dart';
import 'package:shop/accounting/accounting_logic/run_code.dart';
// import 'package:shop/auth/run_code.dart';

import 'package:provider/provider.dart';
import 'package:shop/accounting/accounting_logic/account_dropdown_menu.dart';
import 'package:shop/accounting/expenditure/expenditure_class_tree.dart';
import 'package:shop/auth/auth_db_helper.dart';
import 'package:shop/auth/auth_provider_sql.dart';

import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/environment/environment_provider.dart';
import 'package:shop/accounting/expenditure/expenditure_model.dart';
import 'package:shop/auth/has_access.dart';
import 'package:shop/auth/permission_model.dart';
import 'package:shop/exceptions/curropted_input.dart';
import 'package:shop/exceptions/not_handled_exception.dart';
import 'package:shop/shared/custom_form_fields/float_selection_form_field.dart';
import 'package:shop/shared/custom_form_fields/form_fields_screen.dart';
import 'package:shop/shared/custom_form_fields/multi_selection_form_field.dart';
import 'package:shop/shared/show_error_dialog.dart';
import '../accounting_logic/classification/tran_class_dropdown_menu.dart';
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
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didChangeRun) return;

    authProviderSQL = Provider.of<AuthProviderSQL>(context, listen: true);
    _fields.authId = authProviderSQL.authId;
    _fields.paidBy = hasAccess(
            authProviderSQL: authProviderSQL,
            vitalPermissions: [ExpenditurFormFields.expenditureExample.paidByAccount?.createTransactionPermission])
        ? ExpenditurFormFields.expenditureExample.paidByAccount
        : null;
    _fields.expClass = ExpenditurFormFields.expenditureExample.expClass;
    _fields.floatAccount = ExpenditurFormFields.expenditureExample.floatAccount;
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
      print('EXP_SCN_FRM| initStateDelete() 01 | deleteResult: $deleteResult');
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
    // print('EXP_FRM | initStateEdit() 01|');
    // print(widget.voucher);

    if (widget.voucher!.transactions.length > 2) {
      print('EXP_FRM | initStateEdit() | we can not show voucher with more than two transactions in this form ...');
      _formDuty = FormDuty.CREATE;
      // maybe show money_movement form
    }
    // print('EXP_FRM | initStateEdit() | voucher to edite');
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
      _fields.expClass = creditTransaction.tranClass;
      _fields.floatAccount = creditTransaction.floatAccount;
      _fields.date = creditTransaction.date;
      _fields.note = creditTransaction.note;

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
              _buildDatePickerButton(context),
              SizedBox(height: 20, width: 20),
              _buildPaidBy(context),
              SizedBox(height: 20, width: 20),
              _buildExpClass(context),
              SizedBox(height: 20, width: 20),
              _buildFloatAccount(context),
              SizedBox(height: 20, width: 20),
              _buildMultiSelection(context),
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

  Widget _buildMultiSelection(BuildContext context) {
    return FloatSelectionFormField<FloatingAccount>(
      dropDownMenu: (selectFloatHandler) => _buildFloatAccountDDM(context, selectFloatHandler),
      decoration: _buildInputDecoration('Floating Accounts', Icons.account_box_outlined),
      hint: Text('Select more interests'),
      isDense: true,
      focusNode: _fields.multiselectionFocusNode,
      // options: Interest.values,
      options: [],
      titleBuilder: (float) => Text(float.titleEnglish),
      chipLabelBuilder: (float) => Text(float.titleEnglish),
      chipBackgroundColor: Colors.purple.withOpacity(0.1),
      chipDeleteIconColor: Colors.purple.withOpacity(0.5),
      // initialValues: [Interest.Art, Interest.Blogging, Interest.Cooking],
      initialValues: [],
      validator: (interests) => interests == null || interests.length < 3 ? 'Please select at least 3 interests' : null,
      onSaved: (interests) {
        // _formResult.interests = interests!;
      },
      onChanged: (_) {
        FocusScope.of(context).unfocus();
        // FocusScope.of(context).requestFocus(interestsFocusNode);
      },
    );
  }

  Widget _buildMultiSelection0(BuildContext context) {
    return MyMultiSelectionFormField<Interest>(
      dropDownMenu: (selectFloatHandler) => _buildFloatAccountDDM(context, (selectFloatHandler) {}),
      decoration: _buildInputDecoration('Floating Accounts', Icons.account_box_outlined),
      hint: Text('Select more interests'),
      isDense: true,
      focusNode: _fields.multiselectionFocusNode,
      options: Interest.values,
      titleBuilder: (interest) => Text(describeEnum(interest)),
      chipLabelBuilder: (interest) => Text(describeEnum(interest)),
      chipBackgroundColor: Colors.purple.withOpacity(0.1),
      chipDeleteIconColor: Colors.purple.withOpacity(0.5),
      initialValues: [Interest.Art, Interest.Blogging, Interest.Cooking],
      validator: (interests) => interests == null || interests.length < 3 ? 'Please select at least 3 interests' : null,
      onSaved: (interests) {
        // _formResult.interests = interests!;
      },
      onChanged: (_) {
        FocusScope.of(context).unfocus();
        // FocusScope.of(context).requestFocus(interestsFocusNode);
      },
    );
  }

  Widget _buildAmount(BuildContext context) {
    // print('EXP_FRM | _buildAmount | run ...');
    return TextFormField(
      decoration: _buildInputDecoration('Amount', Icons.monetization_on),
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

  Widget _buildPaidBy(BuildContext context) {
    return TextFormField(
      decoration: _buildInputDecoration('Paid By', Icons.credit_card),
      style: _buildTextStyle(),
      showCursor: false,
      readOnly: true,
      focusNode: _fields.paidByFocusNode,
      controller: _fields.paidByController,
      textInputAction: TextInputAction.next,
      onTap: () {
        _pickAccount();
        FocusScope.of(context).requestFocus(_fields.dateFocusNode);
      },
      validator: _fields.validatePaidBy,
      // onSaved: (amount) {
      //   we do add saving at expFormFields when setting data
      // },
    );
  }

  Widget _buildNote(BuildContext context) {
    return TextFormField(
      decoration: _buildInputDecoration('Note', Icons.note_outlined),
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

  Widget _buildExpClass(BuildContext context) {
    return TextFormField(
      decoration: _buildInputDecoration('Tag', Icons.bookmark_outline_rounded),
      style: _buildTextStyle(),
      showCursor: false,
      readOnly: true,
      focusNode: _fields.expClassFocusNode,
      controller: _fields.expClassController,
      textInputAction: TextInputAction.next,
      onTap: () {
        _pickExpClass();
        FocusScope.of(context).requestFocus(_fields.floatFocusNode);
      },
      validator: _fields.validateExpClass,
      // onSaved: (amount) {
      //   we do add saving at expFormFields when setting data
      // },
    );
  }

  Widget _buildFloatAccountDDM(BuildContext context, Function(FloatingAccount) floatHandlerSelection) {
    return TextFormField(
      // decoration: _buildInputDecoration('Float Account', Icons.account_box_outlined),
      style: _buildTextStyle(),
      showCursor: false,
      readOnly: true,
      // focusNode: _fields.floatFocusNode,
      // controller: _fields.floatController,
      textInputAction: TextInputAction.next,
      onTap: () {
        _pickFloat((FloatingAccount tappedFloat) {
          Navigator.of(context).pop();
          floatHandlerSelection(tappedFloat);
          // setState(() {
          //   _fields.floatAccount = tappedFloat;
          // });
        });
        FocusScope.of(context).requestFocus(_fields.dateFocusNode);
      },
      validator: _fields.validateFloatAccount,
      // onSaved: (amount) {
      //   we do add saving at expFormFields when setting data
      // },
    );
  }

  Widget _buildFloatAccount(BuildContext context) {
    return TextFormField(
      decoration: _buildInputDecoration('Float Account', Icons.account_box_outlined),
      style: _buildTextStyle(),
      showCursor: false,
      readOnly: true,
      focusNode: _fields.floatFocusNode,
      controller: _fields.floatController,
      textInputAction: TextInputAction.next,
      onTap: () {
        _pickFloat((FloatingAccount tappedFloat) {
          Navigator.of(context).pop();
          setState(() {
            _fields.floatAccount = tappedFloat;
          });
        });
        FocusScope.of(context).requestFocus(_fields.dateFocusNode);
      },
      validator: _fields.validateFloatAccount,
      // onSaved: (amount) {
      //   we do add saving at expFormFields when setting data
      // },
    );
  }

  Widget _buildDatePickerButton(BuildContext context) {
    return TextFormField(
      decoration: _buildInputDecoration('Date', Icons.date_range_rounded),
      style: _buildTextStyle(),
      showCursor: false,
      readOnly: true,
      focusNode: _fields.dateFocusNode,
      controller: _fields.dateController,
      textInputAction: TextInputAction.next,
      onTap: () {
        pickDate();
        FocusScope.of(context).requestFocus(_fields.noteFocusNode);
      },
      validator: _fields.validateDate,
      // onSaved: (amount) {
      //   we do add saving at expFormFields when setting data
      // },
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
                    paidBy: ExpenditurFormFields.expenditureExample.paidByAccount,
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
      print('EF21| Error: ${isValid.errorMessage}');
      throw CurroptedInputException('EF21| Error: ${isValid.errorMessage}');
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
              TranClassDropdownMenu(
                showMoreIcon: authProviderSQL.isPermitted(PermissionModel.TRANSACTION_CLASS_CRED),
                expandedTranClassIds: [
                  ExpClassIds.EXP_ROOT_CLASS_ID,
                  ExpClassIds.EXP_SHOP_CLASS_ID,
                  ExpClassIds.EXP_STAFF_CLASS_ID,
                ],
                unwantedTranClassIds: [],
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

  void _pickFloat(Function(FloatingAccount) tapHandler) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('SELECT FLOAT ACCOUNT:'),
            children: [
              FloatDropdownMenu(
                authProvider: authProviderSQL,
                formDuty: _formDuty,
                expandedAccountIds: [
                  FloatAccountIds.ROOT_FLOAT_ACCOUNT_ID,
                  FloatAccountIds.SALESMAN_FLOAT_ACCOUNT_ID,
                ],
                unwantedAccountIds: [],
                tapHandler: (FloatingAccount tappedFloat) => tapHandler(tappedFloat),
                // tapHandler: (FloatingAccount tappedFloat) {
                //   Navigator.of(context).pop();
                //   setState(() {
                //     _fields.floatAccount = tappedFloat;
                //   });
                // },
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

  InputDecoration _buildInputDecoration(String labelText, [IconData? icon]) {
    return InputDecoration(
      border: OutlineInputBorder(),
      labelText: labelText,
      labelStyle: TextStyle(
        // color: Colors.black87,
        color: Colors.purple,
        fontSize: 26,
      ),
      hintStyle: TextStyle(
        // color: Colors.black87,
        color: Colors.amber,
      ),
      // hintText: 'number',
      // helperText: 'paid amount',
      // counterText: '0.0',
      // prefixIcon: Icon(Icons.money_outlined),
      // icon: Icon(Icons.monetization_on_rounded),
      suffixIcon: icon != null
          ? Icon(
              icon,
              color: Theme.of(context).primaryColor,
            )
          : null,
      // prefix: Text('OMR '),
    );
  }

  TextStyle _buildTextStyle() {
    return TextStyle(
      fontSize: 23,
      color: Colors.black,
    );
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

  // ### Depricated method
  Widget _buildPaidBy0(BuildContext context) {
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
        Icons.credit_card_rounded,
        // color: Theme.of(context).primaryColor,
      ),
      label: Text(
        _fields.paidByAccount?.titleEnglish ?? 'SELECT ACCOUNT',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          // color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildExpClass0(BuildContext context) {
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
        Icons.category_outlined,
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

  // Widget _buildDatePickerButton0(BuildContext context) {
  //   return OutlinedButton.icon(
  //     focusNode: _fields.dateFocusNode,
  //     style: OutlinedButton.styleFrom(
  //       primary: _fields.hasErrorDate ? Colors.white : Theme.of(context).primaryColor,
  //       backgroundColor: _fields.hasErrorDate ? Colors.pinkAccent : Colors.white,
  //     ),
  //     onPressed: () {
  //       pickDate();
  //       FocusScope.of(context).requestFocus(_fields.dateFocusNode);
  //     },
  //     icon: Icon(
  //       Icons.date_range_rounded,
  //       // color: Theme.of(context).primaryColor,
  //     ),
  //     label: Text(
  //       _buildTextForDatePicker(),
  //       style: TextStyle(
  //         fontWeight: FontWeight.bold,
  //         fontSize: 20,
  //         // color: Theme.of(context).primaryColor,
  //       ),
  //     ),
  //   );
  // }

}

enum FormDuty {
  READ, // currntly we don't have action for read
  CREATE,
  EDIT,
  DELETE,
}
