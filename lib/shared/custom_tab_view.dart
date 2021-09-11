import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/float/float_dropdown_menu.dart';
import 'package:shop/accounting/accounting_logic/float/floating_account.dart';
import 'package:shop/accounting/accounting_logic/float/floating_account_tree.dart';
import 'package:shop/accounting/expenditure/expenditure_screen_form.dart';
import 'package:shop/auth/auth_provider_sql.dart';

class CustomTabView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder tabBuilder;
  final IndexedWidgetBuilder pageBuilder;
  final Widget? stub;
  final ValueChanged<int>? onPositionChange;
  final ValueChanged<double>? onScroll;
  final int? initPosition;

  CustomTabView({
    required this.itemCount,
    required this.tabBuilder,
    required this.pageBuilder,
    this.stub,
    this.onPositionChange,
    this.onScroll,
    this.initPosition,
  });

  @override
  _CustomTabsState createState() => _CustomTabsState();
}

class _CustomTabsState extends State<CustomTabView> with TickerProviderStateMixin {
  late TabController controller;
  late int _currentCount;
  late int _currentPosition;

  @override
  void initState() {
    _currentPosition = widget.initPosition ?? 0;
    controller = TabController(
      length: widget.itemCount,
      vsync: this,
      initialIndex: _currentPosition,
    );
    controller.addListener(onPositionChange);
    controller.animation?.addListener(onScroll);
    _currentCount = widget.itemCount;
    super.initState();
  }

  @override
  void didUpdateWidget(CustomTabView oldWidget) {
    if (_currentCount != widget.itemCount) {
      controller.animation?.removeListener(onScroll);
      controller.removeListener(onPositionChange);
      controller.dispose();

      if (widget.initPosition != null) {
        _currentPosition = widget.initPosition!;
      }

      if (_currentPosition > widget.itemCount - 1) {
        _currentPosition = widget.itemCount - 1;
        _currentPosition = _currentPosition < 0 ? 0 : _currentPosition;
        if (widget.onPositionChange is ValueChanged<int>) {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            if (mounted) {
              widget.onPositionChange!(_currentPosition);
            }
          });
        }
      }

      _currentCount = widget.itemCount;
      setState(() {
        controller = TabController(
          length: widget.itemCount,
          vsync: this,
          initialIndex: _currentPosition,
        );
        controller.addListener(onPositionChange);
        controller.animation?.addListener(onScroll);
      });
    } else if (widget.initPosition != null) {
      controller.animateTo(widget.initPosition!);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.animation?.removeListener(onScroll);
    controller.removeListener(onPositionChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount < 1) return widget.stub ?? Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: TabBar(
            isScrollable: true,
            controller: controller,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).hintColor,
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
            ),
            tabs: List.generate(
              widget.itemCount,
              (index) => widget.tabBuilder(context, index),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: controller,
            children: List.generate(
              widget.itemCount,
              (index) => widget.pageBuilder(context, index),
            ),
          ),
        ),
      ],
    );
  }

  onPositionChange() {
    if (!controller.indexIsChanging) {
      _currentPosition = controller.index;
      if (widget.onPositionChange is ValueChanged<int>) {
        widget.onPositionChange!(_currentPosition);
      }
    }
  }

  onScroll() {
    if (widget.onScroll is ValueChanged<double>) {
      widget.onScroll!(controller.animation!.value);
    }
  }
}

// class CustomTabbar extends StatefulWidget {
//   final AuthProviderSQL authProviderSQL;
//   final FormDuty formDuty;
//   final Function(FloatingAccount) tapHandler;

//   const CustomTabbar({
//     Key? key,
//     required this.authProviderSQL,
//     required this.formDuty,
//     required this.tapHandler,
//   }) : super(key: key);

//   @override
//   _CustomTabbarState createState() => _CustomTabbarState();
// }

// class _CustomTabbarState extends State<CustomTabbar> {
//   @override
//   Widget build(BuildContext context) {
//     List<Widget> tabs;
//     List<TabBarView> tabViews;

//     return Container(
//       height: 200,
//       child: DefaultTabController(
//         length: 3,
//         child: Scaffold(
//           appBar: AppBar(
//             bottom: const TabBar(
//               tabs: [
//                 Tab(text: 'CAR', icon: Icon(Icons.directions_car)),
//                 Tab(text: 'TRAN', icon: Icon(Icons.directions_transit)),
//                 Tab(text: 'BICICLE', icon: Icon(Icons.directions_bike)),
//               ],
//             ),
//             title: const Text('Select Float Aaccount'),
//           ),
//           body: TabBarView(
//             children: [
//               FloatDropdownMenu(
//                 authProvider: widget.authProviderSQL,
//                 formDuty: widget.formDuty,
//                 expandedAccountIds: [
//                   FloatAccountIds.ROOT_FLOAT_ACCOUNT_ID,
//                   FloatAccountIds.SALESMAN_FLOAT_ACCOUNT_ID,
//                 ],
//                 unwantedAccountIds: [],
//                 tapHandler: (FloatingAccount tappedFloat) => widget.tapHandler(tappedFloat),
//                 // tapHandler: (FloatingAccount tappedFloat) {
//                 //   Navigator.of(context).pop();
//                 //   setState(() {
//                 //     _fields.floatAccount = tappedFloat;
//                 //   });
//                 // },
//               ),
//               Icon(Icons.directions_transit),
//               Icon(Icons.directions_bike),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
