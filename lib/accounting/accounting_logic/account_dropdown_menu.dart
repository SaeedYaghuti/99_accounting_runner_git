import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/accounts_tree.dart';

// TODO: convert accounts_tree to Dropdown Menu
// 1# start from Ledger_account and make Tile

class AccountDropdownMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Account Dropdown Menu'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20.0),
            _buildTileTree(ACCOUNTS_TREE[0]),
          ],
        ),
      ),
    );
  }
}

ExpansionTile _buildTileTree(AccountModel parent) {
  return ExpansionTile(
    title: Text(
      parent.titleEnglish,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    children: childs(parent.id).map((child) {
      if (isParent(child.id)) return _buildTileTree(child);

      return ListTile(
        title: Text(child.titleEnglish),
      );
    }).toList(),
  );
}

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