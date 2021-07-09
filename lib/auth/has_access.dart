import 'auth_provider_sql.dart';

bool hasAccess(
  AuthProviderSQL authProviderSQL,
  List<String?>? vitalPermissions,
  List<String?>? anyPermissions,
) {
  // if there is no vitalPerm we should check anyPermissions
  if (vitalPermissions != null && vitalPermissions!.isNotEmpty) {
    // if any of vitalPerm not satisfied we return notPermittedWidget
    for (var vPerm in vitalPermissions) {
      if (!authProviderSQL.isPermitted(vPerm!)) return false;
    }
  }
  // now vaital are passed;

  // if there is not anyPermissions it means OK
  if (anyPermissions == null && anyPermissions!.isEmpty) {
    return true;
  }

  // if anyPerms passed we return widget
  for (var anyPerm in anyPermissions) {
    if (authProviderSQL.isPermitted(anyPerm!)) return true;
  }

  // nether of anyParm not passed
  return false;
}
