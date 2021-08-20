import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/accounting_logic/classification/classification_form.dart';
import 'package:shop/accounting/accounting_logic/classification/classification_types.dart';
import 'package:shop/accounting/accounting_logic/classification/transaction_classification.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/auth/has_access.dart';
import 'package:shop/auth/permission_model.dart';
import 'package:shop/exceptions/curropted_input.dart';
import 'package:shop/exceptions/not_handled_exception.dart';
import 'package:shop/shared/confirm_dialog.dart';
import 'package:shop/shared/result_status.dart';
import 'package:shop/shared/show_error_dialog.dart';

import '../../expenditure/expenditure_class_tree.dart';
import '../../expenditure/expenditure_screen_form.dart';
import '../voucher_model.dart';

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
  late AuthProviderSQL authProvider;

  late TransactionClassification ledgerExpClass;
  bool vriablesAreInitialized = false;

  @override
  void initState() {
    _initializeState();
    super.initState();
  }

  void _initializeState() {
    _loadingStart();
    TransactionClassification.allClasses(ClassificationTypes.EXPENDITURE_TYPE).then(
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

  @override
  void didChangeDependencies() {
    authProvider = Provider.of<AuthProviderSQL>(context, listen: true);
    super.didChangeDependencies();
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
      trailing: _buildTrailingIcons(parent, true),
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
                    trailing: _buildTrailingIcons(child),
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

  Widget _buildTrailingIcons(TransactionClassification tranClass, [isParent = false]) {
    return FittedBox(
      // width: 50,
      child: Row(
        children: [
          // ## Parent
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
          // ## Add
          IconButton(
            icon: Icon(
              Icons.account_tree_outlined,
              color: classIsBold(tranClass)
                  ? Colors.blue
                  : isParent
                      ? Theme.of(context).accentColor.withOpacity(0.8)
                      : Colors.black45,
            ),
            onPressed: () => _showTranClassCreateForm(context, formParent: tranClass),
          ),
          // ## Edit
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: classIsBold(tranClass)
                  ? Colors.blue
                  : isParent
                      ? Theme.of(context).accentColor.withOpacity(0.8)
                      : Colors.black45,
            ),
            onPressed: () => _showTranClassEditForm(context, tranClass),
          ),
          // ## Delete
          // if (!isParent)
          IconButton(
            icon: Icon(
              // Icons.delete,
              Icons.delete_outlined,
              color: classIsBold(tranClass)
                  ? Colors.blue
                  : isParent
                      ? Theme.of(context).accentColor.withOpacity(0.8)
                      : Colors.black45,
            ),
            onPressed: () async {
              // print('88 you want delete ${tranClass.titleEnglish}');
              // print('ES 80| you delete ...');
              var confirmResult = await confirmDialog(
                context: context,
                title: 'Are sure to delete this classification?',
                content: 'This would delete "${tranClass.titleEnglish}" from database!',
                noTitle: 'No',
                yesTitle: 'Delete it!',
              );
              // print('ES 70| confirmResult: $confirmResult');
              if (confirmResult == true) {
                // print('TRN_CLSS_DDM| 90| YOU confirmed to delete!');
                await _doTranClassDeleteForm(context, tranClass);
              }
            },
          ),
          _buildClassActionMenu(tranClass, isParent),
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

  Future<void> _doTranClassDeleteForm(BuildContext context, TransactionClassification tranClass) async {
    // print('TRN_CLASS_DDM| _showTranClassDeleteForm() 01| run...');
    var parent = await TransactionClassification.fetchClassById(tranClass.parentId);
    if (parent == null) {
      throw CurroptedInputException(
        'TRN_CLSS_DDM | _showTranClassDeleteForm() 01| unable to fetch tranClass with id: ${tranClass.parentId}',
      );
    }
    _loadingStart();
    try {
      var authProviderSQL = Provider.of<AuthProviderSQL>(context, listen: false);
      var deleteResult = await tranClass.deleteMeFromDB(authProviderSQL);
      _loadingEnd();
      // print('CLSS_FORM | initStateDelete() 01 | deleteResult: $deleteResult');
      notifyTranClassChanged(parent);
    } catch (e) {
      _loadingEnd();
      print('TRN_CLSS_DDM | _showTranClassDeleteForm() 02 | @ catheError() e: $e');
      showErrorDialog(
        context,
        'tranClass .deleteMeFromDB()',
        'ClassificationForm at initState while deleting a tranClass happend error:',
        e,
      );
    }

    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return SimpleDialog(
    //       title: Text('Delete Transaction Class'),
    //       children: [
    //         Container(
    //           height: 700,
    //           child: ClassificationForm(
    //             formDuty: FormDuty.DELETE,
    //             parentClass: parent,
    //             tranClass: tranClass,
    //             notifyTranClassChanged: notifyTranClassChanged,
    //           ),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  Widget _buildClassActionMenu(TransactionClassification tranClass, [isParent = false]) {
    // we don't have any perm: return block icon
    if (authProvider.isNotPermitted(PermissionModel.TRANSACTION_CLASS_CRED)) {
      // print(
      //   'TRN_CLSS_DDM | 33 _buildEditDeletePopupMenueCell() | not have access to \nedit: ${hasAccessToEdit.errorMessage} \n:delete: ${hasAccessToDelete.errorMessage}',
      // );
      return Icon(Icons.block_rounded);
    }

    // we have at list one perm:
    return GestureDetector(
      child: Icon(Icons.more_vert),
      onTapDown: (TapDownDetails details) async {
        // rebuildExpForm(
        //   voucher,
        //   expTranId,
        //   FormDuty.CREATE,
        // );
        await _showActionsPopup(
          offset: details.globalPosition,
          showEdit: true,
          showDelete: true,
          tranClass: tranClass,
          isParent: isParent,
        );
      },
    );
  }

  _showActionsPopup(
      {required Offset offset,
      required bool showEdit,
      required bool showDelete,
      required TransactionClassification tranClass,
      bool isParent = false}) async {
    double left = offset.dx;
    double top = offset.dy;
    String? selectedItem = await showMenu<String>(
      elevation: 8.0,
      context: context,
      position: RelativeRect.fromLTRB(left, top, left, top),
      items: [
        if (showEdit)
          PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  color: Colors.green[300],
                ),
                SizedBox(width: 10),
                Text(
                  'Add child',
                  style: TextStyle(
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            value: 'add_child',
          ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Text(
                'Edit',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          value: 'edit',
        ),
        if (showDelete)
          PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  Icons.delete_outlined,
                  color: isParent ? Colors.black45 : Theme.of(context).accentColor.withOpacity(0.8),
                ),
                SizedBox(width: 10),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: isParent ? Colors.black45 : Theme.of(context).accentColor,
                  ),
                ),
              ],
            ),
            value: isParent ? 'disable_delete' : 'delete',
          ),
      ],
    );
    if (selectedItem == null) {
      // print('ES 80| you select nothing ...');
      // rebuildExpForm(null, null, null);
      return;
    }

    if (selectedItem == "add_child") {
      // print('ES 80| you edit ...');
      _showTranClassCreateForm(context, formParent: tranClass);
    } else if (selectedItem == "edit") {
      _showTranClassEditForm(context, tranClass);
    } else if (selectedItem == "delete") {
      // print('ES 80| you delete ...');
      var confirmResult = await confirmDialog(
        context: context,
        title: 'Are sure to delete this expense?',
        content: 'This would delete voucher and all it is transactions from database',
        noTitle: 'No',
        yesTitle: 'Delete it!',
      );
      // print('ES 70| confirmResult: $confirmResult');
      if (confirmResult == true) {
        // rebuildExpForm(
        //   voucher,
        //   expTranId,
        //   FormDuty.DELETE,
        // );
      }
    } else if (selectedItem == "disable_delete") {
      // print('ES 80| you delete ...');
      var confirmResult = await confirmDialog(
        context: context,
        title: 'You can not Delete',
        content: 'This item is Parent and until it has child you can not delete it',
        noTitle: '',
        yesTitle: 'OK',
      );
      // print('ES 70| confirmResult: $confirmResult');
      if (confirmResult == true) {
        // rebuildExpForm(
        //   voucher,
        //   expTranId,
        //   FormDuty.DELETE,
        // );
      }
    } else {
      throw NotHandledException('ES 80| ');
    }
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
