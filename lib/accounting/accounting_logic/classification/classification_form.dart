import 'dart:async';

import 'package:shop/accounting/accounting_logic/classification/classification_form_fields.dart';
import 'package:shop/accounting/accounting_logic/classification/trans_class_manage.dart';
import 'package:shop/accounting/accounting_logic/classification/transaction_classification.dart';

import 'package:provider/provider.dart';
import 'package:shop/accounting/expenditure/expenditure_class_tree.dart';
import 'package:shop/accounting/accounting_logic/classification/tran_class_dropdown_menu.dart';
import 'package:shop/accounting/expenditure/expenditure_screen_form.dart';
import 'package:shop/auth/auth_provider_sql.dart';

import 'package:flutter/material.dart';
import 'package:shop/accounting/environment/environment_provider.dart';
import 'package:shop/exceptions/curropted_input.dart';
import 'package:shop/exceptions/not_handled_exception.dart';
import 'package:shop/shared/show_error_dialog.dart';

class ClassificationForm extends StatefulWidget {
  final TransactionClassification parentClass;
  final TransactionClassification? tranClass;
  final FormDuty formDuty;
  final Function(TransactionClassification?) notifyTranClassChanged;

  const ClassificationForm({
    Key? key,
    this.tranClass,
    required this.parentClass,
    required this.formDuty,
    required this.notifyTranClassChanged,
  }) : super(key: key);

  @override
  _ClassificationFormState createState() => _ClassificationFormState();
}

class _ClassificationFormState extends State<ClassificationForm> {
  late AuthProviderSQL authProviderSQL;
  var _fields = ClassificationFormFields();
  late FormDuty _formDuty;
  var _didChangeRun = false;

  @override
  void initState() {
    _formDuty = widget.formDuty;
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
    // think for permission ...
    // when we reach hear it means we have perm; perms should be controll first at caller and then at code
    authProviderSQL = Provider.of<AuthProviderSQL>(context, listen: true);
    _fields.authId = authProviderSQL.authId;
    switch (widget.formDuty) {
      case FormDuty.READ:
      case FormDuty.CREATE:
        initStateCreate();
        break;
      case FormDuty.EDIT:
        initStateEdit();
        break;
      case FormDuty.DELETE:
        initStateDelete();
        break;
      default:
        throw NotHandledException(
            'CLSS_FORM | didChangeDependencies() 01 | We have a FormDuty element that is not handled: ${widget.formDuty}');
    }
    _didChangeRun = true;
  }

  void initStateCreate() {
    // print('EF | init_state | form rebuild for READ or CREATE ...');
    if (widget.parentClass == null) {
      throw CurroptedInputException(
        'CLASS_FORM | initStateCreate() 01 | parentClass should not be null at create_mode',
      );
    }
    _fields.parentClass = widget.parentClass;
    if (EnvironmentProvider.initializeTransClassForm) {
      var example = ClassificationFormFields.expenditureExample;
      _fields.titleEnglish = example.titleEnglish;
      _fields.titlePersian = example.titlePersian;
      _fields.titleArabic = example.titleArabic;
      _fields.note = example.note;
    }
  }

  void initStateEdit() {
    // print('CLSS_FORM | initStateEdit() 01|');
    // print(widget.voucher);
    if (widget.tranClass == null || widget.parentClass == null) {
      print('CLSS_FORM | initStateEdit() 01| formDuty is Edit but given tranClass is null');
      throw CurroptedInputException('CLSS_FORM | initStateEdit() 01| formDuty is Edit but given tranClass is null');
    }
    _fields.id = widget.tranClass!.id;
    _fields.parentClass = widget.parentClass;
    _fields.titleEnglish = widget.tranClass!.titleEnglish;
    _fields.titlePersian = widget.tranClass!.titlePersian;
    _fields.titleArabic = widget.tranClass!.titleArabic;
    _fields.note = widget.tranClass!.note;

    // print('CLSS_FORM init_state| EDIT 03| prepared _expenditureFormFields');
    // print(_fields);
    setState(() {});
  }

  void initStateDelete() {
    // print('EF | init_state | form rebuild for DELETE');
    if (widget.tranClass == null) return;
    loadingStart();
    widget.tranClass!.deleteMeFromDB(authProviderSQL).then((deleteResult) {
      loadingEnd();
      print('CLSS_FORM | initStateDelete() 01 | deleteResult: $deleteResult');
      widget.notifyTranClassChanged(widget.tranClass!);
    }).catchError((e) {
      loadingEnd();
      showErrorDialog(
        context,
        'tranClass .deleteMeFromDB()',
        'ClassificationForm at initState while deleting a tranClass happend error:',
        e,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // print('CLS_FORM | build() 01 | run ...');
    return Container(
      width: 1200,
      padding: EdgeInsets.all(16),
      child: Form(
        key: _fields.formKey,
        child: Container(
          width: 1200,
          child: ListView(
            children: [
              SizedBox(height: 20, width: 20),
              _buildParentClass(context),
              SizedBox(height: 20, width: 20),
              _buildTitleEnglish(context),
              SizedBox(height: 20, width: 20),
              _buildTitlePersian(context),
              SizedBox(height: 20, width: 20),
              _buildTitleArabic(context),
              SizedBox(height: 20, width: 20),
              _buildNote(context),
              SizedBox(height: 20, width: 20),
              _buildSubmitButtons(context),
            ],
          ),
        ),
      ),
    );
  } // build

  Widget _buildParentClass(BuildContext context) {
    return TextFormField(
      decoration: _buildInputDecoration('Parent Class', Icons.bookmark_outline_rounded),
      style: _buildTextStyle(context, enabled: _formDuty == FormDuty.CREATE ? false : true),
      showCursor: false,
      readOnly: true,
      enabled: _formDuty == FormDuty.CREATE ? false : true,
      focusNode: _fields.parentClassFocusNode,
      controller: _fields.parentClassController,
      textInputAction: TextInputAction.next,
      onTap: () {
        _pickExpClass(
          (tappedExpClass) {
            _fields.parentClass = tappedExpClass;
          },
        );
        FocusScope.of(context).requestFocus(_fields.titleEnglishFocusNode);
      },
      validator: _fields.validateParentClass,
      // onSaved: (amount) {
      //   we do add saving at expFormFields when setting data
      // },
    );
  }

  Widget _buildTitleEnglish(BuildContext context) {
    return TextFormField(
      decoration: _buildInputDecoration('English Title', Icons.title_outlined),
      style: _buildTextStyle(context),
      textInputAction: TextInputAction.next,
      controller: _fields.titleEnglishController,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_fields.titlePersianFocusNode);
      },
      validator: _fields.validateTitleEnglish,
      onSaved: (titleEnglish) {
        // print('titleField.onSaved: titleField: $titleField');
        _fields.titleEnglish = titleEnglish;
      },
    );
  }

  Widget _buildTitlePersian(BuildContext context) {
    return TextFormField(
      decoration: _buildInputDecoration('Persian Title', Icons.language_outlined),
      style: _buildTextStyle(context),
      textInputAction: TextInputAction.next,
      controller: _fields.titlePersianController,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_fields.titleArabicFocusNode);
      },
      validator: _fields.validateTitlePersian,
      onSaved: (titlePersian) {
        // print('titleField.onSaved: titleField: $titleField');
        _fields.titlePersian = titlePersian;
      },
    );
  }

  Widget _buildTitleArabic(BuildContext context) {
    return TextFormField(
      decoration: _buildInputDecoration('Arabic Title', Icons.language_outlined),
      style: _buildTextStyle(context),
      textInputAction: TextInputAction.next,
      controller: _fields.titleArabicController,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_fields.noteFocusNode);
      },
      validator: _fields.validateTitleArabic,
      onSaved: (titleArabic) {
        // print('titleField.onSaved: titleField: $titleField');
        _fields.titleArabic = titleArabic;
      },
    );
  }

  Widget _buildNote(BuildContext context) {
    return TextFormField(
      decoration: _buildInputDecoration('Note', Icons.note_outlined),
      style: _buildTextStyle(context),
      maxLines: 2,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.next,
      controller: _fields.noteController,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_fields.titleEnglishFocusNode);
      },
      validator: _fields.validateNote,
      onSaved: (note) {
        // print('titleField.onSaved: titleField: $titleField');
        _fields.note = note;
      },
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
          _saveForm,
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
              _saveForm,
            ),
            SizedBox(height: 10),
            _buildButton(
              context,
              'Cancel Editing',
              Colors.grey,
              () {
                setState(() {
                  _formDuty = FormDuty.CREATE;
                  _fields = ClassificationFormFields.expenditureExample;
                });
              },
            ),
          ],
        );
      default:
        throw NotHandledException('EF 40| _buildSubmitButtons');
    }
  }

  Future<void> _saveForm() async {
    final isValid = _fields.validate(_formDuty);
    if (!isValid.outcome) {
      print('EF21| Error: ${isValid.errorMessage}');
      throw CurroptedInputException('CLSS_FORM| _saveForm() 01 | Error: ${isValid.errorMessage}');
    }
    _fields.formKey.currentState!.save(); // run all onSaved method
    loadingStart();
    TransactionClassification? operandClass;
    switch (_formDuty) {
      case FormDuty.CREATE:
        try {
          operandClass = await TranClassManagement.createTranClassInDB(
            authProviderSQL,
            _fields,
          );
        } catch (e) {
          loadingEnd();
          showErrorDialog(
            context,
            'Error while _saveForm() > TranClassManagement.createTranClassInDB()',
            'source: CLASS_FRM 11',
            e,
          );
        }
        break;
      case FormDuty.EDIT:
        try {
          operandClass = await TranClassManagement.editTranClassInDB(
            authProviderSQL,
            _fields,
          );
        } catch (e) {
          loadingEnd();
          showErrorDialog(
            context,
            'Error while _saveForm() > TranClassManagement.editTranClassInDB()',
            'source: CLASS_FRM 12',
            e,
          );
        }
        break;
      default:
    }
    widget.notifyTranClassChanged(operandClass);
    loadingEnd();
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

  void _pickExpClass(Function(TransactionClassification) selectedClassHandler) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('SELECT EXPENDITURE CLASS:'),
            children: [
              TranClassDropdownMenu(
                expandedTranClassIds: [
                  ExpClassIds.MAIN_EXP_CLASS_ID,
                  ExpClassIds.SHOP_EXP_CLASS_ID,
                  ExpClassIds.STAFF_EXP_CLASS_ID,
                ],
                unwantedTranClassIds: [],
                tapHandler: (TransactionClassification tappedExpClass) {
                  Navigator.of(context).pop();
                  setState(() {
                    // _fields.tranClass = tappedExpClass;
                    selectedClassHandler(tappedExpClass);
                  });
                },
              ),
            ],
          );
        });
  }

  // void initializeForm0(VoucherModel? voucherToShowInForm, int? expenseIdToShowInForm) {
  //   // Exp_Form called without passing voucher: means we are in create mode
  //   if (voucherToShowInForm == null || expenseIdToShowInForm == null) {
  //     print('EF 01| we need form for create new voucher ...');
  //     _formDuty = FormDuty.CREATE;
  //     if (EnvironmentProvider.initializeExpenditureForm) {
  //       // _expenditureFormFields = ClassificationFormFields.expenditureExample;
  //       // _selectedDate = ClassificationFormFields.expenditureExample.date;
  //       _fields.date = ClassificationFormFields.expenditureExample.date;
  //     }
  //     setState(() {});
  //     return;
  //   }
  //   // Exp_Form called with voucher that contains 3 trans or more: we can not show in this simple form
  //   if (voucherToShowInForm.transactions.length > 2) {
  //     print(
  //       'EF 02| we can not show voucher with more than two transactions in this form ...',
  //     );
  //     _formDuty = FormDuty.CREATE;
  //     // show money_movement form
  //     // ...
  //     setState(() {});
  //     return;
  //   }
  //   // we want to edit voucher in form; we don't have read mode for voucher in form
  //   _formDuty = FormDuty.EDIT;
  //   var debitTransaction = voucherToShowInForm.transactions.firstWhere((tran) => tran!.isDebit);
  //   var creditTransaction = voucherToShowInForm.transactions.firstWhere((tran) => !tran!.isDebit);
  //   AccountModel.fetchAccountById(debitTransaction!.accountId).then(
  //     (acc) {
  //       _fields = ClassificationFormFields(
  //         id: creditTransaction!.id,
  //         amount: creditTransaction.amount,
  //         paidBy: acc,
  //         note: creditTransaction.note,
  //         date: creditTransaction.date,
  //         // tag: creditTransaction.tag,
  //       );
  //       setState(() {});
  //     },
  //   ).catchError((e) {
  //     print(
  //       'CLSS_FORM initializeForm 04| e in fetching account: ${debitTransaction.accountId} e: $e',
  //     );
  //     _formDuty = FormDuty.CREATE;
  //     setState(() {});
  //   });
  // }

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

  TextStyle _buildTextStyle(BuildContext context, {bool enabled = true}) {
    return TextStyle(
      fontSize: 23,
      color: enabled ? Colors.black : Theme.of(context).primaryColor.withOpacity(0.6),
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
}
