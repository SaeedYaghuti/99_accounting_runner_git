import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/auth/local/auth_provider_sql.dart';
import 'package:shop/constants.dart';
import 'package:shop/exceptions/unique_constraint_exception.dart';

import '../auth_mode.dart';
// import 'auth_provider.dart';

class AuthFormSQL extends StatefulWidget {
  const AuthFormSQL({
    Key? key,
  }) : super(key: key);

  @override
  _AuthFormSQLState createState() => _AuthFormSQLState();
}

class _AuthFormSQLState extends State<AuthFormSQL> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  @override
  void initState() {
    _passwordController.text = SAEIDPASSWORD;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildEmailFeild(),
                _buildPasswordField(),
                if (_authMode == AuthMode.Signup) _buildConformPasswordField(),
                SizedBox(height: 20),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  _buildSigninLoginButton(context),
                _buildSwitchButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailFeild() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'E-Mail'),
      keyboardType: TextInputType.emailAddress,
      initialValue: SAEIDEMAIL,
      validator: (value) {
        if (value == null || value.isEmpty || !value.contains('@')) {
          return 'Invalid email!';
        }
        return null;
      },
      onSaved: (value) {
        _authData['email'] = value!;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Password'),
      obscureText: true,
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.isEmpty || value.length < 5) {
          return 'Password is too short!';
        }
      },
      onSaved: (value) {
        _authData['password'] = value!;
      },
    );
  }

  TextFormField _buildConformPasswordField() {
    return TextFormField(
      enabled: _authMode == AuthMode.Signup,
      decoration: InputDecoration(labelText: 'Confirm Password'),
      initialValue: SAEIDPASSWORD,
      obscureText: true,
      validator: _authMode == AuthMode.Signup
          ? (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match!';
              }
            }
          : null,
    );
  }

  RaisedButton _buildSigninLoginButton(BuildContext context) {
    return RaisedButton(
      child: Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
      onPressed: _submit,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      color: Theme.of(context).primaryColor,
      textColor: Theme.of(context).primaryTextTheme.button!.color,
    );
  }

  FlatButton _buildSwitchButton(BuildContext context) {
    return FlatButton(
      child:
          Text('${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
      onPressed: _switchAuthMode,
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: Theme.of(context).primaryColor,
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    _startLoading();

    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<AuthProviderSQL>(context, listen: false).login(
          _authData['email']!,
          _authData['password']!,
        );
        // after successfull login; we run notifyListiner() at authProvider; listiner will action themself to new state
      } else {
        await Provider.of<AuthProviderSQL>(context, listen: false).signup(
          _authData['email']!,
          _authData['password']!,
        );
        // after successfull signup; we run notifyListiner() at authProvider; listiner will action themself to new state

      }
    } on UniqueConstraintException catch (e) {
      _endLoading();
      _showErrorDialog(
        'ATH_FORM_SQL Catch 02| This username already taken! maybe you want to login! or you should choose another username; \n error: $e',
      );
    } catch (e) {
      print(
        'ATH_FORM_SQL Catch 01| error happend while login Or signup: e: $e',
      );
      _endLoading();
      _showErrorDialog(
        'ATH_FORM_SQL Catch 02| Could not authenticate you. Please try again later.',
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _endLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }
}
