import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart'as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';



class onBoardingScreen extends StatefulWidget {
  @override
  _onBoardingScreenState createState() => _onBoardingScreenState();
}

class _onBoardingScreenState extends State<onBoardingScreen> {
  bool isloading=false;

  Future getData(String address) async{
    http.Response response = await http.get(address);
    if(response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    }
    else{
      print(response.statusCode);
    }
  }

  Future movies()async{
    var movielist1 = await getData("https://api.themoviedb.org/3/movie/popular?api_key=1700c4a8b5698384abc2e8d34ff5b413&language=en-US&page=1");
    var movielist2 = await getData("https://api.themoviedb.org/3/movie/top_rated?api_key=1700c4a8b5698384abc2e8d34ff5b413&language=en-US&page=1");
    movielist1["results"].addAll(movielist2["results"]);

    for(int i=0; i<movielist1["results"].length;i++){
      movielist1["results"][i]["type"] = "movie";
    }

    // var movielist3 = await getData("https://api.themoviedb.org/3/movie/now_playing?api_key=1700c4a8b5698384abc2e8d34ff5b413&language=en-US&page=1");
    return movielist1;
  }

  Future tv()async{
    var tvlist = await getData("https://api.themoviedb.org/3/tv/popular?api_key=1700c4a8b5698384abc2e8d34ff5b413&language=en-US&page=1");
    for(int i=0; i<tvlist["results"].length;i++){
      tvlist["results"][i]["type"] = "tv";
    }
    return tvlist;
  }
  final FirebaseAuth auth  = FirebaseAuth.instance;


  static List<OnBoardingEntity> onBoardingData = [
    OnBoardingEntity(
        image: 'assets/devices.png',
        description:
        "Stream on your phone tablet, laptop,and TV without paying more.",
        heading: "Watch on any device"),
    OnBoardingEntity(
        image: 'assets/download.png',
        description: "Always have something to watch offline.",
        heading: "3,2,1... Download!"),
    OnBoardingEntity(
        image: 'assets/contract.png',
        description: "Join today, cancel any time",
        heading: "No annoying contracts"),
    OnBoardingEntity(
        image: 'assets/background.png',
        description: "Stream and download as much as you want, no extra fees.",
        heading: "Unlimited entertainment, one low price"),
  ];

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

class OnBoardingEntity {
  final String image;
  final String heading;
  final String description;

  OnBoardingEntity({this.image, this.heading, this.description});
}
