import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';

Map<String, Object?> voucherTransactionJoinMap = {
  VoucherModel.column1Id: 0,
  VoucherModel.column2VoucherNumber: 0,
  VoucherModel.column3Date: 0,
  VoucherModel.column4Note: 'vch_note',
  TransactionModel.column1Id: 'tran_id',
  TransactionModel.column2AccountId: 'tran_accountId',
  TransactionModel.column3VoucherId: 'tran_voucherId',
  TransactionModel.column4Amount: 'tran_amount',
  TransactionModel.column5IsDebit: 'isDebit',
  TransactionModel.column6Date: 'tran_date',
  TransactionModel.column7Note: 'tran_note',
};
