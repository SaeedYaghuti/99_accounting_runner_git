import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/expenditure/expenditure_form_fields.dart';
import 'package:shop/shared/DBException.dart';

class ExpenditureModel {
  static const EXPENDITURE_ACCOUNT_ID = 'expenditure';

  static Future<void> createExpenditureInDB(ExpenditurFormFields fields) async {
    // DO: we should track voucher number in db; increasig
  }
}
