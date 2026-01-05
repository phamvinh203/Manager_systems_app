class AttendanceModel {
  final int id;
  final int employeeId;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double? totalHours;
  final EmployeeInfo? employee;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.totalHours,
    this.employee,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as int,
      employeeId: json['employeeId'] as int,
      date: DateTime.parse(json['date'] as String),
      checkIn: json['checkIn'] != null 
          ? DateTime.parse(json['checkIn'] as String) 
          : null,
      checkOut: json['checkOut'] != null 
          ? DateTime.parse(json['checkOut'] as String) 
          : null,
      totalHours: json['totalHours'] != null 
          ? (json['totalHours'] as num).toDouble() 
          : null,
      employee: json['employee'] != null 
          ? EmployeeInfo.fromJson(json['employee'] as Map<String, dynamic>) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'totalHours': totalHours,
      'employee': employee?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get hasCheckedIn => checkIn != null;
  bool get hasCheckedOut => checkOut != null;
  bool get isComplete => hasCheckedIn && hasCheckedOut;

  String get checkInTimeFormatted {
    if (checkIn == null) return '--:--';
    return '${checkIn!.hour.toString().padLeft(2, '0')}:${checkIn!.minute.toString().padLeft(2, '0')}';
  }

  String get checkOutTimeFormatted {
    if (checkOut == null) return '--:--';
    return '${checkOut!.hour.toString().padLeft(2, '0')}:${checkOut!.minute.toString().padLeft(2, '0')}';
  }

  String get totalHoursFormatted {
    if (totalHours == null) return '--';
    return '${totalHours!.toStringAsFixed(2)} giờ';
  }
}

class EmployeeInfo {
  final int id;
  final String code;
  final String firstName;
  final String lastName;
  final String? department;

  EmployeeInfo({
    required this.id,
    required this.code,
    required this.firstName,
    required this.lastName,
    this.department,
  });

  factory EmployeeInfo.fromJson(Map<String, dynamic> json) {
    return EmployeeInfo(
      id: json['id'] as int,
      code: json['code'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      department: json['department'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'firstName': firstName,
      'lastName': lastName,
      'department': department,
    };
  }

  String get fullName => '$firstName $lastName';
}

class AttendanceSummary {
  final int totalDays;
  final double totalWorkedHours;

  AttendanceSummary({
    required this.totalDays,
    required this.totalWorkedHours,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalDays: json['totalDays'] as int,
      totalWorkedHours: (json['totalWorkedHours'] as num).toDouble(),
    );
  }
}
