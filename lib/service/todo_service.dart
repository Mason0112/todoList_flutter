import 'package:todo_list/models/todo.dart';
import 'package:todo_list/service/auth_service.dart';
import 'api_service.dart';

class TodoService {
  final ApiService _apiService;
  final AuthService _authService;

  // Inject dependencies via constructor
  TodoService(this._apiService, this._authService);

  Future<List<Todo>> getTodos() async {
    final token = await _authService.getValidToken();
    return await _apiService.getTodos(token);
  }

  Future<Todo> createTodo(String task) async {
    final token = await _authService.getValidToken();
    return await _apiService.createTodo(token, task, false);
  }

  Future<Todo> updateTodo(Todo todo) async {
    final token = await _authService.getValidToken();
    return await _apiService.updateTodo(token, todo);
  }

  Future<void> deleteTodo(int id) async {
    final token = await _authService.getValidToken();
    return await _apiService.deleteTodo(token, id);
  }

}