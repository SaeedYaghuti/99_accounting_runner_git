import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/accounting_logic/transaction_feed.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_feed.dart';
import 'package:shop/accounting/accounting_logic/voucher_number_model.dart';
import 'package:shop/exceptions/DBException.dart';
import 'package:shop/exceptions/curropted_input.dart';
import 'package:shop/exceptions/db_operation.dart';
import 'package:shop/exceptions/dirty_database.dart';
import 'package:shop/exceptions/lazy_saeid.dart';
import 'package:shop/exceptions/voucher_exception.dart';
import 'package:shop/shared/ValidationException.dart';
import 'package:shop/shared/readible_date.dart';
import 'package:shop/shared/seconds_of_time.dart';

class VoucherModel {
  int? id;
  final int voucherNumber;
  final DateTime date;
  final String note;
  List<TransactionModel?> transactions = [];
  // final int userId;

  VoucherModel({
    this.id,
    required this.voucherNumber,
    required this.date,
    this.note = '',
  });

  static Future<void> createVoucher(
    VoucherFeed voucherFeed,
    List<TransactionFeed> transactionFeeds,
    // String creatorId,
  ) async {
    // step 0# if creator hasAccess to create voucher
    // we should check transactionFeeds accountId
    // CATEGORY => EXP_CREATE,MoneyMov_CAT, Purch_CAT
    // ACCOUNTS =>

    // step 1# validate data
    if (!_validateTransactionFeedsAmount(transactionFeeds)) {
      throw ValidationException(
        'V_MG 00| amount in transactionFeeds are not valid',
      );
    }

    // step 2# borrow voucherNumber
    var voucherNumber;
    try {
      voucherNumber = await VoucherNumberModel.borrowNumber();
      // print('V_MG 03| voucherNumber: $voucherNumber');

    } catch (e) {
      print('V_MG 04| voucherNumber: $e');
      print('V_MG 04| we did VoucherNumberModel.reset() try again!');
      await VoucherNumberModel.reset();
      throw e;
    }

    // step 3# create voucher
    VoucherModel voucher = VoucherModel(
      voucherNumber: voucherNumber,
      date: voucherFeed.date,
      note: _makeVoucherNote(transactionFeeds),
    );
    // print('V_MG 07| voucher before save in db >');
    // print(voucher);

    try {
      await voucher._insertMeInDB();
    } catch (e) {
      await VoucherNumberModel.numberNotConsumed(voucherNumber);
      throw DBException(
        'V_MG 10| Unable to create voucher: e: ${e.toString()}',
      );
    }

    // step 4# create transactions
    List<TransactionModel> successTransactions = [];

    for (var feed in transactionFeeds) {
      var transaction = TransactionModel(
        accountId: feed.accountId,
        voucherId: voucher.id!,
        amount: feed.amount,
        isDebit: feed.isDebit,
        date: feed.date,
        note: feed.note,
      );
      try {
        await transaction.insertMeIntoDB();
        successTransactions.add(transaction);
      } catch (e) {
        // delete all transactions and voucher
        try {
          await voucher.deleteMeFromDB();
          for (var transaction in successTransactions) {
            await transaction.deleteMeFromDB();
          }
        } catch (e) {
          // we have dirty data in voucher or transactions
          // do log at error_log ...
          throw VoucherException(
            'V_MG 13| We have dirty data at voucher or transactions table',
          );
        }
        throw VoucherException(
          'V_MG 16| Voucher did not saved at db!  we do not have dirty data at db e: ${e.toString()}',
        );
      }
    }
    // step #5 voucher has mad Successfully
    await VoucherNumberModel.numberConsumed(voucherNumber);
    print('V_MG 19| voucher and all its transactions saved Successfully!');

    // TODO: remove me
    await voucher._fetchMyTransactions();
  }

  static Future<void> updateVoucher(VoucherModel rVoucher) async {
    // step 1# validate amount
    if (!_validateTransactionModelsAmount(rVoucher.transactions)) {
      throw ValidationException(
        'V_MG 30| amount in transactionFeeds are not valid',
      );
    }
    if (rVoucher.id == null || rVoucher.voucherNumber == null) {
      throw CurroptedInputException('VM 31| rVoucher is not valid voucher!');
    }

    // step 2# fetch voucher by id
    var fVoucher = await VoucherModel._fetchVoucherById(rVoucher.id!);

    // step 3# chack validity
    if (fVoucher == null) {
      throw CurroptedInputException(
          'VM 32| there is not voucher in db with id ${rVoucher.id}!');
    }
    if (fVoucher.voucherNumber != rVoucher.voucherNumber) {
      throw CurroptedInputException(
        'VM 33| there is not voucher in db with id:${rVoucher.id} and voucherNumber: ${rVoucher.voucherNumber}; voucherNumber could not be updated!',
      );
    }

    // step 4# remove old transactions from db: we rebuild all transaction in update
    List<TransactionModel> successfullDeleted = [];

    for (var tran in fVoucher.transactions) {
      if (tran == null) break;
      try {
        await tran.deleteMeFromDB();
        successfullDeleted.add(tran);
      } catch (e) {
        // if couldn't delete any tran we should recreate deleted tran
        try {
          for (var transaction in successfullDeleted) {
            if (transaction == null) break;
            await tran.insertMeIntoDB();
          }
          throw DBOperationException(
            'VM 35| unsuccessful update vouchr: ${fVoucher.id}! there is no dirty data in db',
          );
        } catch (e) {
          // do log
          // ...
          throw DirtyDatabaseException(
            'VM 34| There is Dirty transaction in vouchr: ${fVoucher.id}',
          );
        }
      }
    }

    // step #5 recreate new transactions
    List<TransactionModel> successTransactions = [];

    for (var transaction in rVoucher.transactions) {
      try {
        await transaction!.insertMeIntoDB();
        successTransactions.add(transaction);
      } catch (e) {
        // unable to build all new transactions:
        try {
          // step #a delete successTransactions
          for (var transaction in successTransactions) {
            await transaction.deleteMeFromDB();
          }
          // step #b recreate old transactions
          for (var transaction in fVoucher.transactions) {
            await transaction!.insertMeIntoDB();
          }

          // strp #c notify update problem; without dirty data
          throw DBOperationException(
            'VM 36| unsuccessful update vouchr: ${fVoucher.id}! there is no dirty data in db',
          );
        } catch (e) {
          // we have dirty data in voucher or transactions
          // do log at error_log ...
          throw DirtyDatabaseException(
            'V_MG 35| We have dirty data at voucher ${rVoucher.id}',
          );
        }
      }
    }

    // step #6 update voucher at db
    try {
      await rVoucher._updateMeWithoutTransactionsInDB();
    } catch (e) {
      throw LazySaeidException(
        'VM UP39| rVoucher not updated successfuly; And Saeid did not handle this situation',
      );
    }
  }

  Future<int> deleteMeFromDB() async {
    if (id == null) {
      return 0;
    }

    final query = '''
    DELETE FROM $voucherTableName
    WHERE $column1Id = $id ;
    ''';
    var count = await AccountingDB.deleteRawQuery(query);
    // print('VM 20| DELETE $id; count: $count');
    return count;
  }

  List<TransactionModel?> debitTransactions() {
    return transactions.where((tran) {
      if (tran == null) {
        return false;
      }
      return tran.isDebit;
    }).toList();
  }

  List<TransactionModel?> creditTransactions() {
    return transactions.where((tran) {
      if (tran == null) {
        return false;
      }
      return !tran.isDebit;
    }).toList();
  }

  List<TransactionModel?> accountTransactions(String accountId) {
    return transactions.where((tran) {
      if (tran == null) {
        return false;
      }
      return tran.accountId == accountId;
    }).toList();
  }

  String paidByText() {
    var debitIds = [];
    debitTransactions().forEach((tran) {
      debitIds.add(tran?.accountId);
    });
    return debitIds.join(', ');
  }

  static Future<List<VoucherModel>> accountVouchers(
    String accountId,
  ) async {
    final query = '''
    SELECT 
      $column1Id,
      $column2VoucherNumber,
      $column3Date,
      $column4Note
    FROM 
      $voucherTableName 
    LEFT JOIN 
      ${TransactionModel.transactionTableName}
    ON ${TransactionModel.column3VoucherId} = $column1Id
    AND ${TransactionModel.column2AccountId} = ?
    ''';
    var vouchersMap = await AccountingDB.runRawQuery(query, [accountId]);

    // convert map to voucherModel
    List<VoucherModel> voucherModels = [];
    vouchersMap.forEach(
      (vchMap) => voucherModels.add(fromMapOfVoucher(vchMap)),
    );

    // fetch transaction for each voucher
    for (var voucher in voucherModels) {
      await voucher._fetchMyTransactions();
    }

    // print(
    //     'VM aV 01| accountVouchers for account: $accountId: ##################');
    // print(voucherModels);
    // print('##################');
    return voucherModels;
  }

  Future<int> _insertMeInDB() async {
    // do some logic on variables
    // ...
    var map = this._toMapForDB();
    // print('VM10| map: $map');
    id = await AccountingDB.insert(voucherTableName, map);
    // print('VM10| insertMeInDB() id: $id');
    return id!;
  }

  Future<int> _updateMeWithoutTransactionsInDB() async {
    // do some logic on variables
    // ...
    var map = this._toMapForDB();
    // print('VM10| map: $map');
    id = await AccountingDB.update(voucherTableName, map);
    // print('VM10| insertMeInDB() id: $id');
    return id!;
  }

  Future<void> _fetchMyTransactions() async {
    if (id == null) {
      print('VM 29| Warn: id is null: fetchMyTransactions()');
      return;
    }

    final query = '''
      SELECT *
      FROM ${TransactionModel.transactionTableName}
      WHERE ${TransactionModel.column3VoucherId} = $id
    ''';
    var result = await AccountingDB.runRawQuery(query);
    transactions = result
        .map(
          (tranMap) => TransactionModel.fromMapOfTransaction(tranMap),
        )
        .toList();
  }

  static Future<void> _fetchAllVouchers() async {
    final query = '''
    SELECT *
    FROM $voucherTableName
    ''';
    var vouchersMap = await AccountingDB.runRawQuery(query);
    // convert map to voucherModel
    List<VoucherModel> voucherModels = [];
    vouchersMap.forEach(
      (vchMap) => voucherModels.add(fromMapOfVoucher(vchMap)),
    );

    // fetch transaction for each voucher
    for (var voucher in voucherModels) {
      await voucher._fetchMyTransactions();
    }

    print('VM FAV 01| All DB Vouchers: ###########');
    print(voucherModels);
    print('##################');
  }

  static Future<VoucherModel?> _fetchVoucherById(int voucherId) async {
    final query = '''
    SELECT *
    FROM $voucherTableName
    WHERE $column1Id = $voucherId
    ''';
    var vouchersMap = await AccountingDB.runRawQuery(query);
    // convert map to voucherModel
    List<VoucherModel> voucherModels = [];
    vouchersMap.forEach(
      (vchMap) => voucherModels.add(fromMapOfVoucher(vchMap)),
    );

    if (voucherModels.isEmpty) {
      return null;
    }
    // if (voucherModels.length > 1) {
    //   throw
    // }

    // fetch transaction for each voucher
    for (var voucher in voucherModels) {
      await voucher._fetchMyTransactions();
    }

    print('VM 30| fetchVoucher for id: <$voucherId>: ###########');
    print(voucherModels);
    print('##################');

    return voucherModels[0];
  }

  static Future<int> maxVoucherNumber() async {
    final query = '''
    SELECT MAX($column2VoucherNumber) as max
    FROM $voucherTableName
    ''';
    var result = await AccountingDB.runRawQuery(query);
    // print('VM 21| SELECT MAX FROM $voucherTableName >');
    // print(result);

    var maxResult =
        (result[0]['max'] == null) ? '0' : (result[0]['max'] as String);
    var parse = int.tryParse(maxResult);
    var max = (parse == null) ? 0 : parse;
    // print(max);
    return max;
  }

  static Future<void> _fetchAllVouchersJoin() async {
    final query = '''
    SELECT *
    FROM $voucherTableName
    LEFT JOIN ${TransactionModel.transactionTableName}
    ON $voucherTableName.$column1Id = ${TransactionModel.transactionTableName}.${TransactionModel.column3VoucherId}
    ''';
    var result = await AccountingDB.runRawQuery(query);
    print('VM11| $voucherTableName JOIN result >');
    print(result);
  }

  // json_object only work if json1 extension installed
  static Future<void> xVouchersOfAccountIncludeTransactions(
    String accountId,
  ) async {
    final query = '''
      SELECT 
        json_object('voucher_id', ${TransactionModel.column3VoucherId})
      FROM ${TransactionModel.transactionTableName}
      -- WHERE ${TransactionModel.column2AccountId} = ?
      GROUP BY ${TransactionModel.column3VoucherId}
    ''';
    var result = await AccountingDB.runRawQuery(query /*, [accountId] */);
    print('VM 30| vouchersOfAccountIncludeTransactions() result >');
    print(result);
  }

  static bool _validateTransactionFeedsAmount(List<TransactionFeed> feeds) {
    var totalDebit = 0.0;
    var totalCredit = 0.0;

    for (var feed in feeds) {
      // maybe redundent
      if (feed.amount < 0.0) {
        return false;
      }
      // maybe redundent
      if (feed.amount == 0.0) {
        return false;
      }
      if (feed.isDebit) {
        totalDebit += feed.amount;
      } else {
        totalCredit += feed.amount;
      }
    }
    if (totalDebit == totalCredit) {
      return true;
    } else {
      print(
        'VMG10| totalDebit: $totalDebit and totalCredit: $totalCredit are not equal',
      );
      return false;
    }
  }

  static bool _validateTransactionModelsAmount(
      List<TransactionModel?> transactions) {
    var totalDebit = 0.0;
    var totalCredit = 0.0;

    // at least we should have 2 transactions
    if (transactions.length < 2) return false;

    for (var tran in transactions) {
      if (tran == null) return false;
      // maybe redundent
      if (tran.amount < 0.0) {
        return false;
      }
      // maybe redundent
      if (tran.amount == 0.0) {
        return false;
      }
      if (tran.isDebit) {
        totalDebit += tran.amount;
      } else {
        totalCredit += tran.amount;
      }
    }
    if (totalDebit == totalCredit) {
      return true;
    } else {
      print(
        'VMG10| totalDebit: $totalDebit and totalCredit: $totalCredit are not equal',
      );
      return false;
    }
  }

  static String _makeVoucherNote(List<TransactionFeed> feeds) {
    List<String> debitNote = [];
    List<String> creditNote = [];

    for (var feed in feeds) {
      if (feed.isDebit) {
        debitNote.add(feed.accountId);
      } else {
        creditNote.add(feed.accountId);
      }
    }

    String note = debitNote.join(', ') + ' paid for ' + creditNote.join(', ');
    return note;
  }

  static const String voucherTableName = 'vouchers';
  static const String column1Id = 'vch_id';
  static const String column2VoucherNumber = 'voucherNumber';
  static const String column3Date = 'vch_date';
  static const String column4Note = 'vch_note';
  // static const String column5Transactions = 'transactions';

  static const String QUERY_CREATE_VOUCHER_TABLE =
      '''CREATE TABLE $voucherTableName (
      $column1Id INTEGER PRIMARY KEY, 
      $column2VoucherNumber INTEGER NOT NULL, 
      $column3Date INTEGER  NOT NULL, 
      $column4Note TEXT
    )''';

  Map<String, Object> _toMapForDB() {
    print('VM 44| date: ${readibleDate(date)}');
    if (id == null) {
      return {
        column2VoucherNumber: voucherNumber,
        // column3Date: date.toUtc().millisecondsSinceEpoch,
        // column3Date: date.millisecondsSinceEpoch,
        column3Date: seconsdOfDateTime(date),
        column4Note: note,
      };
    } else {
      return {
        column1Id: id ?? '',
        column2VoucherNumber: voucherNumber,
        column3Date: seconsdOfDateTime(date),
        column4Note: note,
      };
    }
  }

  static VoucherModel fromMapOfVoucher(
    Map<String, Object?> voucherMap,
  ) {
    // print('VM 20| @ fromMapOfVoucher(); before conversion');
    // print(voucherMap);

    var voucher = VoucherModel(
      id: voucherMap[VoucherModel.column1Id] as int,
      voucherNumber: voucherMap[VoucherModel.column2VoucherNumber] as int,
      date: secondsToDateTime(
        voucherMap[VoucherModel.column3Date] as int,
      ),
      note: voucherMap[VoucherModel.column4Note] as String,
    );
    // print('VM 21| @ fromMapOfVoucher(); after conversion');
    // print(voucher);

    return voucher;
  }

  String toString() {
    return '''
    voucherId: $id, voucherNumber: $voucherNumber,
    voucherNote: $note, voucherDate: ${date.day}/${date.month}/${date.year},
    transactions: ++++
    $transactions,
    =================
    ''';
  }
}
