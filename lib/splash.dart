import 'dart:async';

import 'package:dhatnoon/MainArrange.dart';
import 'package:dhatnoon/constants.dart';
import 'package:dhatnoon/loginpage.dart';
import 'package:dhatnoon/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool isLoggedIn = true;
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("shredpreference content");
    print(sharedPreferences.getString('token'));
    if (sharedPreferences.getString('token') != null) {
      Timer(
          Duration(seconds: 2),
          () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MainArrange())));
    } else {
      // SharedPreferences.setMockInitialValues({});
      Timer(
          Duration(seconds: 2),
          () => Navigator.pushReplacement(
              // context, MaterialPageRoute(builder: (context) => LoginPage())));
              context,
              MaterialPageRoute(builder: (context) => LoginPage())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Text(
            'DHATNOON',
            style: TextStyle(
                fontSize: 40,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
