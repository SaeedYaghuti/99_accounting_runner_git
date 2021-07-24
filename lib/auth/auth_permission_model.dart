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

  static Future<List<AuthPermissionModel?>?> allPermissionsForAuth(
    int authId,
  ) async {
    final query = '''
    SELECT *
    FROM $tableName
    WHERE $tableName.$column2AuthId = ?
    ''';
    try {
      var result = await AuthDB.runRawQuery(query, [authId]);
      if (result.length == 0) {
        print(
          'ATH_PERM allPermForAth 01| auth $authId don\'t have any permissions',
        );
        return [];
      } else {
        return result
            .map((authPermMap) => fromMapOfAuthPermission(authPermMap))
            .toList();
      }
      // print('TM11| SELECT * FROM $transactionTableName for $accountId>');
      // print(result);
    } catch (e) {
      print(
        'ATH_PERM allPermForAth 10| @ catch e: $e',
      );
    }
  }

  static Future<AuthPermissionModel?> fetchPermissionById(
    String permId,
  ) async {
    final query = '''
    SELECT *
    FROM $tableName
    WHERE $column1Id = ?
    ''';
    try {
      var result = await AuthDB.runRawQuery(query, [permId]);
      if (result.length == 0) {
        print(
          'ATH_PERM fetchPermissionById 01| not found any auth_perm for $permId',
        );
        return null;
      } else {
        var perm = fromMapOfAuthPermission(result[0]);
        print('ATH_PRM_MDL | fetchPermissionById() 01| auth-perm: $perm');
      }
    } catch (e) {
      print(
        'ATH_PERM fetchPermissionById 10| @ catch e: $e',
      );
    }
  }

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

  static Future<void> givePermissionToAuth(
    int authId,
    String permissionId,
  ) async {
    try {
      // INSERT OR REPLACE INTO $tableName ($column2AuthId, $column3PermissionId)
      // INSERT INTO $tableName ($column2AuthId, $column3PermissionId)
      var query = ''' 
        INSERT OR REPLACE INTO $tableName ($column2AuthId, $column3PermissionId)
        VALUES ($authId, '$permissionId');
        ''';
      await AuthDB.runRawQuery(query);
    } catch (e) {
      print('AuthPerm perm_first_auth 01| e: $e');
      throw e;
    }
  }

  static Future<int> deleteAllPermissionsOfAuth(
    int authId,
  ) async {
    if (authId == null) {
      return 0;
    }
    final query = '''
    DELETE FROM $tableName
    WHERE $column2AuthId = ? ;
    ''';
    try {
      var count = await AuthDB.deleteRawQuery(query, [authId]);
      // print(
      //   'ATH_PEM_MDL | deleteAllPermissionsOfAuth 01| $count row deleted for authId: $authId;',
      // );
      return count;
    } catch (e) {
      print('ATH_PEM_MDL | deleteAllPermissionsOfAuth 02| e: $e');
      throw e;
    }
  }

  static Future<void> givePermissionsToAuth(
    int authId,
    List<String> permissionIds,
  ) async {
    try {
      for (var permId in permissionIds) {
        await AuthPermissionModel.givePermissionToAuth(authId, permId);
        // var authPerm = AuthPermissionModel(
        //   authId: authId,
        //   permissionId: permId,
        // );
        // await AuthDB.insert(tableName, authPerm.toMap());
      }
    } catch (e) {
      print('AuthPerm give_perms_to_auth 01| e: $e');
      throw e;
    }
  }

  static Future<void> resetAuthPermissions(
    int authId,
    List<String> permissionIds,
  ) async {
    try {
      await AuthPermissionModel.deleteAllPermissionsOfAuth(authId);
      await givePermissionsToAuth(authId, permissionIds);
    } catch (e) {
      print('ATH_PEM_MDL | resetAuthPermissions() 01| e: $e');
      throw e;
    }
  }

  static Future<void> printAllAuthPermissions([int? authId]) async {
    var query = '''
      SELECT *
      FROM $tableName
      ''';

    if (authId != null) {
      query = '''
        SELECT *
        FROM $tableName
        WHERE $column2AuthId = $authId
        ''';
    }

    var authPermsMap = await AuthDB.runRawQuery(query);

    print('ATH_PERM_MDL printAllAuthPERM 01| All DB AuthPerms: ###########');
    // print(authPermsMap.length);
    print(authPermsMap.map((perm) => perm['authperm_permission_id']).toList());
    // print('##################');
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
    CONSTRAINT fk_${PermissionModel.tableName} FOREIGN KEY ($column3PermissionId) REFERENCES ${PermissionModel.tableName} (${PermissionModel.column1Id}) ON DELETE CASCADE,
    CONSTRAINT uq_permission UNIQUE ($column2AuthId, $column3PermissionId)
  )''';

  static AuthPermissionModel fromMapOfAuthPermission(
    Map<String, Object?> dbResult,
  ) {
    var authPermission = AuthPermissionModel(
      id: dbResult[AuthPermissionModel.column1Id] as int,
      authId: dbResult[AuthPermissionModel.column2AuthId] as int,
      permissionId: dbResult[AuthPermissionModel.column3PermissionId] as String,
    );
    // print('ATH_PERM_MDL fromMap 01| All DB authPermission');
    // print(authPermission);

    return authPermission;
  }

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
