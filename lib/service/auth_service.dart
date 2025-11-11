import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/login_response.dart';
import 'api_service.dart';


class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user';

  final ApiService _apiService;

  // Inject ApiService via constructor
  AuthService(this._apiService);


  // 登入
  Future<LoginResponse> login(String username, String password) async {
    final response = await _apiService.login(username, password);

    // 儲存 Token 和使用者資訊
    if (response.token != null) {
      await saveToken(response.token!);
      await saveUser(response.user);
    }

    return response;
  }

  // 註冊
  Future<LoginResponse> register(String username, String password) async {
    final response = await _apiService.register(username, password);

    // 儲存 Token 和使用者資訊
    if (response.token != null) {
      await saveToken(response.token!);
      await saveUser(response.user);
    }

    return response;
  }

  // 儲存 Token
  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // 取得 Token
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 儲存使用者資訊
  Future<void> saveUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // 取得使用者資訊
  Future<User?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // 檢查是否已登入
  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // 登出
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<String> getValidToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('未登入，請先登入');
    }
    return token;
  }

}