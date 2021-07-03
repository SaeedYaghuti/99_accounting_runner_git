import 'expenditure_tag.dart';

class ExpenditurFormFields {
  int? id;
  double? amount;
  String? paidBy;
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
    return ExpenditurFormFields(
      id: null,
      amount: 3.750,
      paidBy: 'cash-drawer',
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
