import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';



class onBoardingScreen extends StatefulWidget {
  @override
  _onBoardingScreenState createState() => _onBoardingScreenState();
}

class _onBoardingScreenState extends State<onBoardingScreen> {
  bool loading=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
         body: isloading? Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Container(
                 width: 300,
                 child: Image.asset("assets/logo.png", fit: BoxFit.contain,),
               ),
               Container(
                 child: CircularProgressIndicator(),
               ),
               SizedBox(height: 20,),
             ],
           ),
         ):Stack(
           children: [],
         ),
    );
  }
}
