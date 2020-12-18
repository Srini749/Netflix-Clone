import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netflix_clone/screens/OnBoardingScreen.dart';
import 'package:netflix_clone/screens/SignIn.dart';

class SplashScreen extends StatefulWidget {
  final bool status;
  SplashScreen({this.status});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  widget.status ? SignInPage() : onBoardingScreen()),
          (route) => false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain,
              ),
            ),
            widget.status
                ? Container(
                    child: CircularProgressIndicator(),
                  )
                : Container(),
            SizedBox(
              height: 20,
            ),
            widget.status
                ? Container(
                    padding: EdgeInsets.all(10),
                    child: Center(
                        child: Text(
                      "A verification email has been sent. Sign in!",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
