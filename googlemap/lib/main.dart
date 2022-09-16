import 'dart:async';

import 'package:flutter/material.dart';
import 'package:googlemap/MapScreen.dart';
import 'package:firebase_core/firebase_core.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home:  Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Splash extends StatefulWidget {


  @override
  _MAppState createState() => _MAppState();
}

class _MAppState extends State<Splash> {
  @override
  void initState() {
    startSplashScreen();


    super.initState();


  }
  startSplashScreen() {
    var duration = const Duration(seconds: 4);
    return Timer(duration, () async {
      Navigator.pushReplacement(
        context,
        new MaterialPageRoute(builder: (context) => MapScreen()),
      );


    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

        backgroundColor:Colors.blueAccent,
        body:Center(
          child: Text("Petroute",style:TextStyle(fontSize: 38,color:Colors.white,fontWeight: FontWeight.bold,fontFamily:"cursive",)),
        )






    );

  }
}


