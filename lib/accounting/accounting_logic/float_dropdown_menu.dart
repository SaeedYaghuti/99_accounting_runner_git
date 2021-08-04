import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/floating_account.dart';
import 'package:shop/accounting/accounting_logic/floating_account_tree.dart';
import 'package:shop/accounting/expenditure/expenditure_screen_form.dart';
import 'package:shop/auth/auth_provider_sql.dart';

class AccountDropdownMenu extends StatefulWidget {
  final AuthProviderSQL authProvider;
  final FormDuty formDuty;
  final List<String?> unwantedAccountIds;
  final List<String?>? expandedAccountIds;
  final Function(FloatingAccount) tapHandler;

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
  late List<FloatingAccount> floatAccounts;

  late FloatingAccount rootFloatAccount;
  bool vriablesAreInitialized = false;

  @override
  void initState() {
    _loadingStart();
    FloatingAccount.allFloatAccounts().then(
      (fetchFloats) {
        _loadingEnd();

        if (fetchFloats.isEmpty) {
          vriablesAreInitialized = false;
          return;
        }
        // floatAccounts = fetchFloats.cast<FloatingAccount>();
        floatAccounts = fetchFloats.whereType<FloatingAccount>().toList();

        if (floatAccounts.any((acc) => acc.id == FloatAccountIds.ROOT_FLOAT_ACCOUNT_ID)) {
          rootFloatAccount = floatAccounts.firstWhere(
            (acc) => acc.id == FloatAccountIds.ROOT_FLOAT_ACCOUNT_ID,
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
    // print(
    //   'FLT_ACC_DRP_MENU | _build() | authProviderId: ${widget.authProvider.authId}',
    // );
    // print('FLT_ACC_DRP_MENU | _build() | formDuty: ${widget.formDuty}');
    return Column(
      children: <Widget>[
        SizedBox(height: 20.0),
        _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : vriablesAreInitialized
                ? _buildTileTree(rootFloatAccount)
                : Text('Unable to fetch Floating Accounts from database'),
      ],
    );
  }

  ExpansionTile _buildTileTree(FloatingAccount parent) {
    return ExpansionTile(
      childrenPadding: EdgeInsets.symmetric(horizontal: 5),
      initiallyExpanded: widget.expandedAccountIds?.contains(parent.id) ?? false,
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
            if (isParent(child!.id) && !widget.unwantedAccountIds.contains(child.id)) return _buildTileTree(child);

            // check permition for child
            // return hasAccessToAccount(
            //           child,
            //           widget.authProvider,
            //           widget.formDuty,
            //         ) &&
            //         !widget.unwantedAccountIds.contains(child.id)
            return !widget.unwantedAccountIds.contains(child.id)
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

  bool isParent(String floatId) {
    return floatAccounts.any((float) => float.parentId == floatId);
  }

  List<FloatingAccount?> childs(String floatId) {
    return floatAccounts.where((float) => float.parentId == floatId).toList();
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
