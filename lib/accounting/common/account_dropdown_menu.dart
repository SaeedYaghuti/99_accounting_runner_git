import 'package:flutter/material.dart';

// TODO: convert accounts to Dropdown Menu
// 1# definition of accounts tree

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
            ExpansionTile(
              title: Text(
                "Accounts",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: <Widget>[
                ExpansionTile(
                  title: Text(
                    'Assets',
                  ),
                  children: <Widget>[
                    ListTile(
                      title: Text('nbo'),
                    ),
                    ListTile(
                      title: Text('cash-drawer'),
                    ),
                  ],
                ),
                ListTile(
                  title: Text('Expenditure'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
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
//                 "Title",
//                 style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//               ),
//               children: <Widget>[
//                 ExpansionTile(
//                   title: Text(
//                     'Sub title',
//                   ),
//                   children: <Widget>[
//                     ListTile(
//                       title: Text('data'),
//                     )
//                   ],
//                 ),
//                 ListTile(
//                   title: Text('data'),
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

