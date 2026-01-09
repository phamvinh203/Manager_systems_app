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

  EmployeeBriefModel({
    required this.id,
    required this.code,
    required this.firstName,
    required this.lastName,
  });

  factory EmployeeBriefModel.fromJson(Map<String, dynamic> json) {
    return EmployeeBriefModel(
      id: json['id'],
      code: json['code'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  String get fullName => '$firstName $lastName';
}
