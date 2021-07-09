import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/common/supported_language.dart';
import 'package:shop/accounting/environment/environment_provider.dart';
import 'package:shop/auth/auth_provider_sql.dart';

enum witchCondition {
  ALL,
  ANY,
}

class SecureWidget extends StatelessWidget {
  final AuthProviderSQL authProviderSQL;
  final List<String?>? vitalPermissions;
  final List<String?>? anyPermissions;
  final Widget widget;
  final Widget? alternativeWidget;
  const SecureWidget({
    Key? key,
    required this.authProviderSQL,
    required this.vitalPermissions,
    required this.anyPermissions,
    required this.widget,
    this.alternativeWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var notPermittedWidget =
        alternativeWidget != null ? alternativeWidget : Container();

    // if there is no vitalPerm we should check anyPermissions
    if (vitalPermissions != null && vitalPermissions!.isNotEmpty) {
      // if any of vitalPerm not satisfied we return notPermittedWidget
      for (var vPerm in vitalPermissions!) {
        if (!authProviderSQL.isPermitted(vPerm!)) return notPermittedWidget!;
      }
    }
    // now vaital are passed;

    // if there is not anyPermissions it means OK
    if (anyPermissions == null && anyPermissions!.isEmpty) {
      return widget;
    }

    // we should at least pass one of anyPerms
    var isPermitted = false;
    for (var anyPerm in anyPermissions!) {
      if (authProviderSQL.isPermitted(anyPerm!)) return widget;
    }

    return notPermittedWidget!;
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Consumer<EnvironmentProvider>(
  //     builder: (ctx, envProvider, child) => Text(
  //       _buildString(envProvider),
  //       style: style,
  //     ),
  //   );
  // }

}
