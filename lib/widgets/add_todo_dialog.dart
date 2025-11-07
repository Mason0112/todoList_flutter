import 'package:flutter/material.dart';
import '../models/todo.dart';

class AddTodoDialog extends StatefulWidget {
  const AddTodoDialog({super.key});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新增待辦事項'),
      content: TextField( 
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: '請輸入待辦事項...',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _addTodo();
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: _addTodo,
          child: const Text('新增'),
        ),
      ],
    );
  }

  void _addTodo() {
    if (_controller.text.isNotEmpty) {
      Navigator.pop(
        context,
        Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _controller.text,
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}