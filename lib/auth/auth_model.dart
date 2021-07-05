import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/auth/auth_db.dart';
import 'package:shop/constants.dart';
import 'package:shop/exceptions/curropted_input.dart';
import 'package:shop/exceptions/dirty_database.dart';
import 'package:shop/exceptions/unique_constraint_exception.dart';

class AuthModel {
  int? _id;
  String? _username;
  String? _salt;
  String? _password;

  AuthModel();

  Future<void> createNewUserInDB(String username, String password) async {
    // print('Auth cr_new_usr 01| username: $username, password: $password');
    _username = username;
    _salt = _createSalt();
    _password = _hashPassword(password, _salt!);

    var map = _toMapForDB();
    // print('Auth cr_new_usr 02| for db prepared map: $map');
    try {
      _id = await AuthDB.insert(authTableName, map);
      // print('Auth cr_new_usr 03| generated_id _id: $_id');

    } catch (e) {
      print('Auth cr_new_usr 05| catch e: $e');
      if (e.toString().contains('UNIQUE constraint failed'))
        throw UniqueConstraintException('username has taken!');
      throw e;
    }
  }

  Future<AuthModel?> fetchUserById(int userId) async {
    final query = '''
    SELECT *
    FROM $authTableName
    WHERE $column1Id = $userId
    ''';
    var authesMap = await AuthDB.runRawQuery(query);

    if (authesMap.length == 0) {
      return null;
    }
    if (authesMap.length > 1) {
      throw DirtyDatabaseException(
        'AUTH fuserByid 01| there is more than one row with id: $userId',
      );
    }

    _fromMapOfAuth(authesMap.first);
  }

  void validateUser(String password) {
    var salt = _createSalt(); // should take from db
    var pass1 = _hashPassword(password, salt);

    var result = _validatePassword(password, salt, pass1.toString());
    print('Auth validateUser 01| result: $result');
  }

  String _createSalt([int length = 32]) {
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (index) => _random.nextInt(256));
    return base64Url.encode(values);
  }

  String _hashPassword(String password, String salt) {
    var saltedPassword = salt + password + HASH_PASS;
    // print('Auth hash_pass 01| saltedPassword: $saltedPassword');

    var bytes = utf8.encode(saltedPassword);
    // print('Auth hash_pass 02| bytes: $bytes');

    var hashedPassword = sha256.convert(bytes);
    // print('Auth hash_pass 03| hashedPassword: $hashedPassword');

    return hashedPassword.toString();
  }

  bool _validatePassword(String password, String salt, String hashedPassword) {
    var newHash = _hashPassword(password, salt);
    return newHash.toString() == hashedPassword;
  }

  set salt(String salt) {
    _salt = salt;
  }

  // should be removed at the end
  // ...
  String get salt {
    return _salt ?? 'no-salt';
  }

  void _fromMapOfAuth(
    Map<String, Object?> authMap,
  ) {
    print('AUTH from_map_01| input authMap: $authMap');
    print(authMap);

    _id = authMap[AuthModel.column1Id] as int;
    _username = authMap[AuthModel.column2Username] as String;
    _password = authMap[AuthModel.column3Password] as String;
    _salt = authMap[AuthModel.column4Salt] as String;

    print('AUTH from_map_02| output this:\n${toString()}');
  }

  Map<String, Object> _toMapForDB() {
    if (_id == null && _salt != null) {
      return {
        column2Username: _username!,
        column3Password: _password!,
        column4Salt: _salt!,
      };
    }
    if (_id != null && _salt != null) {
      return {
        column1Id: _id!,
        column2Username: _username!,
        column3Password: _password!,
        column4Salt: _salt!,
      };
    }
    throw CurroptedInputException(
      'AUTH to_map_02| we have id but _salt is null',
    );
  }

  String toString() {
    return '''
    id: $_id, username: $_username, 
    salt: $_salt
    password: $_password,
    =================
    ''';
  }

  static const String authTableName = 'auth';
  static const String column1Id = 'auth_id';
  static const String column2Username = 'username';
  static const String column3Password = 'password';
  static const String column4Salt = 'salt';

  static const String QUERY_CREATE_AUTH_TABLE = '''CREATE TABLE $authTableName (
    $column1Id INTEGER PRIMARY KEY, 
    $column2Username TEXT NOT NULL UNIQUE, 
    $column3Password TEXT NOT NULL, 
    $column4Salt TEXT NOT NULL
  )''';

/*

  Future<int> updateMeWithoutTransactionsInDB() async {
    // do some logic on variables
    // ...
    var map = this.toMapForDB();
    // print('VM10| map: $map');
    id = await AccountingDB.update(voucherTableName, map);
    // print('VM10| insertMeInDB() id: $id');
    return id!;
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

  Future<void> fetchMyTransactions() async {
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

  static Future<void> fetchAllVouchers() async {
    final query = '''
    SELECT *
    FROM $voucherTableName
    ''';
    var vouchersMap = await AccountingDB.runRawQuery(query);
    // convert map to AuthModel
    List<AuthModel> AuthModels = [];
    vouchersMap.forEach(
      (vchMap) => AuthModels.add(fromMapOfVoucher(vchMap)),
    );

    // fetch transaction for each voucher
    for (var voucher in AuthModels) {
      await voucher.fetchMyTransactions();
    }

    print('VM FAV 01| All DB Vouchers: ###########');
    print(AuthModels);
    print('##################');
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

  static Future<void> fetchAllVouchersJoin() async {
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

  static Future<List<AuthModel>> accountVouchers(
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

    // convert map to AuthModel
    List<AuthModel> AuthModels = [];
    vouchersMap.forEach(
      (vchMap) => AuthModels.add(fromMapOfVoucher(vchMap)),
    );

    // fetch transaction for each voucher
    for (var voucher in AuthModels) {
      await voucher.fetchMyTransactions();
    }

    print(
        'VM aV 01| accountVouchers for account: $accountId: ##################');
    print(AuthModels);
    print('##################');
    return AuthModels;
  }
*/
}
