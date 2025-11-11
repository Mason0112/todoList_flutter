import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';
import '../models/user.dart';
import '../models/login_response.dart';

class ApiService {
  static const baseUrl = 'http://localhost:8080/api';


  Future<LoginResponse> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('登入失敗: ${response.body}');
    }
  }

  Future<LoginResponse> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': username,
        'password': password,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('註冊失敗: ${response.body}');
    }
  }

  Future<User> getCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception('取得使用者失敗');
    }
  }

  // ========== Todo 相關 ==========

  Future<List<Todo>> getTodos(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/todos'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Todo.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Token 過期，請重新登入');
    } else {
      throw Exception('取得 Todo 失敗');
    }
  }

  Future<Todo> createTodo(String token, String task, bool completed) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'task': task,
        'completed': completed,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Todo.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Token 過期，請重新登入');
    } else {
      throw Exception('新增 Todo 失敗');
    }
  }

  Future<Todo> updateTodo(String token, Todo todo) async {
    final response = await http.put(
      Uri.parse('$baseUrl/todos/${todo.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode == 200) {
      return Todo.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Token 過期，請重新登入');
    } else {
      throw Exception('更新 Todo 失敗');
    }
  }

  Future<void> deleteTodo(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/todos/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Token 過期，請重新登入');
    } else {
      throw Exception('刪除 Todo 失敗');
    }
  }
}