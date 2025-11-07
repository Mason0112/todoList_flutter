import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../repository/todo_repository.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/todo_item.dart';
import '../widgets/edit_todo_dialog.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> _todos = [];
  final TodoRepository _repository = TodoRepository();  // ← 加這行
  bool _isLoading = true;  // ← 加這行

  @override
  void initState() {
    super.initState();
    _loadTodos();  // ← App 啟動時讀取資料
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
    });

    List<Todo> todos = await _repository.loadTodos();

    setState(() {
      _todos = todos;
      _isLoading = false;
    });
  }

  Future<void> _saveTodos() async {
    await _repository.saveTodos(_todos);
  }

  Future<void> _showAddTodoDialog() async {
    final result = await showDialog<Todo>(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );

    if (result != null) {
      setState(() {
        _todos.add(result);
      });
      await _saveTodos();  // ← 加這行，新增後自動儲存
    }
  }

  void _toggleTodo(int index, bool isCompleted) {
    setState(() {
      _todos[index] = _todos[index].copyWith(isCompleted: isCompleted);
    });
    _saveTodos();
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodos();
  }

  Future<void> _editTodo(int index) async {
    final result = await showDialog<Todo>(
      context: context,
      builder: (context) => EditTodoDialog(todo: _todos[index]),
    );

    if (result != null) {
      setState(() {
        _todos[index] = result;
      });
      await _saveTodos();  // 儲存
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('我的待辦事項'),
      ),
      body: _isLoading  // ← 載入時顯示轉圈圈
          ? const Center(child: CircularProgressIndicator())
          : _todos.isEmpty
          ? const Center(
        child: Text(
          '還沒有待辦事項\n點擊右下角 + 新增',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          return TodoItem(
            todo: _todos[index],
            onChanged: (isCompleted) =>
                _toggleTodo(index, isCompleted),
            onDelete: () => _deleteTodo(index),
            onTap: () => _editTodo(index) ,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}