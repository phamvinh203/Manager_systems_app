import 'package:equatable/equatable.dart';
import 'package:mobile/utils/task/task_priority.dart';
import 'package:mobile/utils/task/task_type.dart';

/// Base class cho tất cả TaskEvent
sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

// ============ LOAD EVENTS ============

/// Load danh sách tasks với pagination
class LoadTasksEvent extends TaskEvent {
  final int page;
  final int limit;
  final bool refresh; // true = clear cache và load lại

  const LoadTasksEvent({
    this.page = 1,
    this.limit = 10,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, limit, refresh];
}

/// Load chi tiết task theo ID
class LoadTaskDetailEvent extends TaskEvent {
  final int taskId;
  final bool forceRefresh; // true = bỏ qua cache

  const LoadTaskDetailEvent({
    required this.taskId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [taskId, forceRefresh];
}

/// Load danh sách assignees của task
class LoadTaskAssigneesEvent extends TaskEvent {
  final int taskId;

  const LoadTaskAssigneesEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

// ============ CRUD EVENTS ============

/// Tạo task mới
class CreateTaskEvent extends TaskEvent {
  final String title;
  final int departmentId;
  final String? description;
  final TaskPriority priority;
  final TaskType type;
  final DateTime? startDate;
  final DateTime? dueDate;

  const CreateTaskEvent({
    required this.title,
    required this.departmentId,
    this.description,
    required this.priority,
    required this.type,
    this.startDate,
    this.dueDate,
  });

  @override
  List<Object?> get props => [
        title,
        departmentId,
        description,
        priority,
        type,
        startDate,
        dueDate,
      ];
}

/// Cập nhật task
class UpdateTaskEvent extends TaskEvent {
  final int taskId;
  final String? title;
  final String? description;
  final TaskPriority? priority;
  final TaskType? type;
  final DateTime? startDate;
  final DateTime? dueDate;

  const UpdateTaskEvent({
    required this.taskId,
    this.title,
    this.description,
    this.priority,
    this.type,
    this.startDate,
    this.dueDate,
  });

  /// Check xem có field nào được update không
  bool get hasChanges =>
      title != null ||
      description != null ||
      priority != null ||
      type != null ||
      startDate != null ||
      dueDate != null;

  @override
  List<Object?> get props => [
        taskId,
        title,
        description,
        priority,
        type,
        startDate,
        dueDate,
      ];
}

/// Xóa task
class DeleteTaskEvent extends TaskEvent {
  final int taskId;

  const DeleteTaskEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

// ============ ASSIGNMENT EVENTS ============

/// Gán task cho nhiều nhân viên (batch)
class AssignTaskEvent extends TaskEvent {
  final int taskId;
  final List<int> employeeIds;

  const AssignTaskEvent({
    required this.taskId,
    required this.employeeIds,
  });

  @override
  List<Object?> get props => [taskId, employeeIds];
}

/// Bỏ gán task cho nhân viên
class UnassignTaskEvent extends TaskEvent {
  final int taskId;
  final int employeeId;

  const UnassignTaskEvent({
    required this.taskId,
    required this.employeeId,
  });

  @override
  List<Object?> get props => [taskId, employeeId];
}

/// 🆕 BATCH: Cập nhật assignments (thêm + xóa cùng lúc)
/// Tối ưu cho màn hình AddEmployeeTask
class UpdateTaskAssignmentsEvent extends TaskEvent {
  final int taskId;
  final Set<int> toAssign; // IDs cần thêm
  final Set<int> toUnassign; // IDs cần xóa

  const UpdateTaskAssignmentsEvent({
    required this.taskId,
    required this.toAssign,
    required this.toUnassign,
  });

  bool get hasChanges => toAssign.isNotEmpty || toUnassign.isNotEmpty;

  @override
  List<Object?> get props => [taskId, toAssign, toUnassign];
}

// ============ UTILITY EVENTS ============

/// Clear messages (success/error)
class ClearTaskMessagesEvent extends TaskEvent {
  const ClearTaskMessagesEvent();
}

/// Reset state về initial
class ResetTaskStateEvent extends TaskEvent {
  const ResetTaskStateEvent();
}