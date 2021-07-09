import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/accounting/common/supported_language.dart';
import 'package:shop/accounting/environment/environment_provider.dart';
import 'package:shop/auth/auth_provider_sql.dart';

import 'has_access.dart';

enum witchCondition {
  ALL,
  ANY,
}

class SecureWidget extends StatelessWidget {
  final AuthProviderSQL authProviderSQL;
  final List<String?>? vitalPermissions;
  final List<String?>? anyPermissions;
  final Widget child;
  final Widget? alternativeWidget;
  const SecureWidget({
    Key? key,
    required this.authProviderSQL,
    required this.child,
    this.vitalPermissions,
    this.anyPermissions,
    this.alternativeWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var notPermittedWidget =
        alternativeWidget != null ? alternativeWidget : Container();

    if (hasAccess(authProviderSQL, vitalPermissions, anyPermissions)) {
      return child;
    } else {
      return notPermittedWidget!;
    }
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
