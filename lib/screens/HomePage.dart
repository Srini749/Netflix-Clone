import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:netflix_clone/screens/OnBoardingScreen.dart';
import 'package:netflix_clone/widgets/Video.dart';
import 'dart:convert';
import 'package:netflix_clone/widgets/custom_theme.dart';

import 'MoreDetails.dart';

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

  checkingmylistformovie() async {
    setState(() {
      isloading = true;
      widget.snapshot.docs[0]
          .data()["mylist"]
          .removeWhere((item) => item["type"] == "tv");
    });
    var details = await gettingmoviedetails(data[0]["id"]);
    if (widget.snapshot.docs[0].data()["mylist"].length != 0) {
      for (int i = 0;
      i < widget.snapshot.docs[0].data()["mylist"].length;
      i++) {
        print(widget.snapshot.docs[0].data()["mylist"][i]["original_title"]);
        print(details["original_title"]);
        if (widget.snapshot.docs[0]
            .data()["mylist"][i]["original_title"]==
            details["original_title"]) {
          setState(() {
            added = true;
            isloading = false;
          });
          break;
        } else {
          setState(() {
            added = false;
            isloading = false;
          });
        }
      }
    }else{
      setState(() {
        added = false;
        isloading =false;
      });
    }
  }

  checkingmylistfortv() async {
    setState(() {
      isloading = true;
      widget.snapshot.docs[0]
          .data()["mylist"]
          .removeWhere((item) => item["type"] == "movie");
    });
    var details = data[0]["type"] == "movie"
        ? await gettingmoviedetails(data[0]["id"])
        : await gettingtvdetails(data[0]["id"]);
    if (widget.snapshot.docs[0].data()["mylist"].length != 0) {
      for (int i = 0;
      i < widget.snapshot.docs[0].data()["mylist"].length;
      i++) {
        print(widget.snapshot.docs[0].data()["mylist"][i]["title"]);
        print(details["original_title"]);
        if (widget.snapshot.docs[0].data()["mylist"][i]["id"] ==
            details["id"]) {
          setState(() {
            added = true;
            isloading = false;
          });
          break;
        } else {
          setState(() {
            added = false;
            isloading = false;
          });
        }
      }
    }
  }

  void onTap(int pageValue) {
    setState(() {
      selectedIndex = pageValue;
      data = totaldata;
      pageController.jumpToPage(pageValue);
    });
  }

  Widget homescreen() {
    return isloading
        ? Container(
      child: Center(child: CircularProgressIndicator()),
    )
        : mylist
        ? CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          leading: Image.asset(
            "assets/n_symbol.png",
            scale: 20,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    isloading = true;
                    mylist = false;
                    data = widget.tvlist;
                    isloading = false;
                  });
                },
                child: Text(
                  "TV Shows",
                  style: TextStyle(
                      color: data == widget.tvlist
                          ? Colors.red
                          : Colors.white,
                      fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    isloading = true;
                    mylist = false;
                    data = widget.movielist;
                    isloading = false;
                  });
                },
                child: Text(
                  "Movies",
                  style: TextStyle(
                      color: data == widget.movielist
                          ? Colors.red
                          : Colors.white,
                      fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    isloading = true;
                    data == totaldata;
                    mylist = true;
                    isloading = false;
                  });
                },
                child: Text(
                  "My List",
                  style: TextStyle(
                      color: mylist ? Colors.red : Colors.white,
                      fontSize: 18),
                ),
              ),
            )
          ],
        ),
        widget.snapshot.docs[0]["mylist"].length != 0
            ? SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      isloading = true;
                    });
                    var details = await gettingmoviedetails(
                        widget.snapshot.docs[0].data()["mylist"]
                        [index]["id"]);
                    setState(() {
                      isloading = false;
                    });
                    print(details);
                    Navigator.push(
                        scaffoldKey.currentContext,
                        MaterialPageRoute(
                            builder: (context) => MoreDetails(
                              details: details,
                              movie: movie,
                              user: widget.user,
                              snapshot: widget.snapshot,
                            )));
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    height: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10)),
                    child: Image.network(
                      "https://image.tmdb.org/t/p/original${widget.snapshot.docs[0].data()["mylist"][index]["poster_path"]}",
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
              childCount:
              widget.snapshot.docs[0].data()["mylist"].length,
            ),
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2))
            : SliverToBoxAdapter(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                Image.asset(
                  "assets/icons/tick.png",
                  scale: 2,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 40.0, right: 20, left: 20),
                  child: Text(
                    "Add movies & TV shows to your list so you can easily find them later.",
                    style: TextStyle(
                        color: Colors.grey, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 50, horizontal: 30),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        data = totaldata;
                        mylist = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(5),
                          color: Colors.white),
                      padding: EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      child: Center(
                          child: Text(
                            "FIND SOMETHING TO WATCH",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    )
        : CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          leading: Image.asset(
            "assets/n_symbol.png",
            scale: 20,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    isloading = true;
                    data = widget.tvlist;
                    mylist = false;
                    isloading = false;
                  });
                  data[0]['type'] == "movie"
                      ? checkingmylistformovie()
                      : checkingmylistfortv();
                },
                child: Text(
                  "TV Shows",
                  style: TextStyle(
                      color: data == widget.tvlist
                          ? Colors.red
                          : Colors.white,
                      fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    isloading = true;
                    data = widget.movielist;
                    mylist = false;
                    isloading = false;
                  });
                  data[0]['type'] == "movie"
                      ? checkingmylistformovie()
                      : checkingmylistfortv();
                },
                child: Text(
                  "Movies",
                  style: TextStyle(
                      color: data == widget.movielist
                          ? Colors.red
                          : Colors.white,
                      fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FlatButton(
                onPressed: () async {
                  setState(() {
                    isloading = true;
                    data = totaldata;
                  });
                  QuerySnapshot snapshot =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .where(
                    "email",
                    isEqualTo: widget.user.email,
                  )
                      .get();
                  setState(() {
                    widget.snapshot = snapshot;
                    isloading = false;
                    mylist = true;
                  });
                },
                child: Text(
                  "My List",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            )
          ],
        ),
        SliverToBoxAdapter(
          child: GestureDetector(
            onTap: () async {
              setState(() {
                isloading = true;
              });
              var details = data[0]["type"] == "movie"
                  ? await gettingmoviedetails(data[0]["id"])
                  : await gettingtvdetails(data[0]["id"]);
              setState(() {
                isloading = false;
              });
              print(details);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MoreDetails(
                        details: details,
                        movie: movie,
                        user: widget.user,
                        snapshot: widget.snapshot,
                      )));
            },
            child: Container(
              height: 300,
              child: Image.network(
                "https://image.tmdb.org/t/p/original${data[0]["poster_path"]}",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
            child: data[0]["genre_ids"].length == 0
                ? Container()
                : Container(
              height: 30,
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: data[0]["genre_ids"].length,
                  itemBuilder: (context, index) {
                    return Container(
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
                              genres[data[0]["genre_ids"]
                              [index]],
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            )),
        SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                onPressed: () async {
                  var details = data[0]["type"] == "movie"
                      ? await gettingmoviedetails(data[0]["id"])
                      : await gettingtvdetails(data[0]["id"]);
                  List mylist;
                  setState(() {
                    mylist = widget.snapshot.docs[0].data()["mylist"];

                    mylist.add(details);
                  });
                  print(mylist);
                  Map<String, dynamic> userMap = {
                    "email": widget.user.email,
                    "username":
                    widget.snapshot.docs[0].data()["username"],
                    "mylist": mylist
                  };
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.snapshot.docs[0].id)
                      .update(userMap);
                  setState(() {
                    added = true;
                  });
                },
                child: Column(
                  children: [
                    Icon(added ? Icons.check : Icons.add,
                        color: Colors.white, size: 30),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        added ? "Added" : "My List",
                        style: TextStyle(
                            color: Colors.white, fontSize: 18.0),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                child: FlatButton.icon(
                    onPressed: ()async {
                     var key =  data[0]["type"] == "movie" ? await getData("https://api.themoviedb.org/3/movie/${data[0]["id"]}/videos?api_key=1700c4a8b5698384abc2e8d34ff5b413&language=en-US") : await getData("https://api.themoviedb.org/3/tv/${data[0]["id"]}/videos?api_key=1700c4a8b5698384abc2e8d34ff5b413&language=en-US");
                     print(key);
                     Navigator.push(scaffoldKey.currentContext, MaterialPageRoute(builder: (context) => video(title: data[0]["type"] == "movie" ? data[0]["original_title"] : data[0]["original_name"],
                         videoid: key["results"][0]["key"],)));
                    },
                    icon: Icon(
                      Icons.play_arrow,
                      size: 40,
                      color: Colors.black,
                    ),
                    label: Text(
                      "Play",
                      style: TextStyle(
                          color: Colors.black, fontSize: 18),
                    )),
              ),
              FlatButton(
                onPressed: () async {
                  setState(() {
                    isloading = true;
                  });
                  var details = data[0]["type"] == "movie"
                      ? await gettingmoviedetails(data[0]["id"])
                      : await gettingtvdetails(data[0]["id"]);
                  setState(() {
                    isloading = false;
                  });
                  print(details);
                  Navigator.push(
                      scaffoldKey.currentContext,
                      MaterialPageRoute(
                          builder: (context) => MoreDetails(
                              details: details,
                              movie: movie,
                              user: widget.user,
                              snapshot: widget.snapshot)));
                },
                child: Column(
                  children: [
                    Image.asset(
                      "assets/icons/info.jpg",
                      scale: 13,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Info",
                        style: TextStyle(
                            color: Colors.white, fontSize: 18.0),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10, top: 20),
            child: Text(
              'Popular on Netflix',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        isloading = true;
                      });
                      var details = data[index]["type"] == "movie"
                          ? await gettingmoviedetails(
                          data[index]["id"])
                          : await gettingtvdetails(data[index]["id"]);
                      setState(() {
                        isloading = false;
                      });
                      print(details);
                      Navigator.push(
                          scaffoldKey.currentContext,
                          MaterialPageRoute(
                              builder: (context) => MoreDetails(
                                  details: details,
                                  movie: movie,
                                  user: widget.user,
                                  snapshot: widget.snapshot)));
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      height: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      child: Image.network(
                        "https://image.tmdb.org/t/p/original${data[index]["poster_path"]}",
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10, top: 20),
            child: Text(
              'Action & Adventure',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return data[index]["genre_ids"].contains(28) ||
                      totaldata[index]["genre_ids"].contains(12)
                      ? GestureDetector(
                    onTap: () async {
                      setState(() {
                        isloading = true;
                      });
                      var details =
                      data[index]["type"] == "movie"
                          ? await gettingmoviedetails(
                          data[index]["id"])
                          : await gettingtvdetails(
                          data[index]["id"]);
                      setState(() {
                        isloading = false;
                      });
                      print(details);
                      Navigator.push(
                          scaffoldKey.currentContext,
                          MaterialPageRoute(
                              builder: (context) => MoreDetails(
                                  details: details,
                                  movie: movie,
                                  user: widget.user,
                                  snapshot: widget.snapshot)));
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      height: 150,
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(10)),
                      child: Image.network(
                        "https://image.tmdb.org/t/p/original${data[index]["poster_path"]}",
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                      : Container();
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10, top: 20),
            child: Text(
              'Comedies',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return data[index]["genre_ids"].contains(35)
                      ? GestureDetector(
                    onTap: () async {
                      setState(() {
                        isloading = true;
                      });
                      var details =
                      data[index]["type"] == "movie"
                          ? await gettingmoviedetails(
                          data[index]["id"])
                          : await gettingtvdetails(
                          data[index]["id"]);
                      setState(() {
                        isloading = false;
                      });
                      print(details);
                      Navigator.push(
                          scaffoldKey.currentContext,
                          MaterialPageRoute(
                              builder: (context) => MoreDetails(
                                  details: details,
                                  movie: movie,
                                  user: widget.user,
                                  snapshot: widget.snapshot)));
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      height: 150,
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(10)),
                      child: Image.network(
                        "https://image.tmdb.org/t/p/original${data[index]["poster_path"]}",
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                      : Container();
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10, top: 20),
            child: Text(
              'Mystery & Horror',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return data[index]["genre_ids"].contains(27) ||
                      data[index]["genre_ids"].contains(9648)
                      ? GestureDetector(
                    onTap: () async {
                      setState(() {
                        isloading = true;
                      });
                      var details =
                      data[index]["type"] == "movie"
                          ? await gettingmoviedetails(
                          data[index]["id"])
                          : await gettingtvdetails(
                          data[index]["id"]);
                      setState(() {
                        isloading = false;
                      });
                      print(details);
                      Navigator.push(
                          scaffoldKey.currentContext,
                          MaterialPageRoute(
                              builder: (context) => MoreDetails(
                                  details: details,
                                  movie: movie,
                                  user: widget.user,
                                  snapshot: widget.snapshot)));
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      height: 150,
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(10)),
                      child: Image.network(
                        "https://image.tmdb.org/t/p/original${data[index]["poster_path"]}",
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                      : Container();
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10, top: 20),
            child: Text(
              'Crime & Thriller',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return data[index]["genre_ids"].contains(80) ||
                      data[index]["genre_ids"].contains(18)
                      ? GestureDetector(
                    onTap: () async {
                      setState(() {
                        isloading = true;
                      });
                      var details =
                      data[index]["type"] == "movie"
                          ? await gettingmoviedetails(
                          data[index]["id"])
                          : await gettingtvdetails(
                          data[index]["id"]);
                      setState(() {
                        isloading = false;
                      });
                      print(details);
                      Navigator.push(
                          scaffoldKey.currentContext,
                          MaterialPageRoute(
                              builder: (context) => MoreDetails(
                                  details: details,
                                  movie: movie,
                                  user: widget.user,
                                  snapshot: widget.snapshot)));
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      height: 150,
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(10)),
                      child: Image.network(
                        "https://image.tmdb.org/t/p/original${data[index]["poster_path"]}",
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                      : Container();
                },
              ),
            ),
          ),
        ),
        data == widget.movielist || data == totaldata
            ? SliverToBoxAdapter(
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10, top: 20),
            child: Text(
              'Upcoming Movies',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
          ),
        )
            : SliverToBoxAdapter(
          child: Container(),
        ),
        data == widget.movielist || data == totaldata
            ? SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.upcomingmovies.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        isloading = true;
                      });
                      var details = await gettingmoviedetails(
                          widget.upcomingmovies[index]["id"]);
                      setState(() {
                        isloading = false;
                      });
                      print(details);
                      Navigator.push(
                          scaffoldKey.currentContext,
                          MaterialPageRoute(
                              builder: (context) => MoreDetails(
                                  details: details,
                                  movie: movie,
                                  user: widget.user,
                                  snapshot: widget.snapshot)));
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      height: 150,
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(10)),
                      child: Image.network(
                        "https://image.tmdb.org/t/p/original${widget.upcomingmovies[index]["poster_path"]}",
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        )
            : SliverToBoxAdapter(
          child: Container(),
        ),
      ],
    );
  }

  Widget Search() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()async {
          setState(() {
            isloading = true;
            print(totaldata);
            if(search.text.isNotEmpty){
              searched =true;
              searchdata = [];
              for(int i=0; i< totaldata.length; i++){
                if(totaldata[i]["type"] =="movie" ? totaldata[i]['original_title'].toLowerCase().contains(search.text.toLowerCase().trim()) : totaldata[i]['original_name'].toLowerCase().contains(search.text.toLowerCase().trim())){
                  searchdata.add(totaldata[i]);
                }
              }
            }else{
              searched = false;
              searchdata = totaldata;
            }
            isloading = false;
          });
        },icon: Icon(Icons.search, color:Colors.grey, size: 30,)),
        title: TextField(
          controller: search,
          decoration: InputDecoration(
              hintText: "Search for a movie or a show.",
              hintStyle: TextStyle(color:Colors.white),
              suffixIcon: IconButton(
                onPressed: () {

                },
                icon: Icon(Icons.mic, color: Colors.grey),
              )
          ),
        ),
      ),
      body: isloading? Container(child: Center(child: CircularProgressIndicator(),),) : searchdata.isEmpty? Container(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("No Results.", style: TextStyle(color: Colors.white, fontSize: 18 ),),
      ),) : Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(searched? "Top Results": "Popular Searches", style: TextStyle(color:Colors.white, fontSize: 30, fontWeight:FontWeight.bold),),
            ),
          ),
          Expanded(
            flex: 10,
            child: ListView.builder(
                shrinkWrap: true,itemCount: searchdata.length,itemBuilder: (context, index){
              return GestureDetector(
                onTap: () async {
                  setState(() {
                    isloading = true;
                  });
                  var details = searchdata[index-1]["type"] == "movie"
                      ? await gettingmoviedetails(searchdata[index]["id"])
                      : await gettingtvdetails(searchdata[index]["id"]);

                  print(details);
                  Navigator.push(
                      scaffoldKey.currentContext,
                      MaterialPageRoute(
                          builder: (context) => MoreDetails(
                            details: details,
                            movie: movie,
                            user: widget.user,
                            snapshot: widget.snapshot,
                          )));
                  setState(() {
                    isloading = false;
                  });
                },
                child: Container(
                  height: 130,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                            child: SizedBox(
                              child: Image.network("https://image.tmdb.org/t/p/original${searchdata[index]["poster_path"]}",
                                fit: BoxFit.fitWidth,),
                            ),
                          ),
                        ),
                        Expanded(flex: 3,child: Container(padding: EdgeInsets.all(5), child: Text(searchdata[index]["type"]=="movie"? searchdata[index]["original_title"]:searchdata[index]["original_name"] ,style:TextStyle(color:Colors.white, fontSize: 20,) ),)),
                        Expanded(flex: 1,child: Icon(Icons.play_arrow, color:Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          )
          ,
        ],
      ),
    );
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView.builder(itemCount: widget.upcomingmovies.length,itemBuilder: (context, index){
        return itemCont(context, widget.upcomingmovies[index]["original_title"], widget.upcomingmovies[index]["overview"], "https://image.tmdb.org/t/p/original${widget.upcomingmovies[index]["poster_path"]}", widget.upcomingmovies[index]["genre_ids"]);
      }),
    );
  }

  Widget Download() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
          ),
          Icon(Icons.download_rounded, size: 150, color: Colors.grey,),
          Padding(
            padding: const EdgeInsets.only(
                top: 40.0, right: 20, left: 20),
            child: Text(
              "Movies and TV shows that you download appear here",
              style: TextStyle(
                  color: Colors.grey, fontSize: 25),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                vertical: 50, horizontal: 30),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  data = totaldata;
                  mylist = false;
                  pageController.jumpToPage(0);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(5),
                    color: Colors.white),
                padding: EdgeInsets.symmetric(
                    vertical: 20, horizontal: 10),
                child: Center(
                    child: Text(
                      "FIND SOMETHING TO WATCH",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget More() {
    return Center(
      child: GestureDetector(
        onTap: () {
          auth.signOut();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => onBoardingScreen()));
        },
        child: Container(
          child: Text("Sign Out"),
        ),
      ),
    );
  }

  @override
  void initState() {
    totaldata = List.from(widget.movielist)..addAll(widget.tvlist);
    data = totaldata;
    searchdata = totaldata;
    data.shuffle();
    checkingmylistformovie();

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
