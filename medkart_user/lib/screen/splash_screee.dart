  import 'package:flutter/material.dart';
  import 'package:flutter/widgets.dart';
import 'package:medkart_user/screen/prodcut.dart';
  import 'dart:async';


  class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2 ), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProdcutScreen()),
      );
    });
  }


    @override
    Widget build(BuildContext context) {
      // Using a Timer to navigate to the HomePage after 3 seconds

      return Scaffold(
        backgroundColor: Colors.teal,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo (you can replace this with your logo asset)
              Image.asset(
                'assets/mm.jpg',  // Make sure the path is correct
                height: 100,         // Adjust the size of the logo as needed
              ),
              SizedBox(height: 20),
              // App name or tagline (optional)
              Text(
                'Welcome to Medkart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
}
