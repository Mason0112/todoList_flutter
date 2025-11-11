import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/todo.dart';
import '../service/todo_service.dart';
import '../service_locator.dart';

class TodoRepository {
  static const String _key = 'todos';
  final _todoService = getIt<TodoService>();

  // ========== 私有方法：本地快取 ==========
  // 儲存到本地快取
  Future<void> _saveToCache(List<Todo> todos) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> jsonList =
          todos.map((todo) => todo.toJson()).toList();
      String jsonString = jsonEncode(jsonList);
      await prefs.setString(_key, jsonString);
      print('✅ 已快取 ${todos.length} 筆 Todo');
    } catch (e) {
      print('❌ 快取儲存失敗: $e');
    }
  }
  // 從本地快取讀取
  Future<List<Todo>> _loadFromCache() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_key);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      List<dynamic> jsonList = jsonDecode(jsonString);
      List<Todo> todos = jsonList
          .map((json) => Todo.fromJson(json as Map<String, dynamic>))
          .toList();

      print('✅ 從快取讀取 ${todos.length} 筆 Todo');
      return todos;
    } catch (e) {
      print('❌ 快取讀取失敗: $e');
      return [];
    }
  }


  // 讀取所有 Todo (優先 API，失敗則用快取)
  Future<List<Todo>> loadTodos() async {
    try {
      // 1. 先從 API 取得最新資料
      final todos = await _todoService.getTodos();

      // 2. 成功後更新快取
      await _saveToCache(todos);

      print('✅ 從 API 讀取 ${todos.length} 筆 Todo');
      return todos;
    } catch (e) {
      print('❌ API 讀取失敗: $e，使用本地快取');

      // 3. API 失敗時使用快取
      return await _loadFromCache();
    }
  }

  // 新增 Todo
  Future<Todo> createTodo(String task) async {
    try {
      // 1. 先透過 API 新增
      final newTodo = await _todoService.createTodo(task);

      // 2. 成功後更新快取
      final todos = await _loadFromCache();
      todos.add(newTodo);
      await _saveToCache(todos);

      print('✅ 已新增 Todo: ${newTodo.task}');
      return newTodo;
    } catch (e) {
      print('❌ 新增 Todo 失敗: $e');
      rethrow;
    }
  }

  // 更新 Todo
  Future<Todo> updateTodo(Todo todo) async {
    try {
      // 1. 先透過 API 更新
      final updatedTodo = await _todoService.updateTodo(todo);

      // 2. 成功後更新快取
      final todos = await _loadFromCache();
      final index = todos.indexWhere((t) => t.id == updatedTodo.id);
      if (index != -1) {
        todos[index] = updatedTodo;
        await _saveToCache(todos);
      }

      print('✅ 已更新 Todo: ${updatedTodo.task}');
      return updatedTodo;
    } catch (e) {
      print('❌ 更新 Todo 失敗: $e');
      rethrow;
    }
  }

  // 刪除 Todo
  Future<void> deleteTodo(int id) async {
    try {
      // 1. 先透過 API 刪除
      await _todoService.deleteTodo(id);

      // 2. 成功後更新快取
      final todos = await _loadFromCache();
      todos.removeWhere((t) => t.id == id);
      await _saveToCache(todos);

      print('✅ 已刪除 Todo (ID: $id)');
    } catch (e) {
      print('❌ 刪除 Todo 失敗: $e');
      rethrow;
    }
  }

  // 清空所有 Todo
  Future<void> clearTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    print('✅ 已清空所有 Todo');
  }


}