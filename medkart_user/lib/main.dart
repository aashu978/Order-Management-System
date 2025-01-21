import 'package:flutter/material.dart';
import 'package:medkart_user/screen/splash_screee.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medkart',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SplashScreen(), // Set SplashScreen as the initial screen
      debugShowCheckedModeBanner: false,
    );
  }
}
