class Department {
  final int id;
  final String name;
  final int? managerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic manager;
  final DepartmentCount? count;
  final List<DepartmentEmployee>? employees;

  const Department({
    required this.id,
    required this.name,
    this.managerId,
    this.createdAt,
    this.updatedAt,
    this.manager,
    this.count,
    this.employees,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      managerId: json['managerId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      manager: json['manager'],
      count: json['_count'] != null
          ? DepartmentCount.fromJson(json['_count'])
          : null,
      employees: json['employees'] != null
          ? (json['employees'] as List)
              .map((e) => DepartmentEmployee.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'managerId': managerId};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Department && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DepartmentCount {
  final int employees;
  final int positions;

  const DepartmentCount({required this.employees, required this.positions});

  factory DepartmentCount.fromJson(Map<String, dynamic> json) {
    return DepartmentCount(
      employees: json['employees'] ?? 0,
      positions: json['positions'] ?? 0,
    );
  }
}

class DepartmentEmployee {
  final int id;
  final String code;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final EmployeePosition position;
  final String status;

  const DepartmentEmployee({
    required this.id,
    required this.code,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.position,
    required this.status,
  });

  factory DepartmentEmployee.fromJson(Map<String, dynamic> json) {
    return DepartmentEmployee(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      position: json['position'] != null
          ? EmployeePosition.fromJson(json['position'])
          : EmployeePosition.empty(),
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'position': position.toJson(),
      'status': status,
    };
  }
}

class EmployeePosition {
  final int id;
  final String name;

  const EmployeePosition({
    required this.id,
    required this.name,
  });

  factory EmployeePosition.fromJson(Map<String, dynamic> json) {
    return EmployeePosition(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  factory EmployeePosition.empty() {
    return const EmployeePosition(
      id: 0,
      name: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
