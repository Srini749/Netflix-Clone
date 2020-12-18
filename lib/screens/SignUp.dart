import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:netflix_clone/screens/SignIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:netflix_clone/screens/Splash Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  bool _isCheck = false;
  TextEditingController email = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  final FirebaseAuth auth  = FirebaseAuth.instance;
  bool incorrect = false;


  Future signupwithemailandpassword(String email, String password) async{
    try{UserCredential result = await auth.createUserWithEmailAndPassword(email: email, password: password);
    User firebaseuser = result.user;
    await firebaseuser.sendEmailVerification();
    return firebaseuser != null ? firebaseuser.uid : null;}
    catch (e) {
      print(e.toString());
      setState(() {
        incorrect = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back),
                      ),
                      Container(
                        height: 70,
                        width: 70,
                        child: Image.asset('assets/n_symbol.png'),
                      ),
                    ],
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
                      InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignInPage(),
                                ));
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
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        "Sign up to start your membership.",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        "Create your account",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                            return val.isEmpty? "Field Required.": incorrect? "Incorrect username or password": null;
                          },
                          controller: email,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
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
                            return val.isEmpty? "Field Required.": null;
                          },
                          controller: username,
                          decoration: InputDecoration(
                            labelText: "Username",
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
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
                            return val.isEmpty? "Field Required" : val.length <=6? "Password is not strong enough." : null;
                          },
                          controller: password,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
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
                            return val.isEmpty? null : confirmpassword.text.trim() == password.text.trim() ?null: "Password does not match.";
                          },
                          controller: confirmpassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25,),
                      Row(
                        children: [
                          Checkbox(
                            value: _isCheck,
                            onChanged: (value) {
                              setState(() {
                                _isCheck = value;
                              });
                            },
                          ),
                          Text("Please do not email me Netflix special offers.")
                        ],
                      ),
                      SizedBox(height: 15,),
                      GestureDetector(
                        onTap: ()async{
                          if(formKey.currentState.validate()){
                            await signupwithemailandpassword(email.text, password.text);
                            Map<String,dynamic> userMap = {"email" : email.text, "username" : username.text, "mylist":[]};
                            await FirebaseFirestore.instance.collection("users").add(userMap);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SplashScreen(status: true,)));
                          }
                        },
                        child: Container(
                          width: double.maxFinite,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          child: Text("Continue"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
