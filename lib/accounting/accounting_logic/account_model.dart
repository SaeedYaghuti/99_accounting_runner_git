import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/auth/auth_permission_model.dart';
import 'package:shop/auth/permission_model.dart';
import 'package:shop/shared/cast.dart';

class AccountModel {
  final String id;
  final String parentId;
  final String titleEnglish;
  final String titlePersian;
  final String titleArabic;
  final String note;
  final String? createTransactionPermission;
  final String? readAllTransactionPermission;
  final String? readOwnTransactionPermission;
  final String? editAllTransactionPermission;
  final String? editOwnTransactionPermission;
  final String? deleteAllTransactionPermission;
  final String? deleteOwnTransactionPermission;

  const AccountModel({
    required this.id,
    required this.parentId,
    required this.titleEnglish,
    required this.titlePersian,
    required this.titleArabic,
    this.note = '',
    this.createTransactionPermission,
    this.readAllTransactionPermission,
    this.readOwnTransactionPermission,
    this.editAllTransactionPermission,
    this.editOwnTransactionPermission,
    this.deleteAllTransactionPermission,
    this.deleteOwnTransactionPermission,
  });

  Future<int> insertMeIntoDB() async {
    // do some logic on variables
    try {
      // auto-generated permissons for account
      var permissionIds =
          await PermissionModel.createCRUDTransactionPermissionForAccount(
        id,
        titleEnglish,
        titlePersian,
        titleArabic,
      );

      // give new perms to auth-id = 1
      await AuthPermissionModel.givePermissionsToAuth(1, permissionIds);

      return AccountingDB.insert(tableName, toMap());
    } catch (e) {
      print('AccountModel insertInDB() 01| error:$e');
      throw e;
    }
  }

  static Future<List<AccountModel?>?> allAccounts() async {
    // TODO: access control

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
      // print('AccountModel allAccounts 03| fetched Accounts:');
      // print('accounts count: ${accounts.length}');
      // print(accounts);
      return accounts;
    } on Exception catch (e) {
      print('AccountModel allAccounts 02| @ catch wile fromMap e: $e');
    }
  }

  static Future<AccountModel?> fetchAccountById(String accountId) async {
    // print('ACC_MDL fetchAccountById() 01| accountId: <$accountId>');
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
      // print(account);
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
  static const String column1Id = 'acc_id';
  static const String column2ParentId = 'acc_parentId';
  static const String column3TitleEnglish = 'acc_titleEnglish';
  static const String column4TitlePersian = 'acc_titlePersian';
  static const String column5TitleArabic = 'acc_titleArabic';
  static const String column6Note = 'acc_note';
  static const String column7CreateTransactionPermission =
      'acc_createTransactionPermission';
  static const String column8ReadAllTransactionPermission =
      'acc_readAllTransactionPermission';
  static const String column9ReadOwnTransactionPermission =
      'acc_readOwnTransactionPermission';
  static const String column10EditAllTransactionPermission =
      'acc_editAllTransactionPermission';
  static const String column11EditOwnTransactionPermission =
      'acc_editOwnTransactionPermission';
  static const String column12DeleteAllTransactionPermission =
      'acc_deleteAllTransactionPermission';
  static const String column13DeleteOwnTransactionPermission =
      'acc_deleteOwnTransactionPermission';

  static const String QUERY_CREATE_ACCOUNT_TABLE = '''CREATE TABLE $tableName (
    $column1Id TEXT PRIMARY KEY, 
    $column2ParentId TEXT NOT NULL, 
    $column3TitleEnglish TEXT NOT NULL, 
    $column4TitlePersian TEXT NOT NULL, 
    $column5TitleArabic TEXT NOT NULL, 
    $column6Note TEXT,
    $column7CreateTransactionPermission Text,
    $column8ReadAllTransactionPermission Text,
    $column9ReadOwnTransactionPermission Text,
    $column10EditAllTransactionPermission Text,
    $column11EditOwnTransactionPermission Text,
    $column12DeleteAllTransactionPermission Text,
    $column13DeleteOwnTransactionPermission Text,
    FOREIGN KEY ($column2ParentId) REFERENCES $tableName ($column1Id)
  )''';

  Map<String, Object?> toMap() {
    return {
      column1Id: id,
      column2ParentId: parentId,
      column3TitleEnglish: titleEnglish,
      column4TitlePersian: titlePersian,
      column5TitleArabic: titleArabic,
      column6Note: note,
      column7CreateTransactionPermission: createTransactionPermission,
      column8ReadAllTransactionPermission: readAllTransactionPermission,
      column9ReadOwnTransactionPermission: readOwnTransactionPermission,
      column10EditAllTransactionPermission: editAllTransactionPermission,
      column11EditOwnTransactionPermission: editOwnTransactionPermission,
      column12DeleteAllTransactionPermission: deleteAllTransactionPermission,
      column13DeleteOwnTransactionPermission: deleteOwnTransactionPermission,
    };
  }

  static AccountModel? fromMap(
    Map<String, Object?>? accountMap,
  ) {
    // print('ACC_MDL | fromMap 02| input: \n$accountMap');

    if (accountMap == null) {
      print('ACC_MDL | fromMap 01| input is null');
      return null;
    }
    var account;

    try {
      account = AccountModel(
        id: accountMap[AccountModel.column1Id] as String,
        parentId: accountMap[AccountModel.column2ParentId] as String,
        titleEnglish: accountMap[AccountModel.column3TitleEnglish] as String,
        titlePersian: accountMap[AccountModel.column4TitlePersian] as String,
        titleArabic: accountMap[AccountModel.column5TitleArabic] as String,
        note: accountMap[AccountModel.column6Note] as String,
        createTransactionPermission:
            accountMap[AccountModel.column7CreateTransactionPermission]
                as String?,
        readAllTransactionPermission:
            accountMap[AccountModel.column8ReadAllTransactionPermission]
                as String?,
        readOwnTransactionPermission:
            accountMap[AccountModel.column9ReadOwnTransactionPermission]
                as String?,
        editAllTransactionPermission:
            accountMap[AccountModel.column10EditAllTransactionPermission]
                as String?,
        editOwnTransactionPermission:
            accountMap[AccountModel.column11EditOwnTransactionPermission]
                as String?,
        deleteAllTransactionPermission:
            accountMap[AccountModel.column12DeleteAllTransactionPermission]
                as String?,
        deleteOwnTransactionPermission:
            accountMap[AccountModel.column13DeleteOwnTransactionPermission]
                as String?,
      );

      // print('ACC_MDL | fromMap 03| output: \n$account');
      return account;
    } catch (e) {
      print(
        'ACC_MDL | fromMap() 01 | @ catch e: $e',
      );
      throw e;
    }
  }

  String toString() {
    return '''
    $column1Id: $id, 
    $column2ParentId: $parentId,
    $column3TitleEnglish: $titleEnglish,
    $column4TitlePersian: $titlePersian,
    $column5TitleArabic: $titleArabic, $column6Note: $note,
    $column7CreateTransactionPermission: $createTransactionPermission,
    $column8ReadAllTransactionPermission: $readAllTransactionPermission,
    $column9ReadOwnTransactionPermission: $readOwnTransactionPermission,
    $column10EditAllTransactionPermission: $editAllTransactionPermission,
    $column11EditOwnTransactionPermission: $editOwnTransactionPermission,
    $column12DeleteAllTransactionPermission: $deleteAllTransactionPermission,
    $column13DeleteOwnTransactionPermission: $deleteOwnTransactionPermission,
    ''';
  }
}
