import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:netflix_clone/screens/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:netflix_clone/screens/SignUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInPage extends StatefulWidget {
  final List<dynamic> movielist;
  final List<dynamic> tvlist;
  final List<dynamic> upcomingmovies;
  SignInPage({this.movielist, this.tvlist, this.upcomingmovies,});
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth auth  = FirebaseAuth.instance;
  bool verified = true;
  bool incorrect = false;
  bool isloading =false;

  Future signinwithemailandpassword(String email, String password) async {
    User firebaseuser;
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(email: email, password: password);
      firebaseuser = result.user;
      print(firebaseuser.email);
      if(firebaseuser!=null){
        return firebaseuser;
      }else{
        setState(() {
          isloading = false;
          incorrect = true;
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isloading = false;
        incorrect = true;
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
      ): Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  height: 60,
                  child: Image.asset('assets/logo.png'),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 100,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        child: TextFormField(
                          validator: (val){
                            return val.isEmpty? "Field Required": incorrect? "Incorrect username or password" : verified? null: "Email not verified.";
                          },
                          controller: email,
                          decoration: InputDecoration(
                              labelStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              border: InputBorder.none,
                              labelText: "Email"),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        child: TextFormField(
                          validator: (val){
                            return val.isEmpty? "Field Required": null;
                          },
                          controller: password,
                          obscureText: true,
                          decoration: InputDecoration(
                              labelStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              border: InputBorder.none,
                              labelText: "Password"),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: ()async{
                          if(formKey.currentState.validate()){
                            setState(() {
                              isloading =true;
                            });
                            User user = await signinwithemailandpassword(email.text, password.text);
                            if(user!=null){
                              QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').where("email", isEqualTo: email.text,).get();
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage(user: user, movielist: widget.movielist,tvlist: widget.tvlist,upcomingmovies: widget.upcomingmovies,snapshot: snapshot,)));
                              setState(() {
                                verified = false;
                                isloading =false;
                              });
                            }else{
                              setState(() {
                                isloading=false;
                                incorrect=false;
                              });
                            }
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.grey[600], width: 2)),
                          child: Text("Sign In"),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text("Need Help?"),
                      SizedBox(
                        height: 15,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                        },
                        child: Text(
                          "New to Netflix? Sign up now.",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Sign-in is protected by Google reCAPTCHA to ensure you're not a bot. Learn more.",
                        style: TextStyle(fontSize: 12,),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
