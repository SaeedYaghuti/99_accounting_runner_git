import 'package:flutter/material.dart';
import 'package:shop/accounting/expenditure/expenditure_%20classification.dart';

import 'expenditure_classification_tree.dart';

//  filter by auth perms
//  # hasAccess only for childs not parent
//  # if formDuty is empty it means if auth has one of crud_perm it has access

class ExpClassDropdownMenu extends StatefulWidget {
  final List<String?> unwantedExpClassIds;
  final List<String?> expandedExpClassIds;
  final Function(ExpenditureClassification) tapHandler;

  ExpClassDropdownMenu({
    required this.unwantedExpClassIds,
    required this.expandedExpClassIds,
    required this.tapHandler,
  });

  @override
  _ExpClassDropdownMenuState createState() => _ExpClassDropdownMenuState();
}

class _ExpClassDropdownMenuState extends State<ExpClassDropdownMenu> {
  late List<ExpenditureClassification> accounts;

  late ExpenditureClassification ledgerExpClass;
  bool vriablesAreInitialized = false;

  @override
  void initState() {
    _loadingStart();
    ExpenditureClassification.allExpenditureClasses().then(
      (fetchExpClasss) {
        // print('ACC DRP init() 02| fetchExpClasss: $fetchExpClasss');
        _loadingEnd();
        // check null and Empty
        if (fetchExpClasss.isEmpty) {
          vriablesAreInitialized = false;
          return;
        }
        accounts = fetchExpClasss.cast<ExpenditureClassification>();

        if (accounts.any((acc) => acc.id == ExpClassIds.MAIN_EXP_CLASS_ID)) {
          ledgerExpClass = accounts.firstWhere(
            (acc) => acc.id == ExpClassIds.MAIN_EXP_CLASS_ID,
          );
          vriablesAreInitialized = true;
        } else {
          vriablesAreInitialized = false;
        }
      },
    ).catchError((e) {
      _loadingEnd();
      print(
        'ACC_DROP_MENU initState() 01| unable to fetchExpClass from db or assign it to variables; e: $e ',
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(
    //   'ACC_DRP_MENU | _build() | authProviderId: ${widget.authProvider.authId}',
    // );
    // print('ACC_DRP_MENU | _build() | formDuty: ${widget.formDuty}');
    return Column(
      children: <Widget>[
        SizedBox(height: 20.0),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : vriablesAreInitialized
                ? _buildTileTree(ledgerExpClass)
                : Text('Unable to fetch ExpClasss'),
      ],
    );
  }

  ExpansionTile _buildTileTree(ExpenditureClassification parent) {
    return ExpansionTile(
      childrenPadding: EdgeInsets.symmetric(horizontal: 5),
      initiallyExpanded: widget.expandedExpClassIds.contains(parent.id),
      title: Text(
        parent.titleEnglish,
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      children: childs(parent.id)
          .map((child) {
            // parent should continue running recursively
            if (isParent(child!.id) && !widget.unwantedExpClassIds.contains(child.id)) {
              return _buildTileTree(child);
            }

            // check permition for child
            return !widget.unwantedExpClassIds.contains(child.id)
                ? ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.filter_tilt_shift_outlined, size: 12),
                        SizedBox(width: 3),
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

  List<ExpenditureClassification?> childs(String accountId) {
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
