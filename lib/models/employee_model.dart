class Employee {
  final int id;
  final String code;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String position;
  final String department;
  final int salary;
  final String status;
  final DateTime hiredAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Employee({
    required this.id,
    required this.code,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.position,
    required this.department,
    required this.salary,
    required this.status,
    required this.hiredAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Parse từ JSON (data[])
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      position: json['position'] ?? '',
      department: json['department'] ?? '',
      salary: json['salary'] ?? 0,
      status: json['status'] ?? '',
      hiredAt: json['hiredAt'] != null
          ? DateTime.parse(json['hiredAt'])
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Convert ngược lại JSON (create/update)
  /// Khi tạo mới: không gửi id, createdAt, updatedAt
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'position': position,
      'department': department,
      'salary': salary,
      'status': status.toUpperCase(), // Server expects uppercase
      'hiredAt': _formatDate(hiredAt),
    };
  }

  /// Format date as yyyy-MM-dd for API
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Helper cho UI (optional)
  String get fullName => '$firstName $lastName';
}
