import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/accounts_tree.dart';
import 'package:shop/constants.dart';

import 'expenditure_tag.dart';

class ExpenditurFormFields {
  int? id;
  double? amount;
  AccountModel? paidBy;
  String? note;
  ExpenditureTag expenditureTag;
  DateTime? date;

  ExpenditurFormFields({
    this.id,
    this.amount,
    this.paidBy,
    this.note,
    this.expenditureTag = ExpenditureTag.DEFAULT,
    this.date,
  });

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
