import 'dart:convert';

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

  // TODO: we should store c/e/dPermisionsAny at db
  // TODO: currently we read accounts from AccountTree => we should read from DB
  // TODO: Add account, update account, delete account

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

  static AccountModel fromMap(
    Map<String, Object?> accountMap,
  ) {
    var account = AccountModel(
      id: accountMap[AccountModel.column1Id] as String,
      parentId: accountMap[AccountModel.column2ParentId] as String,
      titleEnglish: accountMap[AccountModel.column3TitleEnglish] as String,
      titlePersian: accountMap[AccountModel.column4TitlePersian] as String,
      titleArabic: accountMap[AccountModel.column5TitleArabic] as String,
      note: accountMap[AccountModel.column6Note] as String,
      createTransactionPermissionsAny: json.decode(
        accountMap[AccountModel.column7CreateTransactionPermissionsAny]
            as String,
      ) as List<String?>?,
      readTransactionPermissionsAny: json.decode(
        accountMap[AccountModel.column8ReadTransactionPermissionsAny] as String,
      ) as List<String?>?,
      editTransactionPermissionsAny: json.decode(
        accountMap[AccountModel.column9EditTransactionPermissionsAny] as String,
      ) as List<String?>?,
      deleteTransactionPermissionsAny: json.decode(
        accountMap[AccountModel.column10DeleteTransactionPermissionsAny]
            as String,
      ) as List<String?>?,
    );
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
    ''';
  }
}
