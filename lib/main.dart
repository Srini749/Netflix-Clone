import 'package:flutter/material.dart';
import 'package:netflix_clone/screens/Splash Screen.dart';
import 'widgets/custom_theme.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      title: 'Netflix Clone',
      home: SplashScreen(status: false),
    );
  }
}