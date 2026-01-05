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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse từ JSON (data[])
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      code: json['code'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      position: json['position'],
      department: json['department'],
      salary: json['salary'],
      status: json['status'],
      hiredAt: DateTime.parse(json['hiredAt']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Convert ngược lại JSON (create/update)
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
      'status': status,
      'hiredAt': hiredAt.toIso8601String(),
    };
  }

  /// Helper cho UI (optional)
  String get fullName => '$firstName $lastName';
}
