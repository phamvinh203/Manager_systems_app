import 'package:mobile/utils/enum/leave_status.dart';
import 'package:mobile/utils/enum/leave_type.dart';

class LeaveRequestModel {
  final int id;
  final int employeeId;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final double totalDays;
  final String? reason;
  final LeaveStatus status;
  final int? approverId;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectNote;
  final DateTime createdAt;
  final DateTime updatedAt;
  final EmployeeBriefModel? employee;
  final ApproverBriefModel? approver;

  LeaveRequestModel({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    this.reason,
    required this.status,
    this.approverId,
    this.approvedAt,
    this.rejectedAt,
    this.rejectNote,
    required this.createdAt,
    required this.updatedAt,
    this.employee,
    this.approver,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'],
      employeeId: json['employeeId'],
      leaveType: LeaveTypeX.fromApi(json['leaveType']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalDays: (json['totalDays'] as num).toDouble(),
      reason: json['reason'],
      status: LeaveStatusX.fromApi(json['status']),
      approverId: json['approverId'],
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'])
          : null,
      rejectNote: json['rejectNote'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      employee: json['employee'] != null
          ? EmployeeBriefModel.fromJson(json['employee'])
          : null,
      approver: json['approver'] != null
          ? ApproverBriefModel.fromJson(json['approver'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'leaveType': leaveType.toApi,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'reason': reason,
      'status': status.toApi,
      'approverId': approverId,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedAt': rejectedAt?.toIso8601String(),
      'rejectNote': rejectNote,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'employee': employee == null
          ? null
          : {
              'id': employee!.id,
              'code': employee!.code,
              'firstName': employee!.firstName,
              'lastName': employee!.lastName,
              'department': employee!.department == null
                  ? null
                  : {
                      'id': employee!.department!.id,
                      'name': employee!.department!.name,
                    },
            },
      'approver': approver == null
          ? null
          : {
              'id': approver!.id,
              'firstName': approver!.firstName,
              'lastName': approver!.lastName,
            },
    };
  }

  /// copyWith
  /// Tạo một bản sao của LeaveRequestModel với các trường được cập nhật
  /// nếu không truyền giá trị mới, giữ nguyên giá trị cũ
  LeaveRequestModel copyWith({
    int? id,
    int? employeeId,
    LeaveType? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    double? totalDays,
    String? reason,
    LeaveStatus? status,
    int? approverId,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    String? rejectNote,
    DateTime? createdAt,
    DateTime? updatedAt,
    EmployeeBriefModel? employee,
    ApproverBriefModel? approver,
  }) {
    return LeaveRequestModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approverId: approverId ?? this.approverId,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectNote: rejectNote ?? this.rejectNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      employee: employee ?? this.employee,
      approver: approver ?? this.approver,
    );
  }

  // helpers
  bool get isPending => status == LeaveStatus.pending;
  bool get isApproved => status == LeaveStatus.approved;
  bool get isRejected => status == LeaveStatus.rejected;
  bool get isCancelled => status == LeaveStatus.cancelled;
}

class EmployeeBriefModel {
  final int id;
  final String code;
  final String firstName;
  final String lastName;
  final DepartmentBriefModel? department;
  final PositionBriefModel? position;

  EmployeeBriefModel({
    required this.id,
    required this.code,
    required this.firstName,
    required this.lastName,
    this.department,
    this.position,
  });

  factory EmployeeBriefModel.fromJson(Map<String, dynamic> json) {
    return EmployeeBriefModel(
      id: json['id'],
      code: json['code'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      department: json['department'] != null
          ? DepartmentBriefModel.fromJson(json['department'])
          : null,
      position: json['position'] != null
          ? PositionBriefModel.fromJson(json['position'])
          : null,
    );
  }

  String get fullName => '$firstName $lastName';
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}'
      '${lastName.isNotEmpty ? lastName[0] : ''}';
}

class DepartmentBriefModel {
  final int? id;
  final String name;

  DepartmentBriefModel({this.id, required this.name});

  factory DepartmentBriefModel.fromJson(Map<String, dynamic> json) {
    return DepartmentBriefModel(id: json['id'], name: json['name']);
  }
}

class ApproverBriefModel {
  final int id;
  final String firstName;
  final String lastName;

  ApproverBriefModel({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory ApproverBriefModel.fromJson(Map<String, dynamic> json) {
    return ApproverBriefModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  String get fullName => '$firstName $lastName';
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}'
      '${lastName.isNotEmpty ? lastName[0] : ''}';
}

class PositionBriefModel {
  final int? id;
  final String name;

  PositionBriefModel({this.id, required this.name});

  factory PositionBriefModel.fromJson(Map<String, dynamic> json) {
    return PositionBriefModel(id: json['id'], name: json['name']);
  }
}
