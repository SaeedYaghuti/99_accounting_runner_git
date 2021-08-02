import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/accounting_logic/transaction_classification.dart';
import 'package:shop/accounting/accounting_logic/transaction_feed.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_feed.dart';
import 'package:shop/accounting/accounting_logic/voucher_number_model.dart';
import 'package:shop/accounting/expenditure/expenditure_screen_form.dart';
import 'package:shop/auth/auth_model_sql.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/auth/has_access.dart';
import 'package:shop/exceptions/DBException.dart';
import 'package:shop/exceptions/access_denied_exception.dart';
import 'package:shop/exceptions/curropted_input.dart';
import 'package:shop/exceptions/db_operation.dart';
import 'package:shop/exceptions/dirty_database.dart';
import 'package:shop/exceptions/lazy_saeid.dart';
import 'package:shop/exceptions/voucher_exception.dart';
import 'package:shop/exceptions/ValidationException.dart';
import 'package:shop/shared/result_status.dart';
import 'package:shop/shared/seconds_of_time.dart';

class VoucherModel {
  int? id;
  final int creatorId;
  final int voucherNumber;
  final DateTime date;
  final String note;
  List<TransactionModel?> transactions = [];

  VoucherModel({
    this.id,
    required this.creatorId,
    required this.voucherNumber,
    required this.date,
    this.note = '',
  });

  // secure
  static Future<List<VoucherModel?>> accountVouchers(
    String accountId,
    AuthProviderSQL authProvider,
  ) async {
    // print(
    //   'VCH_MDL | accountVouchers() 00| accountId: $accountId',
    // );
    // step#1 if client has read_own perm for accountId we fetch from db only own-vouchers
    // account
    AccountModel? account = await AccountModel.fetchAccountById(accountId);
    if (account == null) return [];
    var andVouchersOwn = '';

    if (authProvider.isPermitted(account.readAllTransactionPermission)) {
      // has complete access to read
      andVouchersOwn = '';
      // print(
      //   'VCH_MDL | accountVouchers() 01| auther has READ_ALL',
      // );
    } else if (authProvider.isPermitted(account.readOwnTransactionPermission)) {
      // has access to own
      // print(
      //   'VCH_MDL | accountVouchers() 02| auther has READ_OWN',
      // );
      andVouchersOwn = 'AND ${VoucherModel.column5CreatorId} = ${authProvider.authId!}';
    } else {
      // has no read perm
      // print(
      //   'VCH_MDL | accountVouchers() 03| auther has no permission of read',
      // );
      return [];
    }

    final query = '''
    SELECT 
      $column1Id,
      $column2VoucherNumber,
      $column3Date,
      $column4Note,
      $column5CreatorId
    FROM 
      $voucherTableName 
    INNER JOIN 
      ${TransactionModel.transactionTableName}
    ON ${TransactionModel.column3VoucherId} = $column1Id
    AND ${TransactionModel.column2AccountId} = ?
    $andVouchersOwn

    ''';
    var vouchersMap = await AccountingDB.runRawQuery(query, [accountId]);

    // convert map to voucherModel
    List<VoucherModel> accountVouchers = [];

    // fetch transaction for each voucher
    for (var voucherMap in vouchersMap) {
      var voucher = fromMapOfVoucher(voucherMap);
      await voucher._fetchMyTransactionsWAccountWClass();
      // step#2 => every voucher at least has 2 account; we must check client perm for other accounts
      Result hasAccess = hasCredAccessToVoucher(
        formDuty: FormDuty.READ,
        voucher: voucher,
        authProviderSQL: authProvider,
      );
      if (hasAccess.outcome) accountVouchers.add(voucher);
    }
    return accountVouchers;
  }

  // secure
  static Future<void> createVoucher(
    AuthProviderSQL authProvider,
    VoucherFeed voucherFeed,
    List<TransactionFeed> transactionFeeds,
    // int authId,
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

    // step1# validate authority for each account
    for (var tranFeed in transactionFeeds) {
      AccountModel? account = await AccountModel.fetchAccountById(tranFeed.accountId);
      if (account == null) {
        throw CurroptedInputException(
          'VCH_MDL | createVoucher() 01| account with id: ${tranFeed.accountId} in not availble',
        );
      }
      if (authProvider.isNotPermitted(account.createTransactionPermission)) {
        throw AccessDeniedException(
          'VCH_MDL | createVoucher() 02 | client do not have permission for ${account.createTransactionPermission}',
        );
      }
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
      creatorId: authProvider.authId!,
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
        tranClass: feed.tranClass,
      );
      try {
        await transaction.insertMeIntoDB();
        successTransactions.add(transaction);
      } catch (e) {
        print('VCH_MDL | createVoucher() 100 | @ catch error while insert Tran in db e: $e');
        // delete all transactions and voucher
        try {
          await voucher.deleteMeFromDB(authProvider);
          await VoucherNumberModel.numberNotConsumed(voucherNumber);
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
    // print('V_MG 19| voucher and all its transactions saved Successfully!');

    // TODO: remove me
    await voucher._fetchMyTransactionsJClass();
  }

  // secure
  static Future<void> updateVoucher(
    VoucherModel rVoucher,
    AuthProviderSQL authProvider,
  ) async {
    // step 1# validate amount
    if (!_validateTransactionModelsAmount(rVoucher.transactions)) {
      throw ValidationException(
        'V_MG 30| amount in transactionFeeds are not valid',
      );
    }
    if (rVoucher.id == null || rVoucher.voucherNumber == null) {
      throw CurroptedInputException('VM 31| rVoucher is not valid voucher!');
    }

    // step 1# check edit authority for rVoucher; take accountId from tran; fetch account and check validity
    Result hasAccessToRVoucher = await hasCredAccessToVoucherFuture(
      formDuty: FormDuty.EDIT,
      voucher: rVoucher,
      authProviderSQL: authProvider,
      helperAccounts: [],
    );

    if (hasAccessToRVoucher.outcome != null && !hasAccessToRVoucher.outcome) {
      throw AccessDeniedException(
        '${hasAccessToRVoucher.errorMessage} VCH_MDL | updateVoucher() 01| client do not have required perm for update $rVoucher',
      );
    }

    // step 2# fetch voucher by id (include trans and account)
    var fVoucher = await VoucherModel.fetchVoucherById(rVoucher.id!);

    // step 3# chack fVoucher validity
    if (fVoucher == null) {
      throw CurroptedInputException('VM 32| there is not voucher in db with id ${rVoucher.id}!');
    }
    if (fVoucher.voucherNumber != rVoucher.voucherNumber) {
      throw CurroptedInputException(
        'VM 33| there is not voucher in db with id:${rVoucher.id} and voucherNumber: ${rVoucher.voucherNumber}; voucherNumber could not be updated!',
      );
    }

    // step 2# check edit authority for fVoucher
    Result hasPermResult = hasCredAccessToVoucher(
      formDuty: FormDuty.EDIT,
      voucher: fVoucher,
      authProviderSQL: authProvider,
    );

    if (hasPermResult.outcome != null && !hasPermResult.outcome) {
      throw AccessDeniedException(
        '${hasPermResult.errorMessage} VCH_MDL | updateVoucher() 02| client do not have required perm for update $fVoucher',
      );
    }

    // print(
    //   'EXP_MDL 353| print all-transaction before updating voucherModel ',
    // );
    // await TransactionModel.allTransactions();

    // step #4 update voucher at db => it will delete all voucher-transaction
    try {
      await rVoucher._updateMeWithoutTransactionsInDB();

      // print(
      //   'EXP_MDL 354| print all-trans after updateing voucherModel',
      // );
      // await TransactionModel.allTransactions();
    } catch (e) {
      throw LazySaeidException(
        'VM UP39| rVoucher not updated successfuly; And Saeid did not handle this situation',
      );
    }

    // step 5# remove old transactions from db: we rebuild all transaction in update
    // it is redundent: because update-voucher will remove all voucher-transaction
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

    // step #6 recreate new transactions
    List<TransactionModel> successTransactions = [];

    // print(
    //   'EXP_MDL 351| all trans BEFORE adding new tran ',
    // );
    // await TransactionModel.allTransactions();

    for (var transaction in rVoucher.transactions) {
      try {
        var insertID = await transaction!.insertMeIntoDB();

        // var newTran = await TransactionModel.transactionById(insertID);
        // print(
        //   'EXP_MDL 350| updateVoucher step #6 |rebuild transaction | insertID: $insertID, transaction: $newTran',
        // );
        successTransactions.add(transaction);
      } catch (e) {
        print(
          'EXP_MDL 351| updateVoucher step #6 |@ catch | while rebuild transaction e: $e',
        );
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
  }

  Future<int> deleteMeFromDB(
    AuthProviderSQL authProvider,
  ) async {
    if (id == null) {
      return 0;
    }
    await this._fetchMyTransactionsWAccountWClass();

    // step 1# check edit authority for rVoucher
    // hasCredAccessToVoucher: voucher should contain trans and account
    Result hasAccessToDelete = hasCredAccessToVoucher(
      formDuty: FormDuty.DELETE,
      voucher: this,
      authProviderSQL: authProvider,
    );

    if (hasAccessToDelete.outcome != null && !hasAccessToDelete.outcome) {
      throw AccessDeniedException(
        '${hasAccessToDelete.errorMessage} VCH_MDL | updateVoucher() 01| client do not have required perm to delete $this',
      );
    }

    final query = '''
    DELETE FROM $voucherTableName
    WHERE $column1Id = $id ;
    ''';
    var count = await AccountingDB.deleteRawQuery(query);
    // print('VM 20| DELETE $id; count: $count');
    return count;
  }

  List<String?> myTransactionAccountIds() {
    return transactions.map((tran) {
      return tran?.accountId;
    }).toList();
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

  List<TransactionModel?> onlyTransactionsOf(String accountId) {
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

  Future<int> _insertMeInDB() async {
    // do some logic on variables
    // ...
    // step #1 do we have such creatorId in auth-db ?
    var existAuth = await AuthModel.existAuth(creatorId);

    if (!existAuth) {
      print(
        'VCH_MDL | _insertMeInDB() 01| creatorId: $creatorId dose not exist in AuthDB',
      );
      return 0;
    }
    var map = this._toMapForDB();
    // print('VCH_MDL | _insertMeInDB() 02| map to insert in db: $map');
    id = await AccountingDB.insert(voucherTableName, map);
    // print('VCH_MDL | _insertMeInDB() 03| insert id: $id');
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

  Future<void> _fetchMyTransactionsJClass() async {
    if (id == null) {
      print('VM 29| Warn: id is null: fetchMyTransactions()');
      return;
    }
    // TODO: fetch tranClass
    // ...

    final query = '''
      SELECT *
      FROM ${TransactionModel.transactionTableName}
      INNER JOIN 
        ${TransactionClassification.tableName}
      ON ${TransactionModel.column8TranClassId} = ${TransactionClassification.column1Id}
      AND ${TransactionModel.column3VoucherId} = ?
    ''';

    var result = await AccountingDB.runRawQuery(query, [id]);
    transactions = result.map((tranMap) => TransactionModel.fromMapOfTransactionJClassJFloat(tranMap)).toList();
  }

  Future<void> _fetchMyTransactionsWAccountWClass() async {
    if (id == null) {
      print('VM | _fetchMyTransactionsWithAccount() 01| Warn: id is null: fetchMyTransactions()');
      return;
    }
    final query = '''
    SELECT 
      *
    FROM 
      ${TransactionModel.transactionTableName} 
    INNER JOIN 
      ${AccountModel.tableName}
    ON ${TransactionModel.column2AccountId} = ${AccountModel.column1Id}
    AND ${TransactionModel.column3VoucherId} = ?

    INNER JOIN 
      ${TransactionClassification.tableName}
    ON ${TransactionModel.column8TranClassId} = ${TransactionClassification.column1Id}
    ''';

    var tranJAccJClassMaps = await AccountingDB.runRawQuery(query, [id]);
    // print('VCH_MDL | 02 _fetchMyTranWAccountWClass()| voucher_id:$id tranJAccJClassMaps: $tranJAccJClassMaps');
    transactions = tranJAccJClassMaps
        .map((tranJAccJClass) => TransactionModel.fromMapOfTransactionJAccountJClassJFloat(tranJAccJClass))
        .toList();
  }

  static Future<void> fetchAllVouchers() async {
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
      await voucher._fetchMyTransactionsJClass();
    }

    print('VM FAV 01| All DB Vouchers: ###########');
    print(voucherModels);
    print('##################');
  }

  // include trans and tran's account
  static Future<VoucherModel?> fetchVoucherById(int voucherId) async {
    final query = '''
    SELECT *
    FROM $voucherTableName
    WHERE $column1Id = ?
    ''';
    var vouchersMap = await AccountingDB.runRawQuery(query, [voucherId]);
    // convert map to voucherModel
    List<VoucherModel> voucherModels = [];
    vouchersMap.forEach(
      (vchMap) => voucherModels.add(fromMapOfVoucher(vchMap)),
    );

    if (voucherModels.isEmpty) {
      print('VCH_MDL | _fetchVoucherById($voucherId)| isEmpty');
      return null;
    }
    if (voucherModels.length > 1) {
      throw DirtyDatabaseException(
        'VCH_MDL | _fetchVoucherById($voucherId)| there are more than one voucher with same id',
      );
    }

    // fetch transaction for each voucher
    for (var voucher in voucherModels) {
      // await voucher._fetchMyTransactions();
      await voucher._fetchMyTransactionsWAccountWClass();
    }

    // print('VM 30| fetchVoucher for id: <$voucherId>: ###########');
    // print(voucherModels);
    // print('##################');

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

    var max = (result[0]['max'] == null) ? 0 : (result[0]['max'] as int);
    // var parse = int.tryParse(maxResult);
    // var max = (parse == null) ? 0 : parse;
    // print(max);
    return max;
  }

  static bool _validateTransactionFeedsAmount(List<TransactionFeed> feeds) {
    // TODO: an account could not be at the same time at debitTrans and creditTran

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

  static bool _validateTransactionModelsAmount(List<TransactionModel?> transactions) {
    // TODO: an account could not be at the same time at debitTrans and creditTran

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
  static const String column5CreatorId = 'vch_creator_id';

  // static const String column5Transactions = 'transactions';

  static const String QUERY_CREATE_VOUCHER_TABLE = '''CREATE TABLE $voucherTableName (
      $column1Id INTEGER PRIMARY KEY, 
      $column2VoucherNumber INTEGER NOT NULL, 
      $column3Date INTEGER  NOT NULL, 
      $column4Note TEXT,
      $column5CreatorId INTEGER NOT NULL
    )''';
  // because auth and voucher there are in seperate db we can not use FOREIGN KEY
  // CONSTRAINT fk_${AuthModel.authTableName} FOREIGN KEY ($column5CreatorId) REFERENCES
  // ${AuthModel.authTableName} (${AuthModel.column1Id}) ON DELETE NO ACTION

  Map<String, Object> _toMapForDB() {
    // print('VM 44| date: ${readibleDate(date)}');
    if (id == null) {
      return {
        column2VoucherNumber: voucherNumber,
        column3Date: seconsdOfDateTime(date),
        column4Note: note,
        column5CreatorId: creatorId,
      };
    } else {
      return {
        column1Id: id ?? '',
        column2VoucherNumber: voucherNumber,
        column3Date: seconsdOfDateTime(date),
        column4Note: note,
        column5CreatorId: creatorId,
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
      creatorId: voucherMap[VoucherModel.column5CreatorId] as int,
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
    voucherId: $id, creatorId: $creatorId , voucherNumber: $voucherNumber,
    voucherNote: $note, voucherDate: ${date.day}/${date.month}/${date.year},
    # transactions:
    $transactions,
    =================
    ''';
  }
}
