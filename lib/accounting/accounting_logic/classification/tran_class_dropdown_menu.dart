import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/classification/classification_form.dart';
import 'package:shop/accounting/accounting_logic/classification/transaction_classification.dart';

import '../../expenditure/expenditure_class_tree.dart';
import '../../expenditure/expenditure_screen_form.dart';

class TranClassDropdownMenu extends StatefulWidget {
  final List<String?> unwantedExpClassIds;
  List<String?> expandedExpClassIds;
  final Function(TransactionClassification) tapHandler;

  TranClassDropdownMenu({
    required this.unwantedExpClassIds,
    required this.expandedExpClassIds,
    required this.tapHandler,
  });

  @override
  _TranClassDropdownMenuState createState() => _TranClassDropdownMenuState();
}

class _TranClassDropdownMenuState extends State<TranClassDropdownMenu> {
  late List<TransactionClassification> accounts;
  List<TransactionClassification> boldTranClasses = [];

  late TransactionClassification ledgerExpClass;
  bool vriablesAreInitialized = false;

  @override
  void initState() {
    _initializeState();
    super.initState();
  }

  void _initializeState() {
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
      throw e;
    });
  }

  void notifyTranClassChanged(TransactionClassification? tranClass) {
    if (tranClass != null) boldTranClasses.add(tranClass);
    _initializeState();
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
      initiallyExpanded:
          widget.expandedExpClassIds.contains(parent.id) || boldTranClasses.any((bold) => bold.parentId == parent.id),
      title: Text(
        parent.titleEnglish,
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      trailing: _buildTrailingCredIcon(parent, true),
      children: childs(parent.id!)
          .map((child) {
            // parent should continue running recursively
            if (isParent(child!.id!) && !widget.unwantedExpClassIds.contains(child.id)) {
              return _buildTileTree(child);
            }
            // check permition for child
            return !widget.unwantedExpClassIds.contains(child.id)
                ? ListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.filter_tilt_shift_outlined,
                          size: 12,
                          color: classIsBold(child) ? Colors.blue : Colors.black87,
                        ),
                        SizedBox(width: 3),
                        Text(
                          child.titleEnglish,
                          style: TextStyle(
                            color: classIsBold(child) ? Colors.blue : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    trailing: _buildTrailingCredIcon(child),
                    onTap: () => widget.tapHandler(child),
                  )
                : null;
          })
          .whereType<Widget>()
          .toList(),
    );
  }

  bool classIsBold(TransactionClassification tranClass) {
    return boldTranClasses.any((bold) => bold.id == tranClass.id);
  }

  Widget _buildTrailingCredIcon(TransactionClassification tranClass, [isParent = false]) {
    return FittedBox(
      // width: 50,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.account_tree_rounded,
              color: classIsBold(tranClass)
                  ? Colors.blue
                  : isParent
                      ? Theme.of(context).accentColor.withOpacity(0.8)
                      : Colors.black45,
            ),
            onPressed: () {
              // print('88 you want add child to ${child.titleEnglish}');
              // Navigator.pop(context);
              _showTranClassCreateForm(context, tranClass);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: classIsBold(tranClass)
                  ? Colors.blue
                  : isParent
                      ? Theme.of(context).accentColor.withOpacity(0.8)
                      : Colors.black45,
            ),
            onPressed: () {
              print('88 you want edit ${tranClass.titleEnglish}');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: classIsBold(tranClass)
                  ? Colors.blue
                  : isParent
                      ? Theme.of(context).accentColor.withOpacity(0.8)
                      : Colors.black45,
            ),
            onPressed: () {
              print('88 you want delete ${tranClass.titleEnglish}');
            },
          ),
        ],
      ),
    );
  }

  void _showTranClassCreateForm(BuildContext context, TransactionClassification parent) {
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
                  notifyTranClassChanged: notifyTranClassChanged,
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
