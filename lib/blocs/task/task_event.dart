import 'package:equatable/equatable.dart';
import 'package:mobile/utils/task/task_priority.dart';
import 'package:mobile/utils/task/task_type.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  final int page;
  final int limit;

  const LoadTasksEvent({
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [page, limit];
}

// Tạo task mới
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
  List<Object?> get props =>
      [title, departmentId, description, priority, type, startDate, dueDate];
}

// Lấy chi tiết task theo ID
class LoadTaskDetailEvent extends TaskEvent {
  final int taskId;

  const LoadTaskDetailEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

// Cập nhật task
class UpdateTaskEvent extends TaskEvent {
  final int taskId;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskType type;
  final DateTime? startDate;
  final DateTime? dueDate;

  const UpdateTaskEvent({
    required this.taskId,
    required this.title,
    this.description,
    required this.priority,
    required this.type,
    this.startDate,
    this.dueDate,
  });

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

// Xóa task
class DeleteTaskEvent extends TaskEvent {
  final int taskId;

  const DeleteTaskEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}
