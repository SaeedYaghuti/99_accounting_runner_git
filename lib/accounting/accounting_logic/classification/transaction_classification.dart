import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/auth/permission_model.dart';
import 'package:shop/exceptions/access_denied_exception.dart';
import 'package:shop/exceptions/join_exception.dart';

import '../account_model.dart';
import 'classification_types.dart';

class TransactionClassification {
  final String? id;
  final String parentId;
  final String classType;
  final String titleEnglish;
  final String titlePersian;
  final String titleArabic;
  final String note;

  const TransactionClassification({
    this.id,
    required this.parentId,
    required this.classType,
    required this.titleEnglish,
    required this.titlePersian,
    required this.titleArabic,
    required this.note,
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

  static Future<TransactionClassification> insertIntoDB(
      AuthProviderSQL authProvider, TransactionClassification tranClass) async {
    // check authority
    if (authProvider.isNotPermitted(PermissionModel.TRANSACTION_CLASS_CRED)) {
      print(
        'TRN_CLASS | insertIntoDB() 01 | authProvider ${authProvider.authId} has not access to ${PermissionModel.TRANSACTION_CLASS_CRED}',
      );
      throw AccessDeniedException(
        'TRN_CLASS | insertIntoDB() 01 | authProvider ${authProvider.authId} has not access to ${PermissionModel.TRANSACTION_CLASS_CRED}',
      );
    }

    // do some logic on variables
    try {
      await AccountingDB.insert(tableName, tranClass.toMap());
      return tranClass;
    } catch (e) {
      print('TransactionClassification insertIntoDB() 02| error:$e');
      throw e;
    }
  }

  Future<int> updateMeIntoDB() async {
    // do some logic on variables
    try {
      return await AccountingDB.update(tableName, toMap());
    } catch (e) {
      print('TransactionClassification updateMeIntoDB() 01| error:$e');
      throw e;
    }
  }

  static Future<List<TransactionClassification?>> allTransactionClasses(String? classType) async {
    var query = '''
    SELECT *
    FROM $tableName
    ''';
    if (classType != null && classType.trim() != '') {
      query = '''
      SELECT *
      FROM $tableName
      WHERE $column3ClassType = ? OR $column3ClassType = '${ClassificationTypes.ROOT_TYPE}'
      ''';
    }
    List<TransactionClassification?> tranClasses = [];

    try {
      var result = await AccountingDB.runRawQuery(query, [classType]);
      // print('TransactionClassification allTransactionClasses 01| all tranClasses: ########');
      // print(result);
      // print('##################');

      if (result.isEmpty) return [];

      result.forEach(
        (tranMap) => tranClasses.add(fromMap(tranMap)),
      );
      // print('TRN_CLSS | allTransactionClasses() 03| fetched tranClass:');
      // print('tranClass count: ${tranClasses.length}');
      // print(tranClasses.reversed);
      return tranClasses;
    } on Exception catch (e) {
      print('TransactionClassification allTransactionClasses 02| @ catch wile fromMap e: $e');
      throw e;
    }
  }

  static Future<TransactionClassification?> fetchTranClassById(String expClassId) async {
    // print('TRN_CLASS fetchTranClassById() 01| accountId: <$accountId>');
    final query = '''
    SELECT *
    FROM $tableName
    WHERE $column1Id = ? ;
    ''';
    try {
      var fetchResult = await AccountingDB.runRawQuery(query, [expClassId]);
      // print(
      //   'TransactionClassification fetchTranClassById 01| fetchResult for expClassId: $expClassId',
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

  Future<int> deleteMeFromDB(AuthProviderSQL authProvider) async {
    if (authProvider.isNotPermitted(PermissionModel.TRANSACTION_CLASS_CRED)) {
      print('TRN_CLSS | deleteMeFromDB() 01 | auth is not permitted for TRANSACTION_CLASS_CRED');
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
  static const String column1Id = 'tranClass_id';
  static const String column2ParentId = 'tranClass_parentId';
  static const String column3ClassType = 'tranClass_classType';
  static const String column4TitleEnglish = 'tranClass_titleEnglish';
  static const String column5TitlePersian = 'tranClass_titlePersian';
  static const String column6TitleArabic = 'tranClass_titleArabic';
  static const String column7Note = 'tranClass_note';

  static const String QUERY_CREATE_EXPENDITURE_CLASSIFICATION_TABLE = '''CREATE TABLE $tableName (
    $column1Id TEXT NOT NULL PRIMARY KEY, 
    $column2ParentId TEXT NOT NULL, 
    $column3ClassType TEXT NOT NULL, 
    $column4TitleEnglish TEXT NOT NULL, 
    $column5TitlePersian TEXT NOT NULL, 
    $column6TitleArabic TEXT NOT NULL, 
    $column7Note TEXT NOT NULL DEFAULT '_',
    FOREIGN KEY ($column2ParentId) REFERENCES $tableName ($column1Id),
    FOREIGN KEY ($column3ClassType) REFERENCES ${AccountModel.tableName} (${AccountModel.column1Id})
  )''';

  Map<String, Object?> toMap() {
    return {
      column1Id: id,
      column2ParentId: parentId,
      column3ClassType: classType,
      column4TitleEnglish: titleEnglish,
      column5TitlePersian: titlePersian,
      column6TitleArabic: titleArabic,
      column7Note: note,
    };
  }

  static TransactionClassification? fromMap(Map<String, Object?>? tranClassMap, [bool throwError = false]) {
    // print('TRN_CLASS | fromMap 01| input: \n$tranClassMap');

    if (tranClassMap == null || tranClassMap[TransactionClassification.column1Id] == null) {
      print('TRN_CLASS | fromMap 02| tranClassMap or JoinClass is null');
      if (throwError) {
        throw JoinException('TRN_CLASS | fromMap 03| input is null');
      } else {
        return null;
      }
    }
    var tranClass;

    try {
      tranClass = TransactionClassification(
        id: tranClassMap[TransactionClassification.column1Id] as String,
        parentId: tranClassMap[TransactionClassification.column2ParentId] as String,
        classType: tranClassMap[TransactionClassification.column3ClassType] as String,
        titleEnglish: tranClassMap[TransactionClassification.column4TitleEnglish] as String,
        titlePersian: tranClassMap[TransactionClassification.column5TitlePersian] as String,
        titleArabic: tranClassMap[TransactionClassification.column6TitleArabic] as String,
        note: tranClassMap[TransactionClassification.column7Note] as String,
      );

      // print('TRN_CLASS | fromMap 04| output: \n$tranClass');
      return tranClass;
    } catch (e) {
      print('TRN_CLASS | fromMap() 05 | @ catch e: $e');
      throw e;
    }
  }

  String toString() {
    return '''
    id: $id, 
    parentId: $parentId,
    classType: $classType,
    titleEnglish: $titleEnglish,
    titlePersian: $titlePersian,
    titleArabic: $titleArabic, note: $note,
    ''';
  }
}
