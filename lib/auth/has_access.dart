import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/expenditure/expenditure_form.dart';
import 'package:shop/exceptions/curropted_input.dart';
import 'package:shop/exceptions/not_handled_exception.dart';
import 'package:shop/shared/result_status.dart';

import 'auth_provider_sql.dart';

bool hasAccess({
  required AuthProviderSQL authProviderSQL,
  List<String?>? anyPermissions,
  List<String?>? vitalPermissions,
}) {
  // if both any and vital are empty: No Access
  // because they put accountPerm and it is null and it means access is denied
  // Not Working as expected!
  //  ????
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

  // if there is not anyPermissions it means access is blocked
  if (anyPermissions == null || anyPermissions.isEmpty) {
    return false;
  }

  // if anyPerms passed we return widget
  for (var anyPerm in anyPermissions) {
    if (authProviderSQL.isPermitted(anyPerm!)) return true;
  }

  // nether of anyParm not passed
  return false;
}

// X ver-1: flaw: don't check authority for accounts in voucher => depricated
// bool hasAccessToCredVoucher0({
//   required FormDuty formDuty,
//   required int voucherCreatorId,
//   required AccountModel account,
//   required AuthProviderSQL authProviderSQL,
// }) {
//   // TODO: remove me
//   return true;
//   // if there is no accountCredTransactionPermission: access is denied
//   switch (formDuty) {
//     case FormDuty.CREATE:
//       if (authProviderSQL.isPermitted(account.createTransactionPermission)) {
//         return true;
//       }
//       return false;
//     case FormDuty.READ:
//       if (authProviderSQL.isPermitted(account.readAllTransactionPermission)) {
//         return true;
//       }
//       if (authProviderSQL.isPermitted(account.readOwnTransactionPermission) &&
//           voucherCreatorId == authProviderSQL.authId) {
//         return true;
//       }
//       return false;
//     case FormDuty.EDIT:
//       if (authProviderSQL.isPermitted(account.editAllTransactionPermission)) {
//         return true;
//       }
//       if (authProviderSQL.isPermitted(account.editOwnTransactionPermission) &&
//           voucherCreatorId == authProviderSQL.authId) {
//         return true;
//       }
//       return false;
//     case FormDuty.DELETE:
//       if (authProviderSQL.isPermitted(account.deleteAllTransactionPermission)) {
//         return true;
//       }
//       if (authProviderSQL.isPermitted(account.deleteOwnTransactionPermission) &&
//           voucherCreatorId == authProviderSQL.authId) {
//         return true;
//       }
//       return false;
//     default:
//       throw NotHandledException(
//         'has_access.dart| hasAccessToAccountCredTransaction() 01| unexpected FormDuty Type: $formDuty',
//       );
//   }
// }

// X ver-2: flaw: don't return why not access => depricated
// Future<bool> hasCredAccessToVoucher0({
//   required FormDuty formDuty,
//   required VoucherModel voucher,
//   required AuthProviderSQL authProviderSQL,
//   required List<AccountModel?> helperAccounts,
// }) async {
//   // step#1 fetch all voucher's account
//   List<AccountModel?> voucherAccounts = [];
//   for (var accountId in voucher.myTransactionAccountIds()) {
//     if (accountId == null) continue;
//     if (helperAccounts.any(
//       (account) => (account != null && account.id == accountId),
//     )) {
//       voucherAccounts.add(
//         helperAccounts.firstWhere(
//           (account) => (account != null && account.id == accountId),
//         ),
//       );
//     } else {
//       AccountModel? vAccount = await AccountModel.fetchAccountById(accountId);
//       if (vAccount == null) {
//         throw CurroptedInputException(
//           'hasCredAccessToVoucher 01| we have a trans in voucher with no valid account: $accountId',
//         );
//       }
//       voucherAccounts.add(vAccount);
//     }
//   }
//   if (voucherAccounts.isEmpty || voucherAccounts.length < 2) {
//     throw CurroptedInputException(
//       'hasCredAccessToVoucher 02| we have not enough voucher account in voucher: ${voucher.id}',
//     );
//   }
//   // step#2 check authority according form-duty
//   switch (formDuty) {
//     case FormDuty.CREATE:
//       if (voucherAccounts.any(
//         (account) => authProviderSQL
//             .isNotPermitted(account!.createTransactionPermission),
//       )) return false;
//       return true;
//     case FormDuty.READ:
//       if (voucherAccounts.every(
//         (account) {
//           if (authProviderSQL
//               .isPermitted(account!.readAllTransactionPermission)) {
//             return true;
//           }
//           if (authProviderSQL
//                   .isPermitted(account.readOwnTransactionPermission) &&
//               voucher.creatorId == authProviderSQL.authId) {
//             return true;
//           }
//           return false;
//         },
//       )) return true;
//       return false;
//     case FormDuty.EDIT:
//       if (voucherAccounts.every(
//         (account) {
//           if (authProviderSQL
//               .isPermitted(account!.editAllTransactionPermission)) {
//             return true;
//           }
//           if (authProviderSQL
//                   .isPermitted(account.editOwnTransactionPermission) &&
//               voucher.creatorId == authProviderSQL.authId) {
//             return true;
//           }
//           return false;
//         },
//       )) return true;
//       return false;
//     case FormDuty.DELETE:
//       if (voucherAccounts.every(
//         (account) {
//           if (authProviderSQL
//               .isPermitted(account!.deleteAllTransactionPermission)) {
//             return true;
//           }
//           if (authProviderSQL
//                   .isPermitted(account.deleteOwnTransactionPermission) &&
//               voucher.creatorId == authProviderSQL.authId) {
//             return true;
//           }
//           return false;
//         },
//       )) return true;
//       return false;
//     default:
//       throw NotHandledException(
//         'has_access.dart| hasCredAccessToVoucher() 01| unexpected FormDuty Type: $formDuty',
//       );
//   }
// }

// ver-3: async: fetch account from db and check perms
Future<Result<bool>> hasCredAccessToVoucherFuture({
  required FormDuty formDuty,
  required VoucherModel voucher,
  required AuthProviderSQL authProviderSQL,
  required List<AccountModel?> helperAccounts,
}) async {
  // step#1 fetch all voucher's account
  List<AccountModel?> voucherAccounts = [];

  for (var accountId in voucher.myTransactionAccountIds()) {
    if (accountId == null) continue;
    if (helperAccounts.any(
      (account) => (account != null && account.id == accountId),
    )) {
      voucherAccounts.add(
        helperAccounts.firstWhere(
          (account) => (account != null && account.id == accountId),
        ),
      );
    } else {
      AccountModel? vAccount = await AccountModel.fetchAccountById(accountId);
      if (vAccount == null) {
        throw CurroptedInputException(
          'hasCredAccessToVoucher 01| we have a trans in voucher with no valid account: $accountId',
        );
      }
      voucherAccounts.add(vAccount);
    }
  }
  if (voucherAccounts.isEmpty || voucherAccounts.length < 2) {
    throw CurroptedInputException(
      'hasCredAccessToVoucher 02| we have not enough voucher account in voucher: ${voucher.id}',
    );
  }
  // step#2 check authority according form-duty
  switch (formDuty) {
    case FormDuty.CREATE:
      for (var vAcc in voucherAccounts) {
        if (authProviderSQL.isNotPermitted(vAcc!.createTransactionPermission))
          return Result(
            false,
            '${vAcc.createTransactionPermission} permission is not ocupied!',
          );
      }
      return Result(true);
    case FormDuty.READ:
      for (var vAcc in voucherAccounts) {
        if (authProviderSQL.isPermitted(vAcc!.readAllTransactionPermission)) {
          continue;
        } else if (authProviderSQL
                .isPermitted(vAcc.readOwnTransactionPermission) &&
            voucher.creatorId == authProviderSQL.authId) {
          continue;
        } else {
          return Result(
            false,
            '${vAcc.readAllTransactionPermission} or (${vAcc.readOwnTransactionPermission} && my-own-voucher ) permission is not qualified!',
          );
        }
      }
      return Result(true);
    case FormDuty.EDIT:
      for (var vAcc in voucherAccounts) {
        if (authProviderSQL.isPermitted(vAcc!.editAllTransactionPermission)) {
          continue;
        } else if (authProviderSQL
                .isPermitted(vAcc.editOwnTransactionPermission) &&
            voucher.creatorId == authProviderSQL.authId) {
          continue;
        } else {
          return Result(
            false,
            '${vAcc.editAllTransactionPermission} or (${vAcc.editOwnTransactionPermission} && my-own-voucher ) permission is not qualified!',
          );
        }
      }
      return Result(true);
    case FormDuty.DELETE:
      for (var vAcc in voucherAccounts) {
        if (authProviderSQL.isPermitted(vAcc!.deleteAllTransactionPermission)) {
          continue;
        } else if (authProviderSQL
                .isPermitted(vAcc.deleteOwnTransactionPermission) &&
            voucher.creatorId == authProviderSQL.authId) {
          continue;
        } else {
          return Result(
            false,
            '${vAcc.deleteAllTransactionPermission} or (${vAcc.deleteOwnTransactionPermission} && my-own-voucher ) permission is not qualified!',
          );
        }
      }
      return Result(true);
    default:
      throw NotHandledException(
        'has_access.dart| hasCredAccessToVoucher() 01| unexpected FormDuty Type: $formDuty',
      );
  }
}

// ver-4: sync: all tran should have account
Result<bool> hasCredAccessToVoucher({
  required FormDuty formDuty,
  required VoucherModel voucher,
  required AuthProviderSQL authProviderSQL,
}) {
  // step#1 check all voucher's account
  voucher.transactions.forEach(
    (tran) {
      if (tran == null || tran.account == null) {
        throw CurroptedInputException(
          'hasCredAccessToVoucher 02| we have not enough voucher account in voucher: ${voucher.id}',
        );
      }
    },
  );

  // step#2 check authority according form-duty
  switch (formDuty) {
    case FormDuty.CREATE:
      for (var tran in voucher.transactions) {
        if (authProviderSQL
            .isNotPermitted(tran!.account!.createTransactionPermission))
          return Result(
            false,
            '${tran.account!.createTransactionPermission} permission is not ocupied!',
          );
      }
      return Result(true);
    case FormDuty.READ:
      for (var tran in voucher.transactions) {
        if (authProviderSQL
            .isPermitted(tran!.account!.readAllTransactionPermission)) {
          continue;
        } else if (authProviderSQL
                .isPermitted(tran.account!.readOwnTransactionPermission) &&
            voucher.creatorId == authProviderSQL.authId) {
          continue;
        } else {
          return Result(
            false,
            '${tran.account!.readAllTransactionPermission} or (${tran.account!.readOwnTransactionPermission} && my-own-voucher ) permission is not qualified!',
          );
        }
      }
      return Result(true);
    case FormDuty.EDIT:
      for (var tran in voucher.transactions) {
        if (authProviderSQL
            .isPermitted(tran!.account!.editAllTransactionPermission)) {
          continue;
        } else if (authProviderSQL
                .isPermitted(tran.account!.editOwnTransactionPermission) &&
            voucher.creatorId == authProviderSQL.authId) {
          continue;
        } else {
          return Result(
            false,
            '${tran.account!.editAllTransactionPermission} or (${tran.account!.editOwnTransactionPermission} && my-own-voucher ) permission is not qualified!',
          );
        }
      }
      return Result(true);
    case FormDuty.DELETE:
      for (var tran in voucher.transactions) {
        if (authProviderSQL
            .isPermitted(tran!.account!.deleteAllTransactionPermission)) {
          continue;
        } else if (authProviderSQL
                .isPermitted(tran.account!.deleteOwnTransactionPermission) &&
            voucher.creatorId == authProviderSQL.authId) {
          continue;
        } else {
          return Result(
            false,
            '${tran.account!.deleteAllTransactionPermission} or (${tran.account!.deleteOwnTransactionPermission} && my-own-voucher ) permission is not qualified!',
          );
        }
      }
      return Result(true);
    default:
      throw NotHandledException(
        'has_access.dart| hasCredAccessToVoucher() 01| unexpected FormDuty Type: $formDuty',
      );
  }
}

bool hasAccessToAccount(
  AccountModel account,
  AuthProviderSQL authProviderSQL,
  FormDuty formDuty,
) {
  print('hasAccessToAccount() | ${hasAccess(
    authProviderSQL: authProviderSQL,
    anyPermissions: [account.createTransactionPermission],
  )}');
  print(
      'hasAccessToAccount() | account: ${account.createTransactionPermission}');
  // formDuty null means if any of Crud perm is qualified auth have permission
  if (formDuty == null) {
    // combine all permissions
    List<String> crudTransactionPermissionsAny = [];

    if (account.createTransactionPermission != null &&
        account.createTransactionPermission!.isNotEmpty) {
      crudTransactionPermissionsAny.add(
        account.createTransactionPermission!,
      );
    }
    if (account.readAllTransactionPermission != null &&
        account.readAllTransactionPermission!.isNotEmpty) {
      crudTransactionPermissionsAny.add(
        account.readAllTransactionPermission!,
      );
    }
    if (account.editAllTransactionPermission != null &&
        account.editAllTransactionPermission!.isNotEmpty) {
      crudTransactionPermissionsAny.add(
        account.editAllTransactionPermission!,
      );
    }
    if (account.deleteAllTransactionPermission != null &&
        account.deleteAllTransactionPermission!.isNotEmpty) {
      crudTransactionPermissionsAny.add(
        account.deleteAllTransactionPermission!,
      );
    }

    if (hasAccess(
      authProviderSQL: authProviderSQL,
      anyPermissions: crudTransactionPermissionsAny,
    )) return true;
  } else {
    // form duty is not null
    switch (formDuty) {
      case FormDuty.CREATE:
        return hasAccess(
          authProviderSQL: authProviderSQL,
          anyPermissions: [account.createTransactionPermission],
        );
      case FormDuty.READ:
        if (hasAccess(
          authProviderSQL: authProviderSQL,
          anyPermissions: [
            account.readAllTransactionPermission,
            account.readOwnTransactionPermission,
          ],
        )) return true;
        break;
      case FormDuty.EDIT:
        if (hasAccess(
          authProviderSQL: authProviderSQL,
          anyPermissions: [
            account.editAllTransactionPermission,
            account.editOwnTransactionPermission,
          ],
        )) return true;
        break;
      case FormDuty.DELETE:
        if (hasAccess(
          authProviderSQL: authProviderSQL,
          anyPermissions: [
            account.deleteAllTransactionPermission,
            account.deleteOwnTransactionPermission,
          ],
        )) return true;
        break;
      default:
        throw NotHandledException(
          'ACC_DRP_DWN 01| this type of FormDuty: $formDuty is not handled!',
        );
    }
  }
  return false;
}
