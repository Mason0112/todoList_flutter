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

  Future<void> _showAddTodoDialog() async {
    final result = await showDialog<Todo>(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );

    if (result != null) {
      try {
        // 1. 先透過 API 新增
        final newTodo = await _repository.createTodo(result.task);

        // 2. 成功後更新 UI
        setState(() {
          _todos.add(newTodo);
        });
      } catch (e) {
        // 3. 失敗時顯示錯誤訊息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('新增失敗: $e')),
          );
        }
      }
    }
  }

  void _toggleTodo(int index, bool isCompleted) async {
    try {
      // 1. 先更新本地狀態 (立即反饋給使用者)
      final updatedTodo = _todos[index].copyWith(isCompleted: isCompleted);
      setState(() {
        _todos[index] = updatedTodo;
      });

      // 2. 同步到 API
      await _repository.updateTodo(updatedTodo);
    } catch (e) {
      // 3. 失敗時還原並顯示錯誤
      setState(() {
        _todos[index] = _todos[index].copyWith(isCompleted: !isCompleted);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失敗: $e')),
        );
      }
    }
  }

  void _deleteTodo(int index) async {
    final todo = _todos[index];

    setState(() {
      _todos.removeAt(index);
    });

    if (todo.id == null) return;

    try {
      await _repository.deleteTodo(todo.id!);
    } catch (e) {
      // 失敗時還原並顯示錯誤
      setState(() {
        _todos.insert(index, todo);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('刪除失敗: $e')),
        );
      }
    }
  }

  Future<void> _editTodo(int index) async {
    final result = await showDialog<Todo>(
      context: context,
      builder: (context) => EditTodoDialog(todo: _todos[index]),
    );

    if (result != null) {
      try {
        // 1. 先更新 API
        final updatedTodo = await _repository.updateTodo(result);

        // 2. 成功後更新 UI
        setState(() {
          _todos[index] = updatedTodo;
        });
      } catch (e) {
        // 3. 失敗時顯示錯誤
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('更新失敗: $e')),
          );
        }
      }
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