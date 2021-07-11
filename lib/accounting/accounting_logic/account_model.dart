import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/accounting_db.dart';

class AccountModel {
  final String id;
  final String parentId;
  final String titleEnglish;
  final String titlePersian;
  final String titleArabic;
  final String note;
  final List<String?>? createTransactionPermissionsAny;
  final List<String?>? readTransactionPermissionsAny;
  final List<String?>? editTransactionPermissionsAny;
  final List<String?>? deleteTransactionPermissionsAny;

  const AccountModel({
    required this.id,
    required this.parentId,
    required this.titleEnglish,
    required this.titlePersian,
    required this.titleArabic,
    this.note = '',
    this.createTransactionPermissionsAny,
    this.readTransactionPermissionsAny,
    this.editTransactionPermissionsAny,
    this.deleteTransactionPermissionsAny,
  });

  // TODO: currently we read accounts from AccountTree => we should read from DB

  Future<int> insertMeIntoDB() async {
    // do some logic on variables

    // TODO: we should create relevant permission for this new acc in db
    // TODO: give all this perms to auth_id: 1

    try {
      return AccountingDB.insert(tableName, toMap());
    } catch (e) {
      print('AccountModel insertInDB() 01| error:$e');
      throw e;
    }
  }

  static Future<List<AccountModel?>?> allAccounts() async {
    final query = '''
    SELECT *
    FROM $tableName
    ''';
    List<AccountModel?> accounts = [];

    try {
      var result = await AccountingDB.runRawQuery(query);
      // print('AccountModel allAccounts 01| all accounts: ########');
      // print(result);
      // print('##################');

      if (result == null || result.isEmpty) return null;
      result.forEach(
        (accMap) => accounts.add(fromMap(accMap)),
      );
      print('AccountModel allAccounts 03| fetched Accounts:');
      print('accounts count: ${accounts.length}');
      // print(accounts);
      return accounts;
    } on Exception catch (e) {
      print('AccountModel allAccounts 02| @ catch wile fromMap e: $e');
    }
  }

  static Future<AccountModel?> fetchAccountById(String accountId) async {
    final query = '''
    SELECT *
    FROM $tableName
    WHERE $column1Id = ? ;
    ''';
    try {
      var fetchResult = await AccountingDB.runRawQuery(
        query,
        [accountId],
      );
      // print(
      //   'AccountModel fetchAccountById 01| fetchResult for accountId: $accountId',
      // );
      // print(fetchResult);

      // before list.first always you should check isEmpty
      if (fetchResult == null || fetchResult.isEmpty) return null;

      AccountModel? account = fromMap(fetchResult.first);
      print(account);
      return account;
      // return fetchResult;
    } catch (e) {
      print('ACC_MDL fetchAccountById() 01| e: $e');
      throw e;
    }
  }

  Future<int> deleteMeFromDB() async {
    if (id == null) {
      return 0;
    }
    final query = '''
    DELETE FROM $tableName
    WHERE $column1Id = ? ;
    ''';
    try {
      var count = await AccountingDB.deleteRawQuery(query, [id]);
      print('AccountModel deleteMeFromDB 01| DELETE $id; count: $count');
      return count;
    } catch (e) {
      print('AccountModel deleteMeFromDB 01| e: $e');
      throw e;
    }
  }

  static const String tableName = 'accounts';
  static const String column1Id = 'id';
  static const String column2ParentId = 'parentId';
  static const String column3TitleEnglish = 'titleEnglish';
  static const String column4TitlePersian = 'titlePersian';
  static const String column5TitleArabic = 'titleArabic';
  static const String column6Note = 'note';
  static const String column7CreateTransactionPermissionsAny =
      'createTransactionPermissionsAny';
  static const String column8ReadTransactionPermissionsAny =
      'readTransactionPermissionsAny';
  static const String column9EditTransactionPermissionsAny =
      'editTransactionPermissionsAny';
  static const String column10DeleteTransactionPermissionsAny =
      'deleteTransactionPermissionsAny';

  static const String QUERY_CREATE_ACCOUNT_TABLE = '''CREATE TABLE $tableName (
    $column1Id TEXT PRIMARY KEY, 
    $column2ParentId TEXT NOT NULL, 
    $column3TitleEnglish TEXT NOT NULL, 
    $column4TitlePersian TEXT NOT NULL, 
    $column5TitleArabic TEXT NOT NULL, 
    $column6Note TEXT,
    $column7CreateTransactionPermissionsAny Text,
    $column8ReadTransactionPermissionsAny Text,
    $column9EditTransactionPermissionsAny Text,
    $column10DeleteTransactionPermissionsAny Text,
    FOREIGN KEY ($column2ParentId) REFERENCES $tableName ($column1Id)
  )''';

  Map<String, Object> toMap() {
    return {
      column1Id: id,
      column2ParentId: parentId,
      column3TitleEnglish: titleEnglish,
      column4TitlePersian: titlePersian,
      column5TitleArabic: titleArabic,
      column6Note: note,
      column7CreateTransactionPermissionsAny:
          json.encode(createTransactionPermissionsAny),
      column8ReadTransactionPermissionsAny:
          json.encode(readTransactionPermissionsAny),
      column9EditTransactionPermissionsAny:
          json.encode(editTransactionPermissionsAny),
      column10DeleteTransactionPermissionsAny:
          json.encode(deleteTransactionPermissionsAny),
    };
  }

  static AccountModel? fromMap(
    Map<String, Object?>? accountMap,
  ) {
    if (accountMap == null) {
      print('AccountModel fromMap 01| input is null');
      return null;
    }
    var account = AccountModel(
      id: accountMap[AccountModel.column1Id] as String,
      parentId: accountMap[AccountModel.column2ParentId] as String,
      titleEnglish: accountMap[AccountModel.column3TitleEnglish] as String,
      titlePersian: accountMap[AccountModel.column4TitlePersian] as String,
      titleArabic: accountMap[AccountModel.column5TitleArabic] as String,
      note: accountMap[AccountModel.column6Note] as String,
      createTransactionPermissionsAny: json
          .decode(
            accountMap[AccountModel.column7CreateTransactionPermissionsAny]
                as String,
          )
          .cast<String>(),
      readTransactionPermissionsAny: json
          .decode(
            accountMap[AccountModel.column8ReadTransactionPermissionsAny]
                as String,
          )
          .cast<String>(),
      editTransactionPermissionsAny: json
          .decode(
            accountMap[AccountModel.column9EditTransactionPermissionsAny]
                as String,
          )
          .cast<String>(),
      deleteTransactionPermissionsAny: json
          .decode(
            accountMap[AccountModel.column10DeleteTransactionPermissionsAny]
                as String,
          )
          .cast<String>(),
    );
    // print('AccountModel fromMap 03| output: \n$account');
    return account;
  }

  String toString() {
    return '''
    $column1Id: $id, 
    $column2ParentId: $parentId,
    $column3TitleEnglish: $titleEnglish,
    $column4TitlePersian: $titlePersian,
    $column5TitleArabic: $titleArabic,
    $column6Note: $note,
    $column7CreateTransactionPermissionsAny: $createTransactionPermissionsAny,
    $column8ReadTransactionPermissionsAny: $readTransactionPermissionsAny,
    $column9EditTransactionPermissionsAny: $editTransactionPermissionsAny,
    $column10DeleteTransactionPermissionsAny: $deleteTransactionPermissionsAny,
    ''';
  }
}
