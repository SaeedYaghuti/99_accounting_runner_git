import 'package:shop/auth/auth_model_sql.dart';
import 'package:shop/auth/permission_model.dart';
import 'package:shop/auth/permissions_list.dart';
import 'package:sqflite/sqflite.dart';

import 'auth_db_helper.dart';

class AuthPermissionModel {
  final int? id;
  final int authId;
  final String permissionId;

  const AuthPermissionModel({
    this.id,
    required this.authId,
    required this.permissionId,
  });

  static Future<void> giveAllPermissionsToFirstAuth(Database db) async {
    try {
      for (var permission in PERMISSIONS_LIST) {
        var query = ''' 
        INSERT INTO $tableName ($column2AuthId, $column3PermissionId)
        VALUES (1, '${permission.id}') ;
        ''';
        await db.execute(query);
      }
      await db.close();
    } catch (e) {
      print('AuthPerm perm_first_auth 01| e: $e');
      throw e;
    }
  }

  static Future<void> printAllAuthPermissions() async {
    final query = '''
    SELECT *
    FROM $tableName
    ''';
    var authPermsMap = await AuthDB.runRawQuery(query);

    print('ATH_PERM_MDL printAllAuthPERM 01| All DB AuthPerms: ###########');
    print(authPermsMap);
    print('##################');
  }

  static const String tableName = 'auth_permissions';
  static const String column1Id = 'authperm_id';
  static const String column2AuthId = 'authperm_auth_id';
  static const String column3PermissionId = 'authperm_permission_id';

  static const String QUERY_CREATE_JOIN_TABLE_AUTH_PERMISSION =
      '''CREATE TABLE $tableName (
    $column1Id INTEGER PRIMARY KEY, 
    $column2AuthId INTEGER NOT NULL, 
    $column3PermissionId TEXT NOT NULL,
    CONSTRAINT fk_${AuthModel.authTableName} FOREIGN KEY ($column2AuthId) REFERENCES ${AuthModel.authTableName} (${AuthModel.column1Id}) ON DELETE NO ACTION,
    CONSTRAINT fk_${PermissionModel.tableName} FOREIGN KEY ($column3PermissionId) REFERENCES ${PermissionModel.tableName} (${PermissionModel.column1Id}) ON DELETE CASCADE
  )''';

  Map<String, Object> toMap() {
    if (id != null) {
      return {
        column1Id: id!,
        column2AuthId: authId,
        column3PermissionId: permissionId
      };
    } else {
      return {
        column2AuthId: authId,
        column3PermissionId: permissionId,
      };
    }
  }

  String toString() {
    return '''
    $column1Id: $id, 
    $column2AuthId: $authId,
    $column3PermissionId: $permissionId
    ''';
  }
}
