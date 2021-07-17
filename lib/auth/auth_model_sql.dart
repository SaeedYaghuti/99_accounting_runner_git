import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shop/auth/auth_db_helper.dart';
import 'package:shop/auth/auth_permission_model.dart';
import 'package:shop/constants.dart';
import 'package:shop/exceptions/curropted_input.dart';
import 'package:shop/exceptions/dirty_database.dart';
import 'package:shop/exceptions/null_exception.dart';
import 'package:shop/exceptions/unique_constraint_exception.dart';
import 'package:shop/shared/result_status.dart';
import 'package:shop/shared/validation_result.dart';
import 'package:sqflite/sqflite.dart';

class AuthModel {
  int? _id;
  String? _username;
  String? _salt;
  String? _password;
  List<AuthPermissionModel?>? _permissions;

  AuthModel();

  int? get id {
    return _id;
  }

  bool hasPermission(String permissionId) {
    if (_permissions == null || _permissions!.length == 0) {
      return false;
    }
    // first auth has all permissions
    if (_id == 1) return true;

    return _permissions!.any(
      (permission) => permission!.permissionId == permissionId,
    );
  }

  // only for development; should be deleted
  static Future<void> printAllAuth() async {
    final query = '''
    SELECT *
    FROM $authTableName
    ''';
    var authesMap = await AuthDB.runRawQuery(query);

    print('ATH_MDL printAllAuth 01| All DB Authes: ###########');
    print(authesMap);
    print('##################');
  }

  Future<int> createNewUserInDB(String username, String password) async {
    // print('Auth cr_new_usr 01| username: $username, password: $password');

    // do validation on username
    // ..

    var salt = _createSalt();
    var hashedPassword = _hashPassword(password, salt);

    var map = _makeMapForDB(
      username,
      hashedPassword,
      salt,
    );

    try {
      _id = await AuthDB.insert(authTableName, map);
      _salt = salt;
      _password = hashedPassword;
      return _id!;
    } catch (e) {
      print('Auth cr_new_usr 05| catch e: $e');
      if (e.toString().contains('UNIQUE constraint failed'))
        throw UniqueConstraintException('username has taken!');
      throw e;
    }
  }

  Future<void> createFirstUserInDB(Database db) async {
    var salt = _createSalt();
    var hashedPassword = _hashPassword(SAEIDPASSWORD, salt);

    try {
      await db.execute('''
        INSERT INTO $authTableName ($column1Id, $column2Username, $column3Password, $column4Salt)
        VALUES (1, '$SAEIDEMAIL', '$hashedPassword', '$salt');
        ''');
      await db.close();
    } catch (e) {
      print('Auth cr_first_usr 01| catch e: $e');
      throw e;
    }
  }

  Future<ValidationResult> validateUser(
    String username,
    String password,
  ) async {
    // #1 do we have such a username
    var fetchStatus = await _fetchUserByUsernameAndSetAuth(username);
    if (!fetchStatus.isSuccessful)
      return ValidationResult(
        false,
        'ATH validateUser 01| There is no such a username: $username in db',
      );

    // #2 validate password
    var isValidPassword = _validatePassword(password);
    // print('Auth validateUser 02| isValidPassword: $isValidPassword');

    return ValidationResult(
      isValidPassword,
      'ATH vUser 03| password is incorrect',
    );
  }

  Future<ResultStatus> _fetchUserByIdAndSetAuth(int userId) async {
    final query = '''
    SELECT *
    FROM $authTableName
    WHERE $column1Id = ?
    ''';
    var authesMap = await AuthDB.runRawQuery(query, [userId]);

    if (authesMap.length == 0)
      return ResultStatus(
        false,
        'ATH fUserbyId 01 | There is no such userId: $userId in db',
      );

    if (authesMap.length > 1) {
      throw DirtyDatabaseException(
        'AUTH fuserByid 01| there is more than one row with id: $userId',
      );
    }

    _setVariablesFromMapOfAuth(authesMap.first);

    // fetch permissions
    _permissions = await AuthPermissionModel.allPermissionsForAuth(userId);
    return ResultStatus(true);
  }

  Future<ResultStatus> _fetchUserByUsernameAndSetAuth(String username) async {
    final query = '''
    SELECT *
    FROM $authTableName
    WHERE $column2Username = ?
    ''';
    var authesMap = await AuthDB.runRawQuery(query, [username]);

    if (authesMap.length == 0)
      return ResultStatus(
        false,
        'ATH fuserByUsername 01| There isn\'t any user with username: $username',
      );

    if (authesMap.length > 1)
      throw DirtyDatabaseException(
        'AUTH fuserByid 01| there is more than one row with username: $username',
      );

    // fetch permissions
    _setVariablesFromMapOfAuth(authesMap.first);
    _permissions = await AuthPermissionModel.allPermissionsForAuth(_id!);
    return ResultStatus(true);
  }

  String _createSalt([int length = 32]) {
    // print('_createSalt 01| running...');
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (index) => _random.nextInt(256));
    // print('_createSalt 02| values: $values');
    return base64Url.encode(values);
  }

  String _hashPassword(String password, String salt) {
    // print('Auth hash_pass 00| input password: $password, salt: $salt');
    var saltedPassword = salt + password + HASH_PASS;
    // print('Auth hash_pass 01| saltedPassword: $saltedPassword');

    var bytes = utf8.encode(saltedPassword);
    // print('Auth hash_pass 02| bytes: $bytes');

    var hashedPassword = sha256.convert(bytes);
    // print('Auth hash_pass 03| hashedPassword: $hashedPassword');

    return hashedPassword.toString();
  }

  bool _validatePassword(String password) {
    if (_salt == null || _password == null)
      throw NullException(
          'ATH _vPass 01 | _salt or _password is null but it shouldn\'t be null');
    var newHash = _hashPassword(password, _salt!).toString();
    return _password == newHash;
  }

  set salt(String salt) {
    _salt = salt;
  }

  // should be removed at the end
  // ...
  String get salt {
    return _salt ?? 'no-salt';
  }

  void _setVariablesFromMapOfAuth(
    Map<String, Object?> authMap,
  ) {
    // print('AUTH from_map_01| input authMap: $authMap');
    // print(authMap);

    _id = authMap[AuthModel.column1Id] as int;
    _username = authMap[AuthModel.column2Username] as String;
    _password = authMap[AuthModel.column3Password] as String;
    _salt = authMap[AuthModel.column4Salt] as String;

    // print('AUTH from_map_02| output this:\n${toString()}');
  }

  Map<String, Object> _makeMapForDB(
    String username,
    String password,
    String salt,
  ) {
    return {
      column2Username: username,
      column3Password: password,
      column4Salt: salt,
    };
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
