import 'package:flutter/material.dart';
import 'package:medkart_user/providers/product_provider.dart';
import 'package:medkart_user/screens/home_screen.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProductProvider(), // Provide the ProductProvider
      child: MaterialApp(
        title: 'Product App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(), // HomeScreen has access to ProductProvider now
      ),
    );
  }
}
