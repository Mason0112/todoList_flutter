import 'package:flutter/material.dart';

import '../models/todo.dart';

class EditTodoDialog extends StatefulWidget {

  final Todo todo;
  const EditTodoDialog({super.key, required this.todo});


  @override
  State<EditTodoDialog> createState() => _EditTodoDialogState();
}
class _EditTodoDialogState extends State<EditTodoDialog> {
  late TextEditingController _controller;

  void _saveTodo() {
    if (_controller.text.isNotEmpty) {
      Navigator.pop(
        context,
        widget.todo.copyWith(task: _controller.text),  // 只改 title
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // 預填原本的內容
    _controller = TextEditingController(text: widget.todo.task);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('編輯待辦事項'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: '請輸入待辦事項...',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _saveTodo();
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: _saveTodo,
          child: const Text('儲存'),
        ),
      ],
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}


