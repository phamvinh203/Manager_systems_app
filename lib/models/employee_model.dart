
import 'package:mobile/models/department_model.dart';
import 'package:mobile/models/position_model.dart';
import 'package:mobile/models/user_model.dart';

class Employee {
  final int id;
  final String code;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final double? salary;
  final String status;
  final DateTime hiredAt;

  // Foreign keys
  final int? departmentId;
  final int? positionId;
  final int? userId;

  // Nested objects (từ API response)
  final Department? department;
  final Position? position;
  final User? user;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Employee({
    required this.id,
    required this.code,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.salary,
    required this.status,
    required this.hiredAt,
    this.departmentId,
    this.positionId,
    this.userId,
    this.department,
    this.position,
    this.user,
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
      email: json['email'],
      phone: json['phone'],
      salary: json['salary'] != null
          ? (json['salary'] as num).toDouble()
          : null,
      status: json['status'] ?? 'ACTIVE',
      hiredAt: json['hiredAt'] != null
          ? DateTime.parse(json['hiredAt'])
          : DateTime.now(),
      departmentId: json['departmentId'],
      positionId: json['positionId'],
      userId: json['userId'],
      department: json['department'] != null
          ? Department.fromJson(json['department'])
          : null,
      position: json['position'] != null
          ? Position.fromJson(json['position'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
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
      'positionId': positionId,
      'departmentId': departmentId,
      'salary': salary,
      'status': status.toUpperCase(),
      'hiredAt': _formatDate(hiredAt),
    };
  }

  /// Format date as yyyy-MM-dd for API
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Helper cho UI
  String get fullName => '$firstName $lastName';

  /// Lấy tên department (từ nested object hoặc null)
  String get departmentName => department?.name ?? '';

  /// Lấy tên position (từ nested object hoặc null)
  String get positionName => position?.name ?? '';

  /// Copy with method để tạo bản sao với các thay đổi
  Employee copyWith({
    int? id,
    String? code,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    double? salary,
    String? status,
    DateTime? hiredAt,
    int? departmentId,
    int? positionId,
    int? userId,
    Department? department,
    Position? position,
    User? user,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      code: code ?? this.code,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      salary: salary ?? this.salary,
      status: status ?? this.status,
      hiredAt: hiredAt ?? this.hiredAt,
      departmentId: departmentId ?? this.departmentId,
      positionId: positionId ?? this.positionId,
      userId: userId ?? this.userId,
      department: department ?? this.department,
      position: position ?? this.position,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
