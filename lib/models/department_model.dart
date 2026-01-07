class Department {
  final int id;
  final String name;
  final int? managerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic manager;
  final DepartmentCount? count;

  const Department({
    required this.id,
    required this.name,
    this.managerId,
    this.createdAt,
    this.updatedAt,
    this.manager,
    this.count,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'managerId': managerId,
    };
  }
}

class DepartmentCount {
  final int employees;
  final int positions;

  const DepartmentCount({
    required this.employees,
    required this.positions,
  });

  factory DepartmentCount.fromJson(Map<String, dynamic> json) {
    return DepartmentCount(
      employees: json['employees'] ?? 0,
      positions: json['positions'] ?? 0,
    );
  }
}