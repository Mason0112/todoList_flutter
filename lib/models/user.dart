enum Role {
  USER,
  ADMIN;

  static Role fromString(String value) {
    return Role.values.firstWhere(
          (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Role.USER,
    );
  }
}

class User {
  final int id;
  final String userName;
  final Role role;

  User({
    required this.id,
    required this.userName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    userName: json['userName'],
    role: Role.fromString(json['role']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'role': role.name.toUpperCase(),
  };
}