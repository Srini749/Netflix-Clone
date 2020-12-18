import 'package:flutter/material.dart';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MoreDetails extends StatefulWidget {
  var details;
  bool movie;
  final User user;
  QuerySnapshot snapshot;
  MoreDetails({this.details, this.movie, this.user, this.snapshot});
  @override
  _MoreDetailsState createState() => _MoreDetailsState();
}

class _MoreDetailsState extends State<MoreDetails> {
  var details;
  bool movie;
  bool isloading = false;
  bool showmore = false;
  bool added;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool episode =false;


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

  castdialog(){
    return showDialog(
        context: context,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.black54),
          child: Dialog(
            child: Container(
              decoration: BoxDecoration(color: Colors.black54),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text("Cast", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),),
                    ),
                    Column(
                      children:  widget.details["cast"].map<Widget>((item) {
                        return item.containsKey("character")? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${item["original_name"]}, ",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15),
                          ),
                        ) : Container();
                      }).toList(),
                    ),
                    widget.details["crew"].length !=0 ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text("Producers", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),),
                    ):Container(),
                    Column(
                      children:  widget.details["crew"].map<Widget>((item) {
                        return item.containsValue("Producer") || item.containsValue("Executive Producer")? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${item["original_name"]}, ",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15),
                          ),
                        ) : Container();
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }


  checkingmylistformovie(){
    setState(() {
      isloading = true;
      widget.snapshot.docs[0].data()["mylist"].removeWhere((item) => item["type"]=="tv");
    });
    if (widget.snapshot.docs[0].data()["mylist"].length != 0) {
      for (int i = 0; i < widget.snapshot.docs[0].data()["mylist"].length; i++) {
        print(widget.snapshot.docs[0].data()["mylist"][i]["original_title"]);
        print( widget.details["original_title"]);
        if (widget.snapshot.docs[0].data()["mylist"][i]["original_title"] ==  widget.details["original_title"]) {
          setState(() {
            added = true;
            isloading = false;
          });
          break;
        }else{
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

  checkingmylistfortv(){
    setState(() {
      isloading = true;
      widget.snapshot.docs[0].data()["mylist"].removeWhere((item) => item["type"]=="movie");
    });
    if (widget.snapshot.docs[0].data()["mylist"].length != 0) {
      for (int i = 0; i < widget.snapshot.docs[0].data()["mylist"].length; i++) {
        print(widget.snapshot.docs[0].data()["mylist"][i]["title"]);
        print( widget.details["original_title"]);
        if (widget.snapshot.docs[0].data()["mylist"][i]["id"] ==  widget.details["id"]) {
          setState(() {
            added = true;
            isloading = false;
          });
          break;
        }else{
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

  @override
  void initState() {
    widget.movie? checkingmylistformovie(): checkingmylistfortv();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      body: isloading? Container(child: Center(child: CircularProgressIndicator()),): CustomScrollView(
        slivers: [
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Container(
                          height: 250,
                          width: 150,
                          child: Image.network(
                              "https://image.tmdb.org/t/p/original${widget.details["poster_path"]}"),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: Text(
                              widget.movie
                                  ? widget.details["release_date"]
                                      .substring(0, 4)
                                  : widget.details["first_air_date"]
                                      .substring(0, 4),
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(2)),
                              child: Text(
                                "18+",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ),
                          widget.movie
                              ? Text(
                                  "${widget.details["runtime"] ~/ 60}hr ${widget.details["runtime"] % 60}mins",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 15))
                              : Text(
                                  "${widget.details["seasons"].length} seasons",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 20)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 45, 20, 20),
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          child: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(
                                Icons.play_arrow,
                                color: Colors.black,
                                size: 30,
                              ),
                              label: Text(
                                "Play",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade500.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(5)),
                          child: FlatButton.icon(
                              onPressed: null,
                              icon: Image.asset(
                                "assets/icons/download.png",
                                color: Colors.white,
                                scale: 20,
                              ),
                              label: Text(
                                widget.movie ? "Download" : "Download S1:E1",
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          widget.details["overview"],
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          castdialog();
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.start,
                                    spacing: 5,
                                    children: <Widget>[
                                      Text("Starring: ", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                                      for (int i = 0;
                                          i < widget.details["cast"].length / 3;
                                          i++)
                                        widget.details["cast"][i]
                                                .containsKey("character")
                                            ? Text(
                                                "${widget.details["cast"][i]["original_name"]}, ",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              )
                                            : Text(""),
                                      Text("....", style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15)),
                                      GestureDetector(
                                        onTap: () {
                                          castdialog();
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0, top: 3),
                                          child: Text(
                                            showmore ? "SHOW LESS" : "SHOW MORE",
                                            style: TextStyle(color: Colors.grey, fontSize: 15),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MaterialButton(
                              onPressed: () async {
                                List mylist;
                                setState(() {
                                  mylist =
                                      widget.snapshot.docs[0].data()["mylist"];
                                  mylist.add(widget.details);
                                });
                                print(mylist);
                                Map<String, dynamic> userMap = {
                                  "email": widget.user.email,
                                  "username": widget.snapshot.docs[0]
                                      .data()["username"],
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
                                      color: Colors.white),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      added ? "Added" : "My List",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            MaterialButton(
                              onPressed: null,
                              child: Column(
                                children: [
                                  Icon(Icons.thumb_up, color: Colors.white),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "Rate",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            MaterialButton(
                              onPressed: null,
                              child: Column(
                                children: [
                                  Icon(Icons.share, color: Colors.white),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "Share",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),


                    ],
                  ),
                ),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                          "https://image.tmdb.org/t/p/original${widget.details["poster_path"]}",
                        ),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.black87, BlendMode.darken))),
              ),
            ),
            expandedHeight: MediaQuery.of(context).size.height * 1.1,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 20, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            episode = false;
                          });
                        },
                        child: Text(
                          "MORE LIKE THIS",
                          style: TextStyle(color: episode? Colors.white :Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    Expanded(
                    child: widget.movie? Container():  GestureDetector(
                      onTap: (){
                        setState(() {
                          episode = true;
                        });
                      },
                      child: Text(
                        "EPISODES",
                        style: TextStyle(color: episode? Colors.red : Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    )
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
