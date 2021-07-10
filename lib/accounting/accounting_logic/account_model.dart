class AccountModel {
  final String id;
  final String parentId;
  final String titleEnglish;
  final String titlePersian;
  final String titleArabic;
  final String note;
  final List<String?>? createPermissionsAny;
  final List<String?>? editPermissionsAny;
  final List<String?>? deletePermissionsAny;

  const AccountModel({
    required this.id,
    required this.parentId,
    required this.titleEnglish,
    required this.titlePersian,
    required this.titleArabic,
    this.note = '',
    this.createPermissionsAny,
    this.editPermissionsAny,
    this.deletePermissionsAny,
  });

  // TODO: we should store c/e/dPermisionsAny at db
  // TODO: currently we read accounts from AccountTree => we should read from DB
  // TODO: Add account, update account, delete account

  static const String tableName = 'accounts';
  static const String columnId = 'id';
  static const String columnParentId = 'parentId';
  static const String columnTitleEnglish = 'titleEnglish';
  static const String columnTitlePersian = 'titlePersian';
  static const String columnTitleArabic = 'titleArabic';
  static const String columnNote = 'note';

  static const String QUERY_CREATE_ACCOUNT_TABLE = '''CREATE TABLE $tableName (
    $columnId TEXT PRIMARY KEY, 
    $columnParentId TEXT, 
    $columnTitleEnglish TEXT, 
    $columnTitlePersian TEXT, 
    $columnTitleArabic TEXT, 
    $columnNote TEXT,
    FOREIGN KEY ($columnParentId) REFERENCES $tableName ($columnId)
  )''';

  Map<String, Object> toMap() {
    return {
      columnId: id,
      columnParentId: parentId,
      columnTitleEnglish: titleEnglish,
      columnTitlePersian: titlePersian,
      columnTitleArabic: titleArabic,
      columnNote: note,
    };
  }

  String toString() {
    return '''
    ${AccountModel.columnId}: $id, 
    ${AccountModel.columnParentId}: $parentId,
    ${AccountModel.columnTitleEnglish}: $titleEnglish,
    ${AccountModel.columnTitlePersian}: $titlePersian,
    ${AccountModel.columnTitleArabic}: $titleArabic,
    ${AccountModel.columnNote}: $note,
    ''';
  }
}
