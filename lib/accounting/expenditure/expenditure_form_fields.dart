import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/accounts_tree.dart';
import 'package:shop/accounting/accounting_logic/transaction_classification.dart';
import 'package:shop/accounting/expenditure/expenditure_class_tree.dart';
import 'package:shop/accounting/expenditure/x_expenditure_%20classification_perm.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/constants.dart';
import 'package:shop/shared/result_status.dart';

class ExpenditurFormFields {
  final formKey = GlobalKey<FormState>();
  final amountFocusNode = FocusNode();
  final noteFocusNode = FocusNode();
  final paidByFocusNode = FocusNode();
  final expClassFocusNode = FocusNode();
  final dateFocusNode = FocusNode();
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController paidByController = TextEditingController();
  bool hasErrorExpClass = false;
  bool hasErrorPaidBy = false;
  bool hasErrorDate = false;

  int? id;
  int? authId;
  AccountModel? paidByAccount;
  TransactionClassification? expClass;
  DateTime? date;
  Function? resetState;

  ExpenditurFormFields({
    int? id,
    int? authId,
    AuthProviderSQL? authProvider,
    double? amount,
    AccountModel? paidBy,
    String? note,
    TransactionClassification? expClass,
    DateTime? date,
    Function? resetState,
  }) {
    this.id = id;
    this.authId = authId;
    this.amount = amount;
    this.note = note;
    this.paidBy = paidBy;
    this.expClass = expClass;
    this.date = date;
    this.resetState = resetState;
  }

  double? get amount {
    return double.tryParse(amountController.text);
  }

  set amount(double? num) {
    this.amountController.text = (num == null || num == 0.0) ? '' : num.toString();
  }

  AccountModel? get paidBy {
    return paidByAccount;
  }

  set paidBy(AccountModel? paidByAcc) {
    this.paidByAccount = paidByAcc;
    this.paidByController.text = (paidByAcc == null) ? '' : paidByAcc.titleEnglish;
  }

  String? get note {
    return noteController.text;
  }

  set note(String? text) {
    this.noteController.text = text ?? '';
  }

  Result<bool> validate() {
    if (formKey.currentState == null) {
      print('EF20| Warn: _formKey.currentState == null');
      return Result(false, '_formKey.currentState is null');
    }
    // step#1 validate custom fields that have no predifined validate() method
    var errorMessages = '';
    if (paidByAccount == null) {
      hasErrorExpClass = true;
      errorMessages += '\nPaidBy is empty';
    }
    if (date == null) {
      hasErrorDate = true;
      errorMessages += '\nDate is empty';
    }
    if (expClass == null) {
      hasErrorExpClass = true;
      errorMessages += '\nExpClass is empty';
    }

    // step#2 validate FormField that have predifined validate() method
    final isValid = formKey.currentState!.validate();

    if (!isValid) {
      errorMessages += '\nSome of regular form FormFeilds are not valid';
    }
    // print('EXP_FRM_FIELD | validate() | errorMessages: $errorMessages');

    if (resetState != null) resetState!();

    if (errorMessages == '') {
      return Result(true);
    } else {
      return Result(false, errorMessages);
    }
  }

  static ExpenditurFormFields get expenditureExample {
    AccountModel cashDrawer = ACCOUNTS_TREE.firstWhere((acc) => acc.id == PAID_EXPENDITURE_BY);
    return ExpenditurFormFields(
      id: null,
      amount: 3.750,
      paidBy: cashDrawer,
      note: 'nescafee and cup',
      date: DateTime.now(),
      expClass: EXP_CLASS_TREE.firstWhere((expClass) => expClass.id == ExpClassIds.GENERAL_EXP_CLASS_ID),
    );
  }

  String? validateAmount(String? amount) {
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
  }

  String? validateNote(String? note) {
    if (note == null || note.isEmpty) {
      return 'Note should not be empty';
    }
    return null;
  }

  @override
  String toString() {
    return '''
      id: $id,
      amoutn: $amount, 
      paidBy: ${paidByAccount?.titleEnglish}, 
      note: $note, date: $date, 
      expClass: $expClass, 
    ''';
  }
}
