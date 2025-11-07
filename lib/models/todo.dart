class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  // 用於更新部分屬性
  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 轉成 Map（之後存儲用）
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  // 從 Map 建立（之後讀取用）
  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'],
    title: json['title'],
    isCompleted: json['isCompleted'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}