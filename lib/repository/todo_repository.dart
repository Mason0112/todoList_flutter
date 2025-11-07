import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/todo.dart';

class TodoRepository {
  static const String _key = 'todos';

  // 儲存所有 Todo
  Future<void> saveTodos(List<Todo> todos) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // 1. 每個 Todo 轉成 Map
      List<Map<String, dynamic>> jsonList =
      todos.map((todo) => todo.toJson()).toList();

      // 2. 轉成 JSON 字串
      String jsonString = jsonEncode(jsonList);

      // 3. 儲存
      await prefs.setString(_key, jsonString);

      print('✅ 已儲存 ${todos.length} 筆 Todo');
    } catch (e) {
      print('❌ 儲存失敗: $e');
      rethrow;
    }
  }

  // 讀取所有 Todo
  Future<List<Todo>> loadTodos() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // 1. 讀取 JSON 字串
      String? jsonString = prefs.getString(_key);

      // 2. 如果沒有資料，回傳空列表
      if (jsonString == null || jsonString.isEmpty) {
        print('ℹ️ 沒有儲存的 Todo');
        return [];
      }

      // 3. JSON 字串 → List<dynamic>
      List<dynamic> jsonList = jsonDecode(jsonString);

      // 4. 每個 Map 轉成 Todo
      List<Todo> todos = jsonList
          .map((json) => Todo.fromJson(json as Map<String, dynamic>))
          .toList();

      print('✅ 已讀取 ${todos.length} 筆 Todo');
      return todos;
    } catch (e) {
      print('❌ 讀取失敗: $e');
      return [];
    }
  }

  // 清空所有 Todo
  Future<void> clearTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    print('✅ 已清空所有 Todo');
  }
}