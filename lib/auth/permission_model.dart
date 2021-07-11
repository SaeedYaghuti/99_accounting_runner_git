import 'package:shop/auth/auth_db_helper.dart';

class PermissionModel {
  final String id;
  final String titleEnglish;
  final String titlePersian;
  final String titleArabic;
  final String note;

  const PermissionModel({
    required this.id,
    required this.titleEnglish,
    required this.titlePersian,
    required this.titleArabic,
    this.note = '',
  });

  Future<int> insertMeIntoDB() async {
    // do some logic on variables
    try {
      return AuthDB.insert(tableName, toMap());
    } catch (e) {
      print('PermissionModel insertInDB() 01| error:$e');
      throw e;
    }
  }

  static Future<List<PermissionModel?>?> allPermissions() async {
    final query = '''
    SELECT *
    FROM $tableName
    ''';
    List<PermissionModel?> permissions = [];

    try {
      var result = await AuthDB.runRawQuery(query);
      // print('PermissionModel allPermissions 01| all Permissions: ########');
      // print(result);
      // print('##################');

      if (result == null || result.isEmpty) return null;
      result.forEach(
        (permMap) => permissions.add(fromMap(permMap)),
      );
      print('PermissionModel allPermissions 03| fetched Permissions:');
      print('Permissions count: ${permissions.length}');
      // print(Permissions);
      return permissions;
    } on Exception catch (e) {
      print('PermissionModel allPermissions 02| @ catch wile fromMap e: $e');
    }
  }

  static Future<PermissionModel?> fetchPermissionById(
      String permissionId) async {
    final query = '''
    SELECT *
    FROM $tableName
    WHERE $column1Id = ? ;
    ''';
    try {
      var fetchResult = await AuthDB.runRawQuery(
        query,
        [permissionId],
      );
      // print(
      //   'PermissionModel fetchPermissionById 01| fetchResult for permissionId: $permissionId',
      // );
      // print(fetchResult);

      // before list.first always you should check isEmpty
      if (fetchResult == null || fetchResult.isEmpty) return null;

      PermissionModel? permission = fromMap(fetchResult.first);
      print(permission);
      return permission;
      // return fetchResult;
    } catch (e) {
      print('PERM_MDL fetchPermissionById() 01| e: $e');
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
      var count = await AuthDB.deleteRawQuery(query, [id]);
      print('PermissionModel deleteMeFromDB 01| DELETE $id; count: $count');
      return count;
    } catch (e) {
      print('PermissionModel deleteMeFromDB 02| e: $e');
      throw e;
    }
  }

  static const String tableName = 'permissions';
  static const String column1Id = 'permission_id';
  static const String column2TitleEnglish = 'permission_title_english';
  static const String column3TitlePersian = 'permission_title_persian';
  static const String column4TitleArabic = 'permission_title_arabic';
  static const String column5Note = 'permission_note';

  static const String QUERY_CREATE_PERMISSION_TABLE =
      '''CREATE TABLE $tableName (
    $column1Id TEXT PRIMARY KEY, 
    $column2TitleEnglish TEXT, 
    $column3TitlePersian TEXT, 
    $column4TitleArabic TEXT, 
    $column5Note TEXT
  )''';

  Map<String, Object> toMap() {
    return {
      column1Id: id,
      column2TitleEnglish: titleEnglish,
      column3TitlePersian: titlePersian,
      column4TitleArabic: titleArabic,
      column5Note: note,
    };
  }

  static PermissionModel? fromMap(
    Map<String, Object?>? permissionMap,
  ) {
    if (permissionMap == null) {
      print('PermissionModel fromMap 01| input is null');
      return null;
    }
    var permission = PermissionModel(
      id: permissionMap[PermissionModel.column1Id] as String,
      titleEnglish:
          permissionMap[PermissionModel.column2TitleEnglish] as String,
      titlePersian:
          permissionMap[PermissionModel.column3TitlePersian] as String,
      titleArabic: permissionMap[PermissionModel.column4TitleArabic] as String,
      note: permissionMap[PermissionModel.column5Note] as String,
    );
    print('PermissionModel fromMap 03| output: \n$permission');
    return permission;
  }

  String toString() {
    return '''
    $column1Id: $id, 
    $column2TitleEnglish: $titleEnglish,
    $column3TitlePersian: $titlePersian,
    $column4TitleArabic: $titleArabic,
    $column5Note: $note,
    ''';
  }

  // nobody have this perm
  static const String LEDGER_CREATE_TRANSACTION_X =
      'LEDGER_CREATE_TRANSACTION_X';
  static const String LEDGER_READ_ALL_TRANSACTION =
      'LEDGER_READ_ALL_TRANSACTION';

  // nobody have this perm
  static const String SALES_CREATE_TRANSACTION_X = 'SALES_CREATE_TRANSACTION_X';
  static const String SALES_READ_ALL_TRANSACTION =
      'LEDGER_READ_ALL_TRANSACTION';

  static const String EXPENDITURE_CATEGORY = 'EXPENDITURE_CATEGORY';
  static const String EXPENDITURE_CREATE_TRANSACTION =
      'EXPENDITURE_CREATE_TRANSACTION';
  static const String EXPENDITURE_READ_ALL_TRANSACTION =
      'EXPENDITURE_READ_ALL_TRANSACTION';
  static const String EXPENDITURE_READ_OWN_TRANSACTION =
      'EXPENDITURE_READ_OWN_TRANSACTION';
  static const String EXPENDITURE_EDIT_ALL_TRANSACTION =
      'EXPENDITURE_EDIT_ALL_TRANSACTION';
  static const String EXPENDITURE_EDIT_OWN_TRANSACTION =
      'EXPENDITURE_EDIT_OWN_TRANSACTION';
  static const String EXPENDITURE_DELETE_ALL_TRANSACTION =
      'EXPENDITURE_DELETE_ALL_TRANSACTION';
  static const String EXPENDITURE_DELETE_OWN_TRANSACTION =
      'EXPENDITURE_DELETE_OWN_TRANSACTION';

  // nobody have this perm
  static const String ASSETS_CREATE_TRANSACTION_X =
      'ASSETS_CREATE_TRANSACTION_X';
  static const String ASSETS_READ_ALL_TRANSACTION =
      'ASSETS_READ_ALL_TRANSACTION';

  // nobody have this perm
  static const String BANKS_CREATE_TRANSACTION_X = 'BANKS_CREATE_TRANSACTION_X';
  static const String BANKS_READ_ALL_TRANSACTION = 'BANKS_READ_ALL_TRANSACTION';

  static const String NBO_CREATE_TRANSACTION = 'NBO_CREATE_TRANSACTION';
  static const String NBO_READ_ALL_TRANSACTION = 'NBO_READ_ALL_TRANSACTION';
  static const String NBO_READ_OWN_TRANSACTION = 'NBO_READ_OWN_TRANSACTION';
  static const String NBO_EDIT_ALL_TRANSACTION = 'NBO_EDIT_ALL_TRANSACTION';
  static const String NBO_EDIT_OWN_TRANSACTION = 'NBO_EDIT_OWN_TRANSACTION';
  static const String NBO_DELETE_ALL_TRANSACTION = 'NBO_DELETE_ALL_TRANSACTION';
  static const String NBO_DELETE_OWN_TRANSACTION = 'NBO_DELETE_OWN_TRANSACTION';

  static const String PETTY_CASH_CREATE_TRANSACTION =
      'PETTY_CASH_CREATE_TRANSACTION';
  static const String PETTY_CASH_READ_ALL_TRANSACTION =
      'PETTY_CASH_READ_ALL_TRANSACTION';
  static const String PETTY_CASH_READ_OWN_TRANSACTION =
      'PETTY_CASH_READ_OWN_TRANSACTION';
  static const String PETTY_CASH_EDIT_ALL_TRANSACTION =
      'PETTY_CASH_EDIT_ALL_TRANSACTION';
  static const String PETTY_CASH_EDIT_OWN_TRANSACTION =
      'PETTY_CASH_EDIT_OWN_TRANSACTION';
  static const String PETTY_CASH_DELETE_ALL_TRANSACTION =
      'PETTY_CASH_DELETE_ALL_TRANSACTION';
  static const String PETTY_CASH_DELETE_OWN_TRANSACTION =
      'PETTY_CASH_DELETE_OWN_TRANSACTION';

  static const String CASH_DRAWER_CREATE_TRANSACTION =
      'CASH_DRAWER_CREATE_TRANSACTION';
  static const String CASH_DRAWER_READ_ALL_TRANSACTION =
      'CASH_DRAWER_READ_ALL_TRANSACTION';
  static const String CASH_DRAWER_READ_OWN_TRANSACTION =
      'CASH_DRAWER_READ_OWN_TRANSACTION';
  static const String CASH_DRAWER_EDIT_ALL_TRANSACTION =
      'CASH_DRAWER_EDIT_ALL_TRANSACTION';
  static const String CASH_DRAWER_EDIT_OWN_TRANSACTION =
      'CASH_DRAWER_EDIT_OWN_TRANSACTION';
  static const String CASH_DRAWER_DELETE_ALL_TRANSACTION =
      'CASH_DRAWER_DELETE_ALL_TRANSACTION';
  static const String CASH_DRAWER_DELETE_OWN_TRANSACTION =
      'CASH_DRAWER_DELETE_OWN_TRANSACTION';

  // nobody have this perm
  static const String DEBTORS_CREATE_TRANSACTION_X =
      'DEBTORS_CREATE_TRANSACTION_X';
  static const String DEBTORS_READ_ALL_TRANSACTION =
      'DEBTORS_READ_ALL_TRANSACTION';

  // nobody have this perm
  static const String LIABILITIES_CREATE_TRANSACTION_X =
      'LIABILITIES_CREATE_TRANSACTION_X';
  static const String LIABILITIES_READ_ALL_TRANSACTION =
      'LIABILITIES_READ_ALL_TRANSACTION';

  static const String SELL_POINT_CATEGORY = 'SELL_POINT_CATEGORY';

  static const String RETAIL_CATEGORY = 'RETAIL_CATEGORY';
  static const String RETAIL_CREATE_TRANSACTION = 'RETAIL_CREATE_TRANSACTION';
  static const String RETAIL_READ_ALL_TRANSACTION =
      'RETAIL_READ_ALL_TRANSACTION';
  static const String RETAIL_READ_OWN_TRANSACTION =
      'RETAIL_READ_OWN_TRANSACTION';
  static const String RETAIL_EDIT_ALL_TRANSACTION =
      'RETAIL_EDIT_ALL_TRANSACTION';
  static const String RETAIL_EDIT_OWN_TRANSACTION =
      'RETAIL_EDIT_OWN_TRANSACTION';
  static const String RETAIL_DELETE_ALL_TRANSACTION =
      'RETAIL_DELETE_ALL_TRANSACTION';
  static const String RETAIL_DELETE_OWN_TRANSACTION =
      'RETAIL_DELETE_OWN_TRANSACTION';

  static const String WHOLESALE_CATEGORY = 'WHOLESALE_CATEGORY';
  static const String WHOLESALE_CREATE_TRANSACTION =
      'WHOLESALE_CREATE_TRANSACTION';
  static const String WHOLESALE_READ_ALL_TRANSACTION =
      'WHOLESALE_READ_ALL_TRANSACTION';
  static const String WHOLESALE_READ_OWN_TRANSACTION =
      'WHOLESALE_READ_OWN_TRANSACTION';
  static const String WHOLESALE_EDIT_ALL_TRANSACTION =
      'WHOLESALE_EDIT_ALL_TRANSACTION';
  static const String WHOLESALE_EDIT_OWN_TRANSACTION =
      'WHOLESALE_EDIT_OWN_TRANSACTION';
  static const String WHOLESALE_DELETE_ALL_TRANSACTION =
      'WHOLESALE_DELETE_ALL_TRANSACTION';
  static const String WHOLESALE_DELETE_OWN_TRANSACTION =
      'WHOLESALE_DELETE_OWN_TRANSACTION';

  static const String PURCHAS_CATEGORY = 'PURCHAS_CATEGORY';
  static const String PURCHAS_CREATE_TRANSACTION = 'PURCHAS_CREATE_TRANSACTION';
  static const String PURCHAS_READ_ALL_TRANSACTION =
      'PURCHAS_READ_ALL_TRANSACTION';
  static const String PURCHAS_READ_OWN_TRANSACTION =
      'PURCHAS_READ_OWN_TRANSACTION';
  static const String PURCHAS_EDIT_ALL_TRANSACTION =
      'PURCHAS_EDIT_ALL_TRANSACTION';
  static const String PURCHAS_EDIT_OWN_TRANSACTION =
      'PURCHAS_EDIT_OWN_TRANSACTION';
  static const String PURCHAS_DELETE_ALL_TRANSACTION =
      'PURCHAS_DELETE_ALL_TRANSACTION';
  static const String PURCHAS_DELETE_OWN_TRANSACTION =
      'PURCHAS_DELETE_OWN_TRANSACTION';

  static const String ITEM_CATEGORY = 'ITEM_CATEGORY';
  static const String ITEM_CREATE_TRANSACTION = 'ITEM_CREATE_TRANSACTION';
  static const String ITEM_READ_ALL_TRANSACTION = 'ITEM_READ_ALL_TRANSACTION';
  static const String ITEM_READ_OWN_TRANSACTION = 'ITEM_READ_OWN_TRANSACTION';
  static const String ITEM_EDIT_ALL_TRANSACTION = 'ITEM_EDIT_ALL_TRANSACTION';
  static const String ITEM_EDIT_OWN_TRANSACTION = 'ITEM_EDIT_OWN_TRANSACTION';
  static const String ITEM_DELETE_ALL_TRANSACTION =
      'ITEM_DELETE_ALL_TRANSACTION';
  static const String ITEM_DELETE_OWN_TRANSACTION =
      'ITEM_DELETE_OWN_TRANSACTION';

  static const String MONEY_MOVEMENT_CATEGORY = 'MONEY_MOVEMENT_CATEGORY';
  static const String MONEY_MOVEMENT_CREATE_TRANSACTION =
      'MONEY_MOVEMENT_CREATE_TRANSACTION';
  static const String MONEY_MOVEMENT_READ_ALL_TRANSACTION =
      'MONEY_MOVEMENT_READ_ALL_TRANSACTION';
  static const String MONEY_MOVEMENT_READ_OWN_TRANSACTION =
      'MONEY_MOVEMENT_READ_OWN_TRANSACTION';
  static const String MONEY_MOVEMENT_EDIT_ALL_TRANSACTION =
      'MONEY_MOVEMENT_EDIT_ALL_TRANSACTION';
  static const String MONEY_MOVEMENT_EDIT_OWN_TRANSACTION =
      'MONEY_MOVEMENT_EDIT_OWN_TRANSACTION';
  static const String MONEY_MOVEMENT_DELETE_ALL_TRANSACTION =
      'MONEY_MOVEMENT_DELETE_ALL_TRANSACTION';
  static const String MONEY_MOVEMENT_DELETE_OWN_TRANSACTION =
      'MONEY_MOVEMENT_DELETE_OWN_TRANSACTION';

  static const String REPORT_CATEGORY = 'REPORT_CATEGORY';
  static const String REPORT_READ_ALL_TRANSACTION =
      'REPORT_READ_ALL_TRANSACTION';

  static const String ACCOUNT_CATEGORY = 'ACCOUNT_CATEGORY';
  static const String ACCOUNT_CREATE_TRANSACTION = 'ACCOUNT_CREATE_TRANSACTION';
  static const String ACCOUNT_READ_ALL_TRANSACTION =
      'ACCOUNT_READ_ALL_TRANSACTION';
  static const String ACCOUNT_READ_OWN_TRANSACTION =
      'ACCOUNT_READ_OWN_TRANSACTION';
  static const String ACCOUNT_EDIT_ALL_TRANSACTION =
      'ACCOUNT_EDIT_ALL_TRANSACTION';
  static const String ACCOUNT_EDIT_OWN_TRANSACTION =
      'ACCOUNT_EDIT_OWN_TRANSACTION';
  static const String ACCOUNT_DELETE_ALL_TRANSACTION =
      'ACCOUNT_DELETE_ALL_TRANSACTION';
  static const String ACCOUNT_DELETE_OWN_TRANSACTION =
      'ACCOUNT_DELETE_OWN_TRANSACTION';

  static const String ITEM_SUMMERY_CATEGORY = 'ITEM_SUMMERY_CATEGORY';
}
