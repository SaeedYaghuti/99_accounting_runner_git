import 'package:shop/accounting/accounting_logic/accounting_db.dart';

class ExpenditureClassification {
  final String id;
  final String parentId;
  final String titleEnglish;
  final String titlePersian;
  final String titleArabic;
  final String note;

  const ExpenditureClassification({
    required this.id,
    required this.parentId,
    required this.titleEnglish,
    required this.titlePersian,
    required this.titleArabic,
    this.note = '',
  });

  Future<int> insertMeIntoDB() async {
    // do some logic on variables
    try {
      return AccountingDB.insert(tableName, toMap());
    } catch (e) {
      print('ExpenditureClassification insertInDB() 01| error:$e');
      throw e;
    }
  }

  static Future<List<ExpenditureClassification?>> allExpenditureClasses() async {
    final query = '''
    SELECT *
    FROM $tableName
    ''';
    List<ExpenditureClassification?> expClasses = [];

    try {
      var result = await AccountingDB.runRawQuery(query);
      // print('ExpenditureClassification allAccounts 01| all accounts: ########');
      // print(result);
      // print('##################');

      if (result.isEmpty) return [];

      result.forEach(
        (accMap) => expClasses.add(fromMap(accMap)),
      );
      // print('ExpenditureClassification allAccounts 03| fetched Accounts:');
      // print('accounts count: ${accounts.length}');
      // print(accounts);
      return expClasses;
    } on Exception catch (e) {
      print('ExpenditureClassification allAccounts 02| @ catch wile fromMap e: $e');
      throw e;
    }
  }

  static Future<ExpenditureClassification?> fetchExpClassificationById(
    String expClassId,
  ) async {
    // print('EXP_CLASS fetchExpClassificationById() 01| accountId: <$accountId>');
    final query = '''
    SELECT *
    FROM $tableName
    WHERE $column1Id = ? ;
    ''';
    try {
      var fetchResult = await AccountingDB.runRawQuery(query, [expClassId]);
      // print(
      //   'ExpenditureClassification fetchExpClassificationById 01| fetchResult for accountId: $accountId',
      // );
      // print(fetchResult);

      // before list.first always you should check isEmpty
      if (fetchResult.isEmpty) return null;

      ExpenditureClassification? expClass = fromMap(fetchResult.first);
      // print(account);
      return expClass;
      // return fetchResult;
    } catch (e) {
      print('EXP_CLASS fetchExpClassificationById() 01| e: $e');
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
      print('ExpenditureClassification deleteMeFromDB 01| DELETE $id; count: $count');
      return count;
    } catch (e) {
      print('ExpenditureClassification deleteMeFromDB 01| e: $e');
      throw e;
    }
  }

  static const String tableName = 'expenditure_classification';
  static const String column1Id = 'exp_class_id';
  static const String column2ParentId = 'exp_class_parentId';
  static const String column3TitleEnglish = 'exp_class_titleEnglish';
  static const String column4TitlePersian = 'exp_class_titlePersian';
  static const String column5TitleArabic = 'exp_class_titleArabic';
  static const String column6Note = 'exp_class_note';

  static const String QUERY_CREATE_EXPENDITURE_CLASSIFICATION_TABLE = '''CREATE TABLE $tableName (
    $column1Id TEXT PRIMARY KEY, 
    $column2ParentId TEXT NOT NULL, 
    $column3TitleEnglish TEXT NOT NULL, 
    $column4TitlePersian TEXT NOT NULL, 
    $column5TitleArabic TEXT NOT NULL, 
    $column6Note TEXT NOT NULL DEFAULT '_',
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
    };
  }

  static ExpenditureClassification? fromMap(
    Map<String, Object?>? expClassMap,
  ) {
    // print('EXP_CLASS | fromMap 02| input: \n$accountMap');

    if (expClassMap == null) {
      print('EXP_CLASS | fromMap 01| input is null');
      return null;
    }
    var account;

    try {
      account = ExpenditureClassification(
        id: expClassMap[ExpenditureClassification.column1Id] as String,
        parentId: expClassMap[ExpenditureClassification.column2ParentId] as String,
        titleEnglish: expClassMap[ExpenditureClassification.column3TitleEnglish] as String,
        titlePersian: expClassMap[ExpenditureClassification.column4TitlePersian] as String,
        titleArabic: expClassMap[ExpenditureClassification.column5TitleArabic] as String,
        note: expClassMap[ExpenditureClassification.column6Note] as String,
      );

      // print('EXP_CLASS | fromMap 03| output: \n$account');
      return account;
    } catch (e) {
      print(
        'EXP_CLASS | fromMap() 01 | @ catch e: $e',
      );
      throw e;
    }
  }

  String toString() {
    return '''
    id: $id, 
    parentId: $parentId,
    titleEnglish: $titleEnglish,
    titlePersian: $titlePersian,
    titleArabic: $titleArabic, note: $note,
    ''';
  }
}
