import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/transaction_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/expenditure/expenditure_form.dart';
import 'package:shop/exceptions/not_handled_exception.dart';

import 'auth_provider_sql.dart';

bool hasAccess({
  required AuthProviderSQL authProviderSQL,
  List<String?>? anyPermissions,
  List<String?>? vitalPermissions,
}) {
  return true;

  // if both any and vital are empty: No Access
  // because they put accountPerm and it is null and it means access is denied
  if ((vitalPermissions == null || vitalPermissions.isEmpty) &&
      (anyPermissions == null || anyPermissions.isEmpty)) {
    return false;
  }

  // if there is no vitalPerm we should check anyPermissions
  if (vitalPermissions != null && vitalPermissions.isNotEmpty) {
    // if any of vitalPerm not satisfied we return false
    for (var vPerm in vitalPermissions) {
      if (!authProviderSQL.isPermitted(vPerm!)) return false;
    }
  }
  // vaital are passed!

  // if there is not anyPermissions it means OK
  if (anyPermissions == null || anyPermissions.isEmpty) {
    return true;
  }

  // if anyPerms passed we return widget
  for (var anyPerm in anyPermissions) {
    if (authProviderSQL.isPermitted(anyPerm!)) return true;
  }

  // nether of anyParm not passed
  return false;
}

bool hasAccessToAccountCredTransaction({
  required AuthProviderSQL authProviderSQL,
  required int voucherCreatorId,
  required FormDuty formDuty,
  required AccountModel account,
}) {
  return true;
  // if there is no accountCredTransactionPermission: access is denied
  switch (formDuty) {
    case FormDuty.CREATE:
      if (authProviderSQL.isPermitted(account.createTransactionPermission)) {
        return true;
      }
      return false;
    case FormDuty.READ:
      if (authProviderSQL.isPermitted(account.readAllTransactionPermission)) {
        return true;
      }
      if (authProviderSQL.isPermitted(account.readOwnTransactionPermission) &&
          voucherCreatorId == authProviderSQL.authId) {
        return true;
      }
      return false;
    case FormDuty.EDIT:
      if (authProviderSQL.isPermitted(account.editAllTransactionPermission)) {
        return true;
      }
      if (authProviderSQL.isPermitted(account.editOwnTransactionPermission) &&
          voucherCreatorId == authProviderSQL.authId) {
        return true;
      }
      return false;
    case FormDuty.DELETE:
      if (authProviderSQL.isPermitted(account.deleteAllTransactionPermission)) {
        return true;
      }
      if (authProviderSQL.isPermitted(account.deleteOwnTransactionPermission) &&
          voucherCreatorId == authProviderSQL.authId) {
        return true;
      }
      return false;
    default:
      throw NotHandledException(
        'has_access.dart| hasAccessToAccountCredTransaction() 01| unexpected FormDuty Type: $formDuty',
      );
  }
}
