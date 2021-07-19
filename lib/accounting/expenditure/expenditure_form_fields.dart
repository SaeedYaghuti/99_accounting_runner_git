import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/accounts_tree.dart';
import 'package:shop/accounting/expenditure/payer_account_info.dart';
import 'package:shop/constants.dart';

import 'expenditure_form.dart';
import 'expenditure_tag.dart';

class ExpenditurFormFields {
  final formKey = GlobalKey<FormState>();
  final amountFocusNode = FocusNode();
  final noteFocusNode = FocusNode();
  final paidByFocusNode = FocusNode();
  final dateFocusNode = FocusNode();
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  // FormDuty formDuty = FormDuty.CREATE;

  int? id;
  AccountModel? paidBy;
  late ExpenditureTag expenditureTag;
  DateTime? date;

  ExpenditurFormFields({
    int? id,
    double? amount,
    AccountModel? paidBy,
    String? note,
    ExpenditureTag? expenditureTag,
    DateTime? date,
  }) {
    this.id = id;
    this.amount = amount;
    this.note = note;
    this.paidBy = paidBy;
    this.expenditureTag =
        (expenditureTag == null) ? ExpenditureTag.DEFAULT : expenditureTag;
    this.date = date;
  }

  double? get amount {
    return double.tryParse(amountController.text);
  }

  set amount(double? num) {
    this.amountController.text =
        (num == null || num == 0.0) ? '' : num.toString();
  }

  String? get note {
    return noteController.text;
  }

  set note(String? text) {
    this.noteController.text = text ?? '';
  }

  static ExpenditurFormFields get expenditureExample {
    AccountModel cashDrawer = ACCOUNTS_TREE.firstWhere(
      (acc) => acc.id == PAID_EXPENDITURE_BY,
    );
    return ExpenditurFormFields(
      id: null,
      amount: 3.750,
      paidBy: cashDrawer,
      note: 'nescafee and cup',
      date: DateTime.now(),
      expenditureTag: ExpenditureTag.HOSPITALITY,
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
      note: $note,
      expenditureTag: $expenditureTag, 
      date: $date, 
    ''';
  }
}
