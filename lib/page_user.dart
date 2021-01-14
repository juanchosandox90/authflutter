import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:agconnect_auth/agconnect_auth.dart';

class PageUser extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PageUserState();
  }
}

class _PageUserState extends State<PageUser> {
  String _log = '';
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _photoUrlController = TextEditingController();

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

  _updateProfile() async {
    AGCUser user = await AGCAuth.instance.currentUser;
    if (user == null) {
      print("no user signed in");
      return;
    }
    bool result = await _showProfileDialog();
    if (result == null) {
      print("cancel");
      return;
    }
    String name = _displayNameController.text;
    String photo = _photoUrlController.text;
    ProfileRequest request = ProfileRequest(name, photo);
    await user.updateProfile(request).catchError((error){
      print(error);
    });
    print('updateProfile');
  }


  _getUserExtra() async {
    AGCUser user = await AGCAuth.instance.currentUser;
    AGCUserExtra userExtra = await user.userExtra.catchError((error){
      print(error);
    });
    setState(() {
      _log = 'getUserExtra ${userExtra.createTime}, ${userExtra.lastSignInTime}';
    });
  }

  _getToken() async {
    AGCUser user = await AGCAuth.instance.currentUser.catchError((e){
      AGCAuthException exception = e;
    });
    TokenResult res = await user?.getToken();
    setState(() {
      _log = 'getToken ${res?.token} ';
    });
  }


  Future<bool> _showProfileDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Input"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupertinoTextField(controller: _displayNameController,placeholder: 'display name',),
              CupertinoTextField(controller: _photoUrlController,placeholder: 'photo url',),
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
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
      ),
      body: Center(
          child: ListView(children: <Widget>[
            Text(_log),
            CupertinoButton(child: Text('getCurrentUser'), onPressed: _getCurrentUser),
            CupertinoButton(child: Text('updateProfile'), onPressed: _updateProfile),
            CupertinoButton(child: Text('getUserExtra'), onPressed: _getUserExtra),
            CupertinoButton(child: Text('getToken'), onPressed: _getToken),
          ],)
      ),
    );
  }
}