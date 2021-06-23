class AccountModel {
  final String id;
  final String parentId;
  final String titleEnglish;
  final String titlePersian;
  final String titleArabic;
  final String note;

  const AccountModel({
    required this.id,
    required this.parentId,
    required this.titleEnglish,
    required this.titlePersian,
    required this.titleArabic,
    this.note = '',
  });

  static const String tableName = 'accounts';
  static const String columnId = 'id';
  static const String columnParentId = 'parentId';
  static const String columnTitleEnglish = 'titleEnglish';
  static const String columnTitlePersian = 'titlePersian';
  static const String columnTitleArabic = 'titleArabic';
  static const String columnNote = 'note';

  static const String CREATE_ACCOUNT_TABLE_QUERY = '''CREATE TABLE $tableName (
    $columnId TEXT PRIMARY KEY, 
    $columnParentId TEXT PRIMARY KEY, 
    $columnTitleEnglish TEXT, 
    $columnTitlePersian TEXT, 
    $columnTitleArabic TEXT, 
    $columnNote TEXT,
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
