import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_ids.dart';
import 'package:shop/accounting/accounting_logic/classification/classification_form.dart';
import 'package:shop/accounting/accounting_logic/classification/classification_types.dart';
import 'package:shop/accounting/accounting_logic/classification/transaction_classification.dart';

import '../../expenditure/expenditure_class_tree.dart';
import '../../expenditure/expenditure_screen_form.dart';

class TranClassDropdownMenu extends StatefulWidget {
  final List<String?> unwantedTranClassIds;
  List<String?> expandedTranClassIds;
  final Function(TransactionClassification) tapHandler;
  final bool selectableParent;

  TranClassDropdownMenu({
    required this.unwantedTranClassIds,
    required this.expandedTranClassIds,
    required this.tapHandler,
    this.selectableParent = false,
  });

  @override
  _TranClassDropdownMenuState createState() => _TranClassDropdownMenuState();
}

class _TranClassDropdownMenuState extends State<TranClassDropdownMenu> {
  late List<TransactionClassification> tranClasses;
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
    TransactionClassification.allTransactionClasses(ClassificationTypes.EXPENDITURE_TYPE).then(
      (fetchExpClasss) {
        // print('ACC DRP init() 02| fetchExpClasss: $fetchExpClasss');
        _loadingEnd();
        // check null and Empty
        if (fetchExpClasss.isEmpty) {
          vriablesAreInitialized = false;
          return;
        }
        tranClasses = fetchExpClasss.cast<TransactionClassification>();

        if (tranClasses.any((acc) => acc.id == ExpClassIds.EXP_ROOT_CLASS_ID)) {
          ledgerExpClass = tranClasses.firstWhere(
            (acc) => acc.id == ExpClassIds.EXP_ROOT_CLASS_ID,
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
          widget.expandedTranClassIds.contains(parent.id) || boldTranClasses.any((bold) => bold.parentId == parent.id),
      title: Text(
        parent.titleEnglish,
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      trailing: _buildTrailingCredIcon(parent, true),
      children: childs(parent.id!)
          .map((child) {
            // parent should continue running recursively
            if (isParent(child!.id!) && !widget.unwantedTranClassIds.contains(child.id)) {
              return _buildTileTree(child);
            }
            // check permition for child
            return !widget.unwantedTranClassIds.contains(child.id)
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
          // button: select parent
          if (isParent && widget.selectableParent)
            IconButton(
              icon: Icon(
                Icons.touch_app_outlined,
                color: classIsBold(tranClass)
                    ? Colors.blue
                    : isParent
                        ? Theme.of(context).accentColor.withOpacity(0.8)
                        : Colors.black45,
              ),
              onPressed: () => widget.tapHandler(tranClass),
            ),
          // button: add child
          IconButton(
            icon: Icon(
              Icons.account_tree_rounded,
              color: classIsBold(tranClass)
                  ? Colors.blue
                  : isParent
                      ? Theme.of(context).accentColor.withOpacity(0.8)
                      : Colors.black45,
            ),
            onPressed: () => _showTranClassCreateForm(context, formParent: tranClass),
          ),
          // button: edit
          IconButton(
            icon: Icon(
              Icons.edit,
              color: classIsBold(tranClass)
                  ? Colors.blue
                  : isParent
                      ? Theme.of(context).accentColor.withOpacity(0.8)
                      : Colors.black45,
            ),
            onPressed: () => _showTranClassEditForm(context, tranClass),
          ),
          // button: delete
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

  void _showTranClassCreateForm(BuildContext context, {required TransactionClassification formParent}) {
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
                  parentClass: formParent,
                  notifyTranClassChanged: notifyTranClassChanged,
                ),
              ),
            ],
          );
        });
  }

  void _showTranClassEditForm(BuildContext context, TransactionClassification tranClass) {
    var parentClass = tranClassById(tranClass.parentId);
    // print('TRN_CLSS_DDM | _showTranClassEditForm() | parentClass: $parentClass');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Edit Transaction Class'),
          children: [
            Container(
              height: 700,
              child: ClassificationForm(
                formDuty: FormDuty.EDIT,
                parentClass: parentClass,
                tranClass: tranClass,
                notifyTranClassChanged: notifyTranClassChanged,
              ),
            ),
          ],
        );
      },
    );
  }

  TransactionClassification tranClassById(String classId) {
    return tranClasses.firstWhere((tranClass) => tranClass.id == classId);
  }

  bool isParent(String classId) {
    return tranClasses.any((account) => account.parentId == classId);
  }

  List<TransactionClassification?> childs(String accountId) {
    return tranClasses.where((account) => account.parentId == accountId).toList();
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
