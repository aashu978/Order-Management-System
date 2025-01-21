import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAdminPage extends StatefulWidget {
  @override
  _AddAdminPageState createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController(text: "admin"); // Default role set to "admin"
  bool isLoading = false;
  String message = '';

  // Function to call the API to add admin
  Future<void> addAdmin() async {
    final url = Uri.parse('http://localhost:5000/auth/signup');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
          'role': _roleController.text,
        }),
      );

      final responseData = json.decode(response.body);

      setState(() {
        isLoading = false;
        if (response.statusCode == 201) {
          // If successful, show a confirmation message and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Admin added successfully!')),
          );
          Navigator.pop(context, true); // Pass a success indicator back
        } else {
          message = responseData['message'] ?? 'Something went wrong';
        }
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        message = 'Something went wrong';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Admin'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400), // Set a maximum width for the card
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Admin",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _roleController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.admin_panel_settings_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, // Button takes full width
                    child: ElevatedButton(
                      onPressed: isLoading ? null : addAdmin,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Add Admin'),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (message.isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
