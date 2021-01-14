import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:agconnect_auth/agconnect_auth.dart';

class PageEmailAuth extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PageEmailAuthState();
  }
}

class _PageEmailAuthState extends State<PageEmailAuth> {
  String _log = '';
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _verifyCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  _getCurrentUser() async {
    AGCAuth.instance.currentUser.then((value) {
      setState(() {
        _log = 'current user = ${value?.uid} , ${value?.providerId}';
      });
    });
  }

  _createEmailUser() async {
    bool result = await _showEmailDialog(VerifyCodeAction.registerLogin);
    if (result == null) {
      print("cancel");
      return;
    }
    String email = _emailController.text;
    String verifyCode = _verifyCodeController.text;
    String password = _passwordController.text;
    AGCAuth.instance
        .createEmailUser(EmailUser(email, verifyCode, password: password))
        .then((value) {
      setState(() {
        _log = 'Create Email lUser = ${value.user.uid} , ${value.user.providerId}';
      });
    }).catchError((error) => print(error));
  }

  _signInWithPassword() async {
    bool result = await _showEmailDialog(VerifyCodeAction.registerLogin);
    if (result == null) {
      print("cancel");
      return;
    }
    String email = _emailController.text;
    String password = _passwordController.text;
    AGCAuthCredential credential =
    EmailAuthProvider.credentialWithPassword(email, password);
    AGCAuth.instance.signIn(credential).then((value) {
      setState(() {
        _log =
        'Sign In With Password = ${value.user.uid} , ${value.user.providerId}';
      });
    });
  }

  _signInWithVerifyCode() async {
    bool result = await _showEmailDialog(VerifyCodeAction.registerLogin);
    if (result == null) {
      print("cancel");
      return;
    }
    String email = _emailController.text;
    String verifyCode = _verifyCodeController.text;
    String password = _passwordController.text;
    AGCAuthCredential credential = EmailAuthProvider.credentialWithVerifyCode(
        email, verifyCode,
        password: password);
    AGCAuth.instance.signIn(credential).then((value) {
      setState(() {
        _log =
        'Sign In With VerifyCode = ${value.user.uid} , ${value.user.providerId}';
      });
    });
  }

  _resetEmailPassword() async {
    bool result = await _showEmailDialog(VerifyCodeAction.resetPassword);
    if (result == null) {
      print("cancel");
      return;
    }
    String email = _emailController.text;
    String verifyCode = _verifyCodeController.text;
    String password = _passwordController.text;
    AGCAuth.instance
        .resetPasswordWithEmail(email, password, verifyCode)
        .then((value) => print('Reset Email Password'));
  }

  _signOut() {
    AGCAuth.instance.signOut().then((value) {
      setState(() {
        _log = 'Sign Out';
      });
    }).catchError((error) => print(error));
  }

  _deleteUser() {
    AGCAuth.instance.deleteUser().then((value) {
      setState(() {
        _log = 'Delete User';
      });
    }).catchError((error) => print(error));
  }

  _link() async {
    AGCUser user = await AGCAuth.instance.currentUser;
    if (user == null) {
      print("no user signed in");
      return;
    }
    bool result = await _showEmailDialog(VerifyCodeAction.registerLogin);
    if (result == null) {
      print("cancel");
      return;
    }
    String email = _emailController.text;
    String verifyCode = _verifyCodeController.text;
    String password = _passwordController.text;
    AGCAuthCredential credential = EmailAuthProvider.credentialWithVerifyCode(
        email, verifyCode,
        password: password);
    SignInResult signInResult = await user.link(credential).catchError((error) {
      print(error);
    });
    setState(() {
      _log = 'link email = ${signInResult?.user?.uid}';
    });
  }

  _unlink() async {
    AGCUser user = await AGCAuth.instance.currentUser;
    if (user == null) {
      print("no user signed in");
      return;
    }
    SignInResult result =
    await user.unlink(AuthProviderType.email).catchError((error) {
      print(error);
    });
    setState(() {
      _log = 'unlink email = ${result?.user?.uid}';
    });
  }

  _updateEmail() async {
    AGCUser user = await AGCAuth.instance.currentUser;
    if (user == null) {
      print("no user signed in");
      return;
    }
    bool result = await _showEmailDialog(VerifyCodeAction.registerLogin);
    if (result == null) {
      print("cancel");
      return;
    }
    String email = _emailController.text;
    String verifyCode = _verifyCodeController.text;
    await user.updateEmail(email, verifyCode).catchError((error) {
      print(error);
    });
    print('Update Email');
  }

  _updatePassword() async {
    AGCUser user = await AGCAuth.instance.currentUser;
    if (user == null) {
      print("no user signed in");
      return;
    }
    bool result = await _showEmailDialog(VerifyCodeAction.resetPassword);
    if (result == null) {
      print("cancel");
      return;
    }
    String verifyCode = _verifyCodeController.text;
    String password = _passwordController.text;
    await user.updatePassword(password, verifyCode, AuthProviderType.email).catchError((error){
      print(error);
    });
    print('Update Password');
  }

  Future<bool> _showEmailDialog(VerifyCodeAction action) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Input"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'email',
              ),
              CupertinoTextField(
                controller: _passwordController,
                placeholder: 'password',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: CupertinoTextField(
                      controller: _verifyCodeController,
                      placeholder: 'verification code',
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 32,
                    child: FlatButton(
                        color: Colors.white,
                        child: Text('send'),
                        onPressed: () => _requestEmailVerifyCode(action)),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("CANCEL"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  _requestEmailVerifyCode(VerifyCodeAction action) {
    String email = _emailController.text;
    VerifyCodeSettings settings = VerifyCodeSettings(action, sendInterval: 30);
    EmailAuthProvider.requestVerifyCode(email, settings)
        .then((value) => print(value.validityPeriod));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Auth'),
      ),
      body: Center(
          child: ListView(
            children: <Widget>[
              Text(_log),
              CupertinoButton(
                  child: Text('Get Current User'), onPressed: _getCurrentUser),
              CupertinoButton(
                  child: Text('Create Email User'), onPressed: _createEmailUser),
              CupertinoButton(
                  child: Text('Sign In With Password'),
                  onPressed: _signInWithPassword),
              CupertinoButton(
                  child: Text('Sign In With Verify Code'),
                  onPressed: _signInWithVerifyCode),
              CupertinoButton(
                  child: Text('Reset Email Password'),
                  onPressed: _resetEmailPassword),
              CupertinoButton(child: Text('Sign Out'), onPressed: _signOut),
              CupertinoButton(child: Text('Delete User'), onPressed: _deleteUser),
              CupertinoButton(child: Text('Link Email'), onPressed: _link),
              CupertinoButton(child: Text('Unlink Email'), onPressed: _unlink),
              CupertinoButton(child: Text('Update Email'), onPressed: _updateEmail),
              CupertinoButton(child: Text('Update Password'), onPressed: _updatePassword),
            ],
          )),
    );
  }
}