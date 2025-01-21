import 'package:flutter/material.dart';
import 'package:medkart_manager/screen/admin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Authentication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',  // Start with home screen
      routes: {
        '/': (context) => AdminHomeScreen(),  // HomeScreen as the initial screen
        // '/signup': (context) => SignupScreen(),
        // '/login': (context) => LoginScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}