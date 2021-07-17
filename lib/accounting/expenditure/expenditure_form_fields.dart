import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/accounts_tree.dart';
import 'package:shop/accounting/expenditure/payer_account_info.dart';
import 'package:shop/constants.dart';

import 'expenditure_tag.dart';

class ExpenditurFormFields {
  final formKey = GlobalKey<FormState>();
  final amountFocusNode = FocusNode();
  final noteFocusNode = FocusNode();
  final paidByFocusNode = FocusNode();
  final dateFocusNode = FocusNode();
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();

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
      // paidBy: PayerAccountInfo(
      //   cashDrawer.id,
      //   cashDrawer.titleEnglish,
      //   cashDrawer.titlePersian,
      //   cashDrawer.titleArabic,
      // ),
      note: 'nescafee and cup',
      date: DateTime.now(),
      expenditureTag: ExpenditureTag.HOSPITALITY,
    );
  }

  // void initValues(ExpenditureModel ?? expence) {
  //   id =
  // }

  @override
  String toString() {
    return '''ES10| ExpenditureFormFields: {
      id: $id,
      amoutn: $amount, 
      paidBy: $paidBy, 
      note: $note,
      expenditureTag: $expenditureTag, 
      date: $date, 
    ''';
  }
}
