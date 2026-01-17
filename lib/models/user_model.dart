class User {
  final int id;
  final String name;
  final String email;
  final String? role;

  User({required this.id, required this.name, required this.email, this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['fullName'] ?? '',
      email: json['email'],
      role: json['role'],
    );
  }

  bool get isAdmin => role == 'ADMIN';
  bool get isHR => role == 'HR';
  bool get isManager => role == 'MANAGER';
  bool get isEmployee => role == 'EMPLOYEE';
}
