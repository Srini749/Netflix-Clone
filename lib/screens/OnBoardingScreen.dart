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
  int _currentpageindex = 0;
  var movieslist;
  var tvlist;
  var upcomingmovies;

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


  fetchingalldata()async{
    var movies1 = await movies();
    var tv1 =await tv();
    var upcomingmovies1 = await getData("https://api.themoviedb.org/3/movie/upcoming?api_key=1700c4a8b5698384abc2e8d34ff5b413&language=en-US&page=1");

    setState(() {
      movieslist = movies1;
      tvlist = tv1;
      upcomingmovies = upcomingmovies1;
    });
  }

  issignedinusingemail()async {
    setState(() {
      isloading = true;
    });
    User firebaseUser = auth.currentUser;
    await fetchingalldata();
    try{
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').where("email", isEqualTo: firebaseUser.email,).get();
      if(firebaseUser != null){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(user: firebaseUser, movielist: movieslist["results"],tvlist: tvlist["results"], upcomingmovies: upcomingmovies["results"], snapshot: snapshot)));
      }else{
        setState(() {
          isloading = false;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => onBoardingScreen()));
        });
      }
    }catch(e){
      setState(() {
        isloading = false;
      });
    }

  }


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
           children: [
             PageView.builder(
                 itemCount: onBoardingData.length,
                 onPageChanged: (index){
                   setState((){
                     _currentpageindex = index;
                   });
                 },
                 itemBuilder: (context, index) {
                   return Stack(
                     fit: StackFit.passthrough,
                     children: [
                       index == 3
                           ? Container(
                         height: double.infinity,
                         child: Image.asset(
                           onBoardingData[index].image,
                           fit: BoxFit.cover,
                         ),
                       )
                           : Container(
                         alignment:Alignment.topCenter,
                         child: Column(
                           children: [
                             SizedBox(height: 170,),
                             Image.asset(onBoardingData[index].image),
                           ],
                         ),
                       ),
                       index == 3
                           ? Container(
                         decoration: BoxDecoration(
                             gradient: LinearGradient(
                               colors: [
                                 Colors.black.withOpacity(0.5),
                                 Colors.black.withOpacity(0.1),
                                 Colors.black.withOpacity(0.9),
                               ],
                               begin: Alignment(0.9, 0.0),
                               end: Alignment(0.9, 0.4),
                             )),
                       )
                           : Container(),
                       Container(
                         margin: EdgeInsets.only(top: 400, left: 40, right: 40),
                         child: Column(
                           children: [
                             Text(
                               onBoardingData[index].heading,
                               style: TextStyle(
                                 fontSize: 22,
                               ),
                               textAlign: TextAlign.center,
                             ),
                             SizedBox(
                               height: 10,
                             ),
                             Text(
                               onBoardingData[index].description,
                               style: TextStyle(
                                 fontSize: 16,
                               ),
                               textAlign: TextAlign.center,
                             )
                           ],
                         ),
                       )
                     ],
                   );
                 }),
             Container(child: Column(
               mainAxisAlignment: MainAxisAlignment.end,
               children: [
                 Container(
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: onBoardingData.map((data){
                       int index = onBoardingData.indexOf(data);
                       return Container(
                         height: 10,
                         width: 10,
                         margin: EdgeInsets.all(5),
                         decoration: BoxDecoration(
                             color: index==_currentpageindex? Colors.red: Colors.grey,
                             borderRadius: BorderRadius.all(Radius.circular(20))
                         ),
                       );
                     }).toList(),
                   ),
                 ),
                 SizedBox(height: 20,),
                 GestureDetector(
                   onTap: (){
                     Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                   },
                   child: Container(
                     margin: EdgeInsets.only(bottom: 10, left: 15, right: 15),
                     padding: EdgeInsets.symmetric(vertical: 15,),
                     width: double.infinity,
                     alignment: Alignment.center,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.all(Radius.circular(5)),
                       color: Colors.red,
                     ),
                     child: Text("GET STARTED", style: TextStyle(fontWeight: FontWeight.bold),),
                   ),
                 ),
                 SizedBox(height: 20,),
               ],
             )),
             Container(
               margin: EdgeInsets.only(top: 15),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Container(
                     height: 70,
                     width: 70,
                     child: Image.asset("assets/n_symbol.png"),
                   ),
                   Row(
                     children: [
                       Text("PRIVACY"),
                       SizedBox(
                         width: 10,
                       ),
                       Text("HELP"),
                       SizedBox(
                         width: 10,
                       ),
                       GestureDetector(
                           onTap: ()async{
                             setState(() {
                               isloading=true;
                             });
                             await fetchingalldata();
                             setState(() {
                               isloading=false;
                             });
                             Navigator.push(context, MaterialPageRoute(builder: (context) => SignInPage( movielist: movieslist["results"],tvlist: tvlist["results"],upcomingmovies: upcomingmovies["results"], )));
                           },
                           child: Text("SIGN IN")),
                       SizedBox(
                         width: 10,
                       ),
                     ],
                   )
                 ],
               ),
             ),

           ],
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
