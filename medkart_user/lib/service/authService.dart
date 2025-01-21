import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class AuthService {
  final String baseUrl = 'http://localhost:5000/auth';  // Your backend API URL

  // Sign Up method
  Future<Map<String, dynamic>> signup(String username, String password, String role) async {
    final url = Uri.parse('$baseUrl/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        // Successfully created user
        return {'success': true, 'message': json.decode(response.body)['message'], 'user': json.decode(response.body)['user']};
      } else {
        return {'success': false, 'message': json.decode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  // Log In method
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Store the JWT token for future requests
        _storeToken(data['token']);
        return {'success': true, 'token': data['token']};
      } else {
        return {'success': false, 'message': json.decode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  // Store the JWT token using shared preferences
  void _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Retrieve JWT token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}