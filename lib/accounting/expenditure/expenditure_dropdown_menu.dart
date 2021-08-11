import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/classification/classification_form.dart';
import 'package:shop/accounting/accounting_logic/classification/transaction_classification.dart';

import 'expenditure_class_tree.dart';
import 'expenditure_screen_form.dart';

class ExpClassDropdownMenu extends StatefulWidget {
  final List<String?> unwantedExpClassIds;
  final List<String?> expandedExpClassIds;
  final Function(TransactionClassification) tapHandler;

  ExpClassDropdownMenu({
    required this.unwantedExpClassIds,
    required this.expandedExpClassIds,
    required this.tapHandler,
  });

  @override
  _ExpClassDropdownMenuState createState() => _ExpClassDropdownMenuState();
}

class _ExpClassDropdownMenuState extends State<ExpClassDropdownMenu> {
  late List<TransactionClassification> accounts;

  late TransactionClassification ledgerExpClass;
  bool vriablesAreInitialized = false;

  @override
  void initState() {
    _loadingStart();
    TransactionClassification.allTransactionClasses(ACCOUNTS_ID.EXPENDITURE_ACCOUNT_ID).then(
      (fetchExpClasss) {
        // print('ACC DRP init() 02| fetchExpClasss: $fetchExpClasss');
        _loadingEnd();
        // check null and Empty
        if (fetchExpClasss.isEmpty) {
          vriablesAreInitialized = false;
          return;
        }
        accounts = fetchExpClasss.cast<TransactionClassification>();

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
      print('ACC_DROP_MENU initState() 01| unable to fetchExpClass from db or assign it to variables; e: $e ');
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

  ExpansionTile _buildTileTree(TransactionClassification parent) {
    return ExpansionTile(
      childrenPadding: EdgeInsets.symmetric(horizontal: 5),
      initiallyExpanded: widget.expandedExpClassIds.contains(parent.id),
      title: Text(
        parent.titleEnglish,
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      trailing: FittedBox(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.account_tree_rounded),
              onPressed: () {
                // print('88 you want add child to ${parent.titleEnglish}');
                _showTranClassCreate(context, parent);
              },
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                print('88 you want edit ${parent.titleEnglish}');
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                print('88 you want delete ${parent.titleEnglish}');
              },
            ),
          ],
        ),
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
                    trailing: FittedBox(
                      // width: 50,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.account_tree_rounded),
                            onPressed: () {
                              // print('88 you want add child to ${child.titleEnglish}');
                              _showTranClassCreate(context, child);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              print('88 you want edit ${child.titleEnglish}');
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              print('88 you want delete ${child.titleEnglish}');
                            },
                          ),
                        ],
                      ),
                    ),
                    onTap: () => widget.tapHandler(child),
                  )
                : null;
          })
          .whereType<Widget>()
          .toList(),
    );
  }

  void _showTranClassCreate(BuildContext context, TransactionClassification parent) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Create new Transaction Class'),
            children: [
              Container(
                height: 700,
                child: ClassificationForm(
                  formDuty: FormDuty.CREATE,
                  parentClass: parent,
                  // notifyTranClassChanged: notifyNewVoucher,
                  notifyTranClassChanged: () {},
                ),
              ),
            ],
          );
        });
  }

  bool isParent(String accountId) {
    return accounts.any((account) => account.parentId == accountId);
  }

  List<TransactionClassification?> childs(String accountId) {
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
