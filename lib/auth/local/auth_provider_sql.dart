import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop/auth/local/auth_model.dart';
import 'package:shop/exceptions/DBException.dart';
import 'package:shop/shared/ValidationException.dart';
import 'package:shop/shared/validation_result.dart';

class AuthProviderSQL with ChangeNotifier {
  AuthModel? _auth;

  Future<void> signup(String username, String password) async {
    print('ATHPr signup 01| recived $username and $password');
    _auth = AuthModel();
    var insertedId = await _auth!.createNewUserInDB(username, password);
    if (insertedId == 0)
      throw DBException('ATHPr signup 02| unable to insert $username in db');
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _auth = AuthModel();
    ValidationResult validationResult = await _auth!.validateUser(
      username,
      password,
    );
    if (!validationResult.isValid)
      throw ValidationException(
        'ATH_Pr login 01| validation of $username failed\n e: ${validationResult.errorMessage}',
      );
    notifyListeners();
  }

  Future<void> logout() async {
    _auth = null;
    notifyListeners();
  }

  int? get userId {
    return _auth?.id;
  }

  bool get isAuth {
    return (_auth != null && _auth!.id != null);
  }
}
