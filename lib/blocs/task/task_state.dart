import 'package:equatable/equatable.dart';
import 'package:mobile/models/pagination_model.dart';
import 'package:mobile/models/task_model.dart';

enum BlocTaskStatus { initial, loading, loaded, success, error }

class TaskState extends Equatable {
  final BlocTaskStatus status;

  final List<TaskModel>? tasks;
  final Pagination? pagination;
  final TaskModel? currentTask;
  final List<TaskAssigneeModel>? assignees;

  final String? successMessage;
  final String? errorMessage;

  const TaskState({
    this.status = BlocTaskStatus.initial,
    this.tasks = const [],
    this.pagination,
    this.currentTask,
    this.assignees,
    this.successMessage,
    this.errorMessage,
  });

  factory TaskState.initial() {
    return const TaskState();
  }

  TaskState copyWith({
    BlocTaskStatus? status,
    List<TaskModel>? tasks,
    Pagination? pagination,
    TaskModel? currentTask,
    List<TaskAssigneeModel>? assignees,
    String? successMessage,
    String? errorMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearPagination = false,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      pagination: clearPagination ? null : (pagination ?? this.pagination),
      currentTask: currentTask ?? this.currentTask,
      assignees: assignees ?? this.assignees,
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  // Helper getters
  bool get isInitial => status == BlocTaskStatus.initial;
  bool get isLoading => status == BlocTaskStatus.loading;
  bool get isSuccess => status == BlocTaskStatus.success;
  bool get isError => status == BlocTaskStatus.error;

  @override
  List<Object?> get props => [
        status,
        tasks,
        pagination,
        currentTask,
        assignees,
        successMessage,
        errorMessage,
      ];
}
