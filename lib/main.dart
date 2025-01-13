import 'package:flutter/material.dart';
import 'package:medkart_user/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart'; // Import AuthProvider
import 'screens/home_screen.dart'; // Import HomeScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [    
        ChangeNotifierProvider(create: (context) => AuthProvider()), // Provide AuthProvider
        ChangeNotifierProvider(create: (context) => CartProvider()), // Provide CartProvider
      ],
      child: MaterialApp(
        title: 'Online Product & Order Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
