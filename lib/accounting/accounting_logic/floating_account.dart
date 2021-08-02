import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/exceptions/join_exception.dart';

class FloatingAccount {
  final String id;
  final String parentId;
  final String titleEnglish;
  final String titlePersian;
  final String titleArabic;
  final String note;

  const FloatingAccount({
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
      print('FloatingAccount insertInDB() 01| error:$e');
      throw e;
    }
  }

  // static Future<List<FloatingAccount?>> allTransactionClasses(String? accountType) async {
  //   var query = '''
  //   SELECT *
  //   FROM $tableName
  //   ''';
  //   if (accountType != null && accountType.trim() != '') {
  //     query = '''
  //   SELECT *
  //   FROM $tableName
  //   WHERE $column3AccountType = ?
  //   ''';
  //   }
  //   List<FloatingAccount?> expClasses = [];
  //   try {
  //     var result = await AccountingDB.runRawQuery(query, [accountType]);
  //     // print('FloatingAccount allTransactionClasses 01| all tranClasses: ########');
  //     // print(result);
  //     // print('##################');
  //     if (result.isEmpty) return [];
  //     result.forEach(
  //       (accMap) => expClasses.add(fromMap(accMap)),
  //     );
  //     // print('FloatingAccount allTransactionClasses 03| fetched Accounts:');
  //     // print('accounts count: ${accounts.length}');
  //     // print(accounts);
  //     return expClasses;
  //   } on Exception catch (e) {
  //     print('FloatingAccount allTransactionClasses 02| @ catch wile fromMap e: $e');
  //     throw e;
  //   }
  // }

  static Future<FloatingAccount?> fetchFloatAccountById(String floatId) async {
    // print('TRN_CLASS fetchFloatAccountById() 01| floatId: <$floatId>');
    final query = '''
    SELECT *
    FROM $tableName
    WHERE $column1Id = ? ;
    ''';
    try {
      var fetchResult = await AccountingDB.runRawQuery(query, [floatId]);
      // print(
      //   'FloatingAccount fetchFloatAccountById 01| fetchResult for expClassId: $expClassId',
      // );
      // print(fetchResult);

      // before list.first always you should check isEmpty
      if (fetchResult.isEmpty) return null;

      FloatingAccount? floatAccount = fromMap(fetchResult.first);
      // print(account);
      return floatAccount;
      // return fetchResult;
    } catch (e) {
      print('TRN_CLASS fetchFloatAccountById() 01| e: $e');
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
      print('FloatingAccount deleteMeFromDB 01| DELETE $id; count: $count');
      return count;
    } catch (e) {
      print('FloatingAccount deleteMeFromDB 01| e: $e');
      throw e;
    }
  }

  static const String tableName = 'floating_account';
  static const String column1Id = 'float_id';
  static const String column2ParentId = 'float_parentId';
  static const String column3TitleEnglish = 'float_titleEnglish';
  static const String column4TitlePersian = 'float_titlePersian';
  static const String column5TitleArabic = 'float_titleArabic';
  static const String column6Note = 'float_note';

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

  static FloatingAccount? fromMap(Map<String, Object?>? floatAccountMap, [bool throwError = false]) {
    // print('TRN_CLASS | fromMap 01| input: \n$tranClassMap');

    if (floatAccountMap == null || floatAccountMap[FloatingAccount.column1Id] == null) {
      print('TRN_CLASS | fromMap 02| tranClassMap or JoinClass is null');
      if (throwError) {
        throw JoinException('TRN_CLASS | fromMap 03| input is null');
      } else {
        return null;
      }
    }
    var floatAcc;

    try {
      floatAcc = FloatingAccount(
        id: floatAccountMap[FloatingAccount.column1Id] as String,
        parentId: floatAccountMap[FloatingAccount.column2ParentId] as String,
        titleEnglish: floatAccountMap[FloatingAccount.column3TitleEnglish] as String,
        titlePersian: floatAccountMap[FloatingAccount.column4TitlePersian] as String,
        titleArabic: floatAccountMap[FloatingAccount.column5TitleArabic] as String,
        note: floatAccountMap[FloatingAccount.column6Note] as String,
      );

      // print('TRN_CLASS | fromMap 04| output: \n$tranClass');
      return floatAcc;
    } catch (e) {
      print('TRN_CLASS | fromMap() 05 | @ catch e: $e');
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
