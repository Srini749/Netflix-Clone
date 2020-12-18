import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:netflix_clone/widgets/custom_theme.dart';

class HomePage extends StatefulWidget {
  final User user;
  final List<dynamic> movielist;
  final List<dynamic> tvlist;
  final List<dynamic> upcomingmovies;
  QuerySnapshot snapshot;
  HomePage(
      {this.user,
      this.tvlist,
      this.movielist,
      this.upcomingmovies,
      this.snapshot});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<dynamic> totaldata;
  bool isloading = false;
  int selectedIndex = 0;
  TextEditingController search = TextEditingController();
  bool mylist = false;
  var details;
  var searchdata;
  bool movie;
  bool added =false;
  bool searched = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Color> selectedbar = [
    Colors.white,
    Colors.grey,
    Colors.grey,
    Colors.grey,
    Colors.grey
  ];
  List list = [
    {"id": 82856, "poster_path": "/sWgBv7LV2PRoQgkxwlibdGXKz1S.jpg"},
    {"id": 97180, "poster_path": "/mYsWyfiIMxx4HDm0Wck7oJ9ckez.jpg"},
    {"id": 82856, "poster_path": "/sWgBv7LV2PRoQgkxwlibdGXKz1S.jpg"},
    {"id": 82856, "poster_path": "/sWgBv7LV2PRoQgkxwlibdGXKz1S.jpg"}
  ];
  List<dynamic> data;
  PageController pageController = PageController();
  Map<int, String> genres = {
    28: "Action",
    12: "Adventure",
    16: "Animation",
    35: "Comedy",
    80: "Crime",
    99: "Documentary",
    18: "Drama",
    10751: "Family",
    14: "Fantasy",
    36: "History",
    27: "Horror",
    10402: "Music",
    9648: "Mystery",
    10749: "Romance",
    878: "Science Fiction",
    10770: "TV Movie",
    53: "Thriller",
    10752: "War",
    37: "Western",
    10759: "Action & Adventure",
    10762: "Kids",
    10763: "News",
    10764: "Reality",
    10765: "Sci-Fi & Fantasy",
    10766: "Soap",
    10767: "Talk",
    10768: "War & Politics",
  };

  Future getData(String address) async {
    http.Response response = await http.get(address);
    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }

  Future gettingmoviedetails(int id) async {
    var data1 = await getData(
        "https://api.themoviedb.org/3/movie/$id?api_key=1700c4a8b5698384abc2e8d34ff5b413&language=en-US");
    var credits = await getData(
        "https://api.themoviedb.org/3/movie/$id/credits?api_key=1700c4a8b5698384abc2e8d34ff5b413&language=en-US");
    var similar = await getData(
        "https://api.themoviedb.org/3/movie/$id/similar?api_key=1700c4a8b5698384abc2e8d34ff5b413&language=en-US&page=1");

    for (int i = 0; i < similar["results"].length; i++) {
      similar["results"][i]["type"] = "movie";
    }

    if (data1 != null) {
      setState(() {
        details = data1;
        details["cast"] = credits["cast"];
        details['crew'] = credits["crew"];
        details["similar"] = similar["results"];
        movie = true;
      });
    }
    return details;
  }

  Future gettingtvdetails(int id) async {
    var data1 = await getData(
        "https://api.themoviedb.org/3/tv/${id}?api_key=1700c4a8b5698384abc2e8d34ff5b413&language=en-US");
    var credits = await getData(
        "https://api.themoviedb.org/3/tv/${id}/credits?api_key=1700c4a8b5698384abc2e8d34ff5b413&language=en-US");
    var similar = await getData(
        "https://api.themoviedb.org/3/tv/$id/similar?api_key=1700c4a8b5698384abc2e8d34ff5b413&language=en-US&page=1");
    for (int i = 0; i < similar["results"].length; i++) {
      similar["results"][i]["type"] = "movie";
    }
    if (data1 != null) {
      setState(() {
        details = data1;
        details["cast"] = credits["cast"];
        details['crew'] = credits["crew"];
        details["similar"] = similar["results"];
        movie = false;
      });
    }
    return details;
  }


  void onTap(int pageValue) {
    setState(() {
      selectedIndex = pageValue;

      pageController.jumpToPage(pageValue);
    });
  }

  Widget homescreen() {
    return Container();
  }

  Widget Search() {
    return Container();
  }

  Container itemCont(BuildContext context,String name,String desp,String image,List genrelist) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(child: Image.network(image, fit: BoxFit.fitWidth)),
          SizedBox(width: double.infinity,height: 20,),
          Row(
            children: <Widget>[
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left:15),
                  width: (MediaQuery.of(context).size.width/2),
                  height: 40.0,
                  child: FlatButton(
                    onPressed: (){},
                    child: Container(
                        width:120,
                        height: 30,
                        decoration: BoxDecoration(
                            color:Colors.grey.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(7)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Icon(Icons.notifications_active,color:Colors.white,size:18),
                            Text('Remind Me' ,style: TextStyle(color:Colors.white),)
                          ],)
                    ),
                  )
              ),
            ],
          ),
          SizedBox(height: 10,)
          ,
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    name,
                    style:TextStyle(
                      color:Colors.white,
                      fontSize:30,
                    ),
                  ),
                ),
              )
            ],
          )
          ,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(

                  fit: FlexFit.loose,
                  child:
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      desp
                      ,style: TextStyle(
                        color: Colors.white54,
                        fontSize: 20,
                        fontWeight: FontWeight.w100
                    ),
                    ),
                  )

              )
            ],
          ),
          Container(
            alignment: Alignment.center,
            child: Wrap(
              direction: Axis.horizontal,
              spacing: 5,
              alignment: WrapAlignment.center,
              children: [
                for (int i = 0;
                i < genrelist.length;
                i++)
                  Container(
                    width: 100,
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(20))),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            genres[genrelist[i]],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Container(
          //   height: 30,
          //   alignment: Alignment.center,
          //   width: MediaQuery.of(context).size.width,
          //   child: ListView.builder(
          //       shrinkWrap: true,
          //       scrollDirection: Axis.horizontal,
          //       itemCount: genrelist.length,
          //       itemBuilder: (context, index) {
          //         return Container(
          //           alignment: Alignment.center,
          //           child: Row(
          //             children: [
          //               Container(
          //                 height: 10,
          //                 width: 10,
          //                 margin: EdgeInsets.all(5),
          //                 decoration: BoxDecoration(
          //                     color: Colors.orange,
          //                     borderRadius: BorderRadius.all(
          //                         Radius.circular(20))),
          //               ),
          //               Container(
          //                 padding: EdgeInsets.only(left: 5),
          //                 child: Text(
          //                   genres[genrelist[index]],
          //                   style: TextStyle(
          //                       color: Colors.white,
          //                       fontSize: 15),
          //                 ),
          //               )
          //             ],
          //           ),
          //         );
          //       }),
          // ),
          SizedBox(height: 30,)
        ],
      ),
    );
  }

  Widget ComingSoon() {
    return Container();
  }

  Widget Download() {
    return Container();
  }

  Widget More() {
    return Container();
  }

  @override
  void initState() {
    totaldata = List.from(widget.movielist)..addAll(widget.tvlist);
    data = totaldata;
    data.shuffle();

    // print(widget.user.email);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme,
      home: Scaffold(
        key: scaffoldKey,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black87,
          selectedFontSize: 14.0,
          selectedIconTheme: IconThemeData(color: Colors.black87),
          unselectedFontSize: 12.0,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: Image.asset('assets/icons/home.png',
                    scale: 22.0, color: selectedbar[0]),
                title: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Home',
                      style: TextStyle(color: selectedbar[0], fontSize: 12.0)),
                )),
            BottomNavigationBarItem(
                icon: Image.asset('assets/icons/search.png',
                    scale: 22.0, color: selectedbar[1]),
                title: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Search',
                      style: TextStyle(color: selectedbar[1], fontSize: 12.0)),
                )),
            BottomNavigationBarItem(
                icon: Image.asset('assets/icons/coming.png',
                    scale: 22.0, color: selectedbar[2]),
                title: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Coming soon',
                      style: TextStyle(color: selectedbar[2], fontSize: 12.0)),
                )),
            BottomNavigationBarItem(
                icon: Image.asset('assets/icons/download.png',
                    scale: 22.0, color: selectedbar[3]),
                title: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Download',
                      style: TextStyle(color: selectedbar[3], fontSize: 12.0)),
                )),
            BottomNavigationBarItem(
                icon: Image.asset('assets/icons/more.png',
                    scale: 22.0, color: selectedbar[4]),
                title: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('More',
                      style: TextStyle(color: selectedbar[4], fontSize: 12.0)),
                )),
          ],
          onTap: onTap, // onTap: onTap,
        ),
        body: PageView(
          controller: pageController,
          children: <Widget>[
            homescreen(),
            Search(),
            ComingSoon(),
            Download(),
            More()
          ],
          onPageChanged: (value) {

            setState(() {
              selectedIndex = value;
              for (int i = 0; i < selectedbar.length; i++) {
                if (i == selectedIndex) {
                  selectedbar[i] = Colors.white;
                } else {
                  selectedbar[i] = Colors.grey;
                }
              }
            });
          },
        ),
      ),
    );
  }
}
