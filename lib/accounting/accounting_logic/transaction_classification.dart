import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/exceptions/join_exception.dart';

import 'account_model.dart';

class TransactionClassification {
  final String id;
  final String parentId;
  final String accountType;
  final String titleEnglish;
  final String titlePersian;
  final String titleArabic;
  final String note;

  const TransactionClassification({
    required this.id,
    required this.parentId,
    required this.accountType,
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
      print('TransactionClassification insertInDB() 01| error:$e');
      throw e;
    }
  }

  static Future<List<TransactionClassification?>> allTransactionClasses() async {
    final query = '''
    SELECT *
    FROM $tableName
    ''';
    List<TransactionClassification?> expClasses = [];

    try {
      var result = await AccountingDB.runRawQuery(query);
      // print('TransactionClassification allTransactionClasses 01| all accounts: ########');
      // print(result);
      // print('##################');

      if (result.isEmpty) return [];

      result.forEach(
        (accMap) => expClasses.add(fromMap(accMap)),
      );
      // print('TransactionClassification allTransactionClasses 03| fetched Accounts:');
      // print('accounts count: ${accounts.length}');
      // print(accounts);
      return expClasses;
    } on Exception catch (e) {
      print('TransactionClassification allTransactionClasses 02| @ catch wile fromMap e: $e');
      throw e;
    }
  }

  static Future<TransactionClassification?> fetchTranClassById(
    String expClassId,
  ) async {
    // print('TRN_CLASS fetchTranClassById() 01| accountId: <$accountId>');
    final query = '''
    SELECT *
    FROM $tableName
    WHERE $column1Id = ? ;
    ''';
    try {
      var fetchResult = await AccountingDB.runRawQuery(query, [expClassId]);
      // print(
      //   'TransactionClassification fetchTranClassById 01| fetchResult for accountId: $accountId',
      // );
      // print(fetchResult);

      // before list.first always you should check isEmpty
      if (fetchResult.isEmpty) return null;

      TransactionClassification? expClass = fromMap(fetchResult.first);
      // print(account);
      return expClass;
      // return fetchResult;
    } catch (e) {
      print('TRN_CLASS fetchTranClassById() 01| e: $e');
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
      print('TransactionClassification deleteMeFromDB 01| DELETE $id; count: $count');
      return count;
    } catch (e) {
      print('TransactionClassification deleteMeFromDB 01| e: $e');
      throw e;
    }
  }

  static const String tableName = 'expenditure_classification';
  static const String column1Id = 'tran_class_id';
  static const String column2ParentId = 'tran_class_parentId';
  static const String column3AccountType = 'tran_class_account_type';
  static const String column4TitleEnglish = 'tran_class_titleEnglish';
  static const String column5TitlePersian = 'tran_class_titlePersian';
  static const String column6TitleArabic = 'tran_class_titleArabic';
  static const String column7Note = 'tran_class_note';

  static const String QUERY_CREATE_EXPENDITURE_CLASSIFICATION_TABLE = '''CREATE TABLE $tableName (
    $column1Id TEXT PRIMARY KEY, 
    $column2ParentId TEXT NOT NULL, 
    $column3AccountType TEXT NOT NULL, 
    $column4TitleEnglish TEXT NOT NULL, 
    $column5TitlePersian TEXT NOT NULL, 
    $column6TitleArabic TEXT NOT NULL, 
    $column7Note TEXT NOT NULL DEFAULT '_',
    FOREIGN KEY ($column2ParentId) REFERENCES $tableName ($column1Id),
    FOREIGN KEY ($column3AccountType) REFERENCES ${AccountModel.tableName} (${AccountModel.column1Id})
  )''';

  Map<String, Object?> toMap() {
    return {
      column1Id: id,
      column2ParentId: parentId,
      column3AccountType: accountType,
      column4TitleEnglish: titleEnglish,
      column5TitlePersian: titlePersian,
      column6TitleArabic: titleArabic,
      column7Note: note,
    };
  }

  static TransactionClassification? fromMap(Map<String, Object?>? tranClassMap, [bool throwError = false]) {
    // print('TRN_CLASS | fromMap 02| input: \n$accountMap');

    if (tranClassMap == null) {
      print('TRN_CLASS | fromMap 01| input is null');
      if (throwError) {
        throw JoinException('TRN_CLASS | fromMap 01| input is null');
      } else {
        return null;
      }
    }
    var account;

    try {
      account = TransactionClassification(
        id: tranClassMap[TransactionClassification.column1Id] as String,
        parentId: tranClassMap[TransactionClassification.column2ParentId] as String,
        accountType: tranClassMap[TransactionClassification.column3AccountType] as String,
        titleEnglish: tranClassMap[TransactionClassification.column4TitleEnglish] as String,
        titlePersian: tranClassMap[TransactionClassification.column5TitlePersian] as String,
        titleArabic: tranClassMap[TransactionClassification.column6TitleArabic] as String,
        note: tranClassMap[TransactionClassification.column7Note] as String,
      );

      // print('TRN_CLASS | fromMap 03| output: \n$account');
      return account;
    } catch (e) {
      print(
        'TRN_CLASS | fromMap() 01 | @ catch e: $e',
      );
      throw e;
    }
  }

  String toString() {
    return '''
    id: $id, 
    parentId: $parentId,
    accountType: $accountType,
    titleEnglish: $titleEnglish,
    titlePersian: $titlePersian,
    titleArabic: $titleArabic, note: $note,
    ''';
  }
}
