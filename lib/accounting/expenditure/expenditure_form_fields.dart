import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/accounts_tree.dart';
import 'package:shop/accounting/expenditure/expenditure_%20classification.dart';
import 'package:shop/accounting/expenditure/expenditure_classification_tree.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/constants.dart';
import 'package:shop/shared/result_status.dart';

import 'expenditure_tag.dart';

class ExpenditurFormFields {
  final formKey = GlobalKey<FormState>();
  final amountFocusNode = FocusNode();
  final noteFocusNode = FocusNode();
  final paidByFocusNode = FocusNode();
  final expClassFocusNode = FocusNode();
  final dateFocusNode = FocusNode();
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  int? id;
  int? authId;
  AccountModel? paidBy;
  ExpenditureClassification? expClass;
  DateTime? date;

  ExpenditurFormFields({
    int? id,
    int? authId,
    AuthProviderSQL? authProvider,
    double? amount,
    AccountModel? paidBy,
    String? note,
    ExpenditureClassification? expClass,
    DateTime? date,
  }) {
    this.id = id;
    this.authId = authId;
    this.amount = amount;
    this.note = note;
    this.paidBy = paidBy;
    this.expClass = expClass;
    this.date = date;
  }

  double? get amount {
    return double.tryParse(amountController.text);
  }

  set amount(double? num) {
    this.amountController.text = (num == null || num == 0.0) ? '' : num.toString();
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
    // step#1 validate FormField that have predifined validate() method
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      print('EF21| Warn: some of form feilds are not valid;');
      return Result(false, 'some of form FormFeilds are not valid');
    }
    // step#1 validate custom fields that have no predifined validate() method
    if (paidBy == null) {
      return Result(false, 'paidBy is empty');
    }
    if (date == null) {
      return Result(false, 'date is empty');
    }
    if (expClass == null) {
      return Result(false, 'expClass is empty');
    }
    return Result(true);
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
      paidBy: ${paidBy?.titleEnglish}, 
      note: $note, date: $date, 
      expClass: $expClass, 
    ''';
  }
}
