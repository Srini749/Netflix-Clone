import 'package:flutter/material.dart';
import 'screens/SplashScreen.dart';
import 'widgets/custom_theme.dart';
import 'package:firebase_cor/firebase_core.dart';


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