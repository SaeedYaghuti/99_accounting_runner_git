import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/expenditure/expenditure_form.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/auth/has_access.dart';
import 'package:shop/exceptions/not_handled_exception.dart';

import 'account_ids.dart';

//  filter by auth perms
//  # hasAccess only for childs not parent
//  # if formDuty is empty it means if auth has one of crud_perm it has access

class AccountDropdownMenu extends StatefulWidget {
  final AuthProviderSQL authProvider;
  final FormDuty formDuty;
  final List<String?> unwantedAccountIds;
  final List<String?>? expandedAccountIds;
  final Function(AccountModel) tapHandler;

  AccountDropdownMenu({
    required this.authProvider,
    required this.formDuty,
    this.unwantedAccountIds = const [],
    this.expandedAccountIds,
    required this.tapHandler,
  });

  @override
  _AccountDropdownMenuState createState() => _AccountDropdownMenuState();
}

class _AccountDropdownMenuState extends State<AccountDropdownMenu> {
  late List<AccountModel> accounts;

  late AccountModel ledgerAccount;
  bool vriablesAreInitialized = false;

  @override
  void initState() {
    _loadingStart();
    AccountModel.allAccounts().then(
      (fetchAccounts) {
        // print('ACC DRP init() 02| fetchAccounts: $fetchAccounts');
        _loadingEnd();
        // check null and Empty
        if (fetchAccounts == null || fetchAccounts.isEmpty) {
          vriablesAreInitialized = false;
          return;
        }
        accounts = fetchAccounts.cast<AccountModel>();

        if (accounts.any((acc) => acc.id == ACCOUNTS_ID.LEDGER_ACCOUNT_ID)) {
          ledgerAccount = accounts.firstWhere(
            (acc) => acc.id == ACCOUNTS_ID.LEDGER_ACCOUNT_ID,
          );
          vriablesAreInitialized = true;
        } else {
          vriablesAreInitialized = false;
        }
      },
    ).catchError((e) {
      _loadingEnd();
      print(
        'ACC_DROP_MENU initState() 01| unable to fetchAccount from db or assign it to variables; e: $e ',
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'ACC_DRP_MENU | _build() | authProviderId: ${widget.authProvider.authId}');
    print('ACC_DRP_MENU | _build() | formDuty: ${widget.formDuty}');
    return Column(
      children: <Widget>[
        SizedBox(height: 20.0),
        _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : vriablesAreInitialized
                ? _buildTileTree(ledgerAccount)
                : Text('Unable to fetch Accounts'),
      ],
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       centerTitle: true,
  //       title: Text('Account Dropdown Menu'),
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 30.0),
  //       child: Column(
  //         children: <Widget>[
  //           SizedBox(height: 20.0),
  //           _isLoading
  //               ? Center(
  //                   child: CircularProgressIndicator(),
  //                 )
  //               : vriablesAreInitialized
  //                   ? _buildTileTree(ledgerAccount)
  //                   : Text('Unable to fetch Accounts'),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  ExpansionTile _buildTileTree(AccountModel parent) {
    return ExpansionTile(
      childrenPadding: EdgeInsets.symmetric(horizontal: 5),
      initiallyExpanded:
          widget.expandedAccountIds?.contains(parent.id) ?? false,
      title: Text(
        parent.titleEnglish,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: childs(parent.id)
          .map((child) {
            // parent should continue running recursively
            if (isParent(child!.id) &&
                !widget.unwantedAccountIds.contains(child.id))
              return _buildTileTree(child);

            // check permition for child
            return hasAccessToAccount(
                      child,
                      widget.authProvider,
                      widget.formDuty,
                    ) &&
                    !widget.unwantedAccountIds.contains(child.id)
                ? ListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.filter_tilt_shift_outlined,
                          size: 12,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(child.titleEnglish),
                      ],
                    ),
                    onTap: () => widget.tapHandler(child),
                  )
                : null;
          })
          .whereType<Widget>()
          .toList(),
    );
  }

  bool isParent(String accountId) {
    return accounts.any((account) => account.parentId == accountId);
  }

  List<AccountModel?> childs(String accountId) {
    return accounts.where((account) => account.parentId == accountId).toList();
  }

  bool _isLoading = false;

  void _loadingStart() {
    setState(() {
      _isLoading = true;
    });
  }

  void _loadingEnd() {
    setState(() {
      _isLoading = false;
    });
  }
}






// *** make tile by recursive method ***
// class AccountDropdownMenu extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text('Account Dropdown Menu'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 30.0),
//         child: Column(
//           children: <Widget>[
//             SizedBox(height: 20.0),
//             _buildTileTree(ACCOUNTS_TREE[0]),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ExpansionTile _buildTileTree(AccountModel parent) {
//   return ExpansionTile(
//     title: Text(
//       parent.titleEnglish,
//       style: TextStyle(
//         fontSize: 18.0,
//         fontWeight: FontWeight.bold,
//       ),
//     ),
//     children: childs(parent.id).map((child) {
//       if (isParent(child.id)) return _buildTileTree(child);

//       return ListTile(
//         title: Text(child.titleEnglish),
//       );
//     }).toList(),
//   );
// }



// *** make take manually ***
// class AccountDropdownMenu extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text('Account Dropdown Menu'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 30.0),
//         child: Column(
//           children: <Widget>[
//             SizedBox(height: 20.0),
//             ExpansionTile(
//               title: Text(
//                 "Accounts",
//                 style: TextStyle(
//                   fontSize: 18.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               children: <Widget>[
//                 ExpansionTile(
//                   title: Text(
//                     'Assets',
//                   ),
//                   children: <Widget>[
//                     ListTile(
//                       title: Text('nbo'),
//                     ),
//                     ListTile(
//                       title: Text('cash-drawer'),
//                     ),
//                   ],
//                 ),
//                 ListTile(
//                   title: Text('Expenditure'),
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }