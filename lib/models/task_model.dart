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
  final DepartmentModel? department;
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
    this.department,
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
      department: json['department'] != null
          ? DepartmentModel.fromJson(json['department'])
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
    DepartmentModel? department,
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
      department: department ?? this.department,
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
    return DepartmentModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
