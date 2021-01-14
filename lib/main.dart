import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:agconnect_auth/agconnect_auth.dart';

import 'page_email.dart';
import 'page_user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    addTokenListener();
  }

  Future<void> addTokenListener() async {
    if (!mounted) return;

    AGCAuth.instance.tokenChanges().listen((TokenSnapshot event) {
      print("onEvent: $event , ${event.state}, ${event.token}");
    }, onError: (Object error) {
      print('onError: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: ListView(
              children: <Widget>[
                CupertinoButton(
                    child: Text('Email'),
                    onPressed: () async {
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => PageEmailAuth()));
                    }),
                CupertinoButton(
                    child: Text('User Info'),
                    onPressed: () async {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => PageUser()));
                    }),
              ],
            )),
      ),
    );
  }
}



