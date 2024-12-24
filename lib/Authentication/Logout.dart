import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8080/auth';
  String _token = '';
  String get token => _token;
  void logout() {
    _token = '';
  }
  bool isTokenExpired() {
    if (_token.isEmpty) return true;
    return JwtDecoder.isExpired(_token);
  }


}