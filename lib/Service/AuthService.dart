import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8080/auth';
  String _token = '';

  String get token => _token;

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      _token = response.body;
      return true;
    } else {
      return false;
    }
  }

  void logout() {
    _token = '';
  }

  bool isTokenExpired() {
    if (_token.isEmpty) return true;
    return JwtDecoder.isExpired(_token);
  }

  Future<void> refreshToken() async {
    final response = await http.post(
      Uri.parse('$baseUrl/refresh'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      _token = response.body;
    } else {
      logout();
    }
  }
}