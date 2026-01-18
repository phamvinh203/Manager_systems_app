import 'package:mobile/utils/task/task_status.dart';
import 'package:mobile/utils/task/task_type.dart';
import 'package:mobile/utils/task/task_priority.dart';

class TaskModel {
  final int id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final TaskType type;

  final DateTime? startDate;
  final DateTime? dueDate;
  final int? employeeId;
  final int? assignedCount;
  final DepartmentModel? department;
  final List<TaskAssigneeModel>? assignees;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.type,
    this.startDate,
    this.dueDate,
    this.employeeId,
    this.assignedCount,
    this.department,
    this.assignees,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: TaskStatusX.fromApi(json['status']),
      priority: TaskPriorityX.fromApi(json['priority']),
      type: TaskTypeX.fromApi(json['type']),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      employeeId: json['employeeId'],
      assignedCount:
          json['assignedCount'] ??
          json['assignedEmployeesCount'] ??
          json['_count']?['employees'] ??
          json['_count']?['taskAssignees'],
      department: json['department'] != null
          ? DepartmentModel.fromJson(json['department'])
          : null,
      assignees:
          (json['assignees'] ??
                  json['taskAssignees'] ??
                  json['employees'] ??
                  json['assignedEmployees'])
              is List
          ? (json['assignees'] ??
                    json['taskAssignees'] ??
                    json['employees'] ??
                    json['assignedEmployees'] as List)
                .map((e) => TaskAssigneeModel.fromJson(e))
                .toList()
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /* TO JSON */
  /// Dùng cho CREATE / UPDATE
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'priority': priority.toApi,
      'type': type.toApi,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    };
  }

  /* COPY WITH */
  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    TaskType? type,
    DateTime? startDate,
    DateTime? dueDate,
    int? employeeId,
    int? assignedCount,
    DepartmentModel? department,
    List<TaskAssigneeModel>? assignees,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      employeeId: employeeId ?? this.employeeId,
      assignedCount: assignedCount ?? this.assignedCount,
      department: department ?? this.department,
      assignees: assignees ?? this.assignees,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helpers
  bool get isTodo => status == TaskStatus.todo;
  bool get isInProgress => status == TaskStatus.inProgress;
  bool get isReview => status == TaskStatus.review;
  bool get isDone => status == TaskStatus.done;
  bool get isCancelled => status == TaskStatus.cancelled;
}

class DepartmentModel {
  final int id;
  final String name;

  DepartmentModel({required this.id, required this.name});

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

// Model cho thông tin nhân viên được gán task
class TaskAssigneeModel {
  final int employeeId;
  final String code;
  final String fullName;
  final PositionBriefModel? position;
  final String status;
  final int progress;
  final DateTime assignedAt;
  final DateTime? completedAt;

  TaskAssigneeModel({
    required this.employeeId,
    required this.code,
    required this.fullName,
    this.position,
    required this.status,
    required this.progress,
    required this.assignedAt,
    this.completedAt,
  });

  factory TaskAssigneeModel.fromJson(Map<String, dynamic> json) {
    return TaskAssigneeModel(
      employeeId: json['employeeId'],
      code: json['code'],
      fullName: json['fullName'],
      position: json['position'] != null
          ? PositionBriefModel.fromJson(json['position'])
          : null,
      status: json['status'],
      progress: json['progress'] ?? 0,
      assignedAt: DateTime.parse(json['assignedAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'code': code,
      'fullName': fullName,
      'position': position?.toJson(),
      'status': status,
      'progress': progress,
      'assignedAt': assignedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

class PositionBriefModel {
  final int id;
  final String name;

  PositionBriefModel({required this.id, required this.name});

  factory PositionBriefModel.fromJson(Map<String, dynamic> json) {
    return PositionBriefModel(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
