import 'package:flutter/material.dart';
import './shop/shop.dart';

import 'constants.dart';

void main() {
  if (RUN_SHOP_APP) {
    runApp(Shop());
  } else if (RUN_ACCOUNTING_APP) {}
}
