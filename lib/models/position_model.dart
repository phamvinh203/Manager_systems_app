class Position {
  final int id;
  final String name;
  final int departmentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PositionDepartment? department;
  final PositionCount? count;

  const Position({
    required this.id,
    required this.name,
    required this.departmentId,
    this.createdAt,
    this.updatedAt,
    this.department,
    this.count,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      departmentId: json['departmentId'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      department: json['department'] != null 
          ? PositionDepartment.fromJson(json['department']) 
          : null,
      count: json['_count'] != null 
          ? PositionCount.fromJson(json['_count']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'departmentId': departmentId,
    };
  }
}

class PositionDepartment {
  final int id;
  final String name;

  const PositionDepartment({
    required this.id,
    required this.name,
  });

  factory PositionDepartment.fromJson(Map<String, dynamic> json) {
    return PositionDepartment(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class PositionCount {
  final int employees;

  const PositionCount({
    required this.employees,
  });

  factory PositionCount.fromJson(Map<String, dynamic> json) {
    return PositionCount(
      employees: json['employees'] ?? 0,
    );
  }
}