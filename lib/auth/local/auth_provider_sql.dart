import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/auth/auth_mode.dart';
import 'package:shop/auth/local/auth_model.dart';
import 'package:shop/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/exceptions/DBException.dart';
import 'package:shop/shared/ValidationException.dart';
import 'package:shop/shared/result_status.dart';
import 'package:shop/shared/validation_result.dart';

class AuthProviderSQL with ChangeNotifier {
  int? _userId;
  AuthModel? _auth;
  // String? _token;
  // String? _refreshToken;
  // DateTime? _expiryDate;
  // Timer? _logoutTimer;

  Future<void> signup(String username, String password) async {
    _auth = AuthModel();
    var insertedId = await _auth!.createNewUserInDB(username, password);
    if (insertedId == 0)
      throw DBException('ATHPr signup 01| unable to insert $username in db');

    _userId = _auth!.id;
    // _expiryDate = DateTime.now().add(Duration(hours: 3));
    // _setAutoLogout();
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

    _userId = _auth!.id!;
    // _expiryDate = DateTime.now().add(Duration(hours: 3));
    // _setAutoLogout();
    notifyListeners();
  }

  Future<void> logout() async {
    _userId = null;
    // _token = null;
    // _expiryDate = null;
    _auth = null;

    // if (_logoutTimer != null) {
    //   _logoutTimer!.cancel();
    //   _logoutTimer = null;
    // }

    notifyListeners();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // print(prefs.getString('authData'));
    // prefs.remove('authData');
    // prefs.clear(); // clear all data
  }

  int? get userId {
    return _auth?.id;
  }

  bool get isAuth {
    return _auth?.id != null;
  }

  /*
  void _setAutoLogout() {
    if (_logoutTimer != null) {
      _logoutTimer!.cancel();
    }
    final timeToExpiry = _expiryDate != null
        ? _expiryDate!.difference(DateTime.now()).inSeconds
        : 0;
    _logoutTimer = Timer(Duration(seconds: timeToExpiry), logout);
    print('AP10| _autoLogout sets for $timeToExpiry sec');
  }

  Future<bool> tryAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authData')) {
      if (AUTOLOGINSAEID) {
        try {
          await login(SAEIDEMAIL, SAEIDPASSWORD);
          return true;
        } on Exception catch (e) {
          print(
              'AP19| tryToAutoLogin() > login(SAEIDEMAIL, SAEIDPASSWORD) > error: ${e.toString()}');
          return false;
        }
      } else {
        print('AP20| tryToAutoLogin() > prefs.containsKey(authData): false');
        return false;
      }
    }
    final extractedAuthData = prefs.getString('authData');
    // print('AP21| tryToAutoLogin() > extractedAuthData: $extractedAuthData');
    final decode = json.decode(extractedAuthData!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(decode['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      print(
          'AP22| tryToAutoLogin() > expiryDate.isBefore(DateTime.now()): true');
      return false;
    }
    _token = decode['token'];
    _userId = decode['userId'];
    _expiryDate = expiryDate;

    notifyListeners();
    _setAutoLogout();
    return true;
  }


  Future<void> _authenticate(
    String username,
    String password,
    AuthMode mode,
  ) async {
    try {
      final rawResponse = await http.post(url!, body: payload);
      final response = json.decode(rawResponse.body);

      _userId = response['localId'];
      _token = response['idToken'];
      _refreshToken = response['refreshToken'];
      _expiryDate = DateTime.now().add(
        Duration(seconds: int.parse(response['expiresIn'])),
      );
      _setAutoLogout();
      notifyListeners();

      final String authData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('authData', authData);
      print('AP30| set authData: $authData');
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  String? get token {
    if (_expiryDate != null && _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String? get refreshToken {
    return _refreshToken;
  }

  */
}
