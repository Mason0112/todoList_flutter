class Todo {
  final int? id;
  final String task;
  final bool completed;

  Todo({
    this.id,
    required this.task,
    required this.completed,
  });

  // 用於更新部分屬性
  Todo copyWith({
    int? id,
    String? task,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      task: task ?? this.task,
      completed: isCompleted ?? this.completed,
    );
  }

  // 轉成 Map（之後存儲用）
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'task': task,
    'completed': completed,
  };

  // 從 Map 建立（之後讀取用）
  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'],
    task: json['task'],
    completed: json['completed'],
  );
}