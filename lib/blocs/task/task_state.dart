import 'package:equatable/equatable.dart';
import 'package:mobile/models/pagination_model.dart';
import 'package:mobile/models/task_model.dart';

/// Enum cho trạng thái chính của Bloc
enum BlocTaskStatus { initial, loading, loaded, success, error }

/// Enum cho các operation phụ (assign/unassign) - cho phép loading độc lập
enum TaskOperationStatus { idle, processing, completed, failed }

class TaskState extends Equatable {
  // Main status
  final BlocTaskStatus status;

  // Data
  final List<TaskModel>? tasks;
  final Pagination? pagination;
  final TaskModel? currentTask;
  final List<TaskAssigneeModel>? assignees;

  // Operation status - cho phép UI hiển thị loading riêng cho assign/unassign
  final TaskOperationStatus assignStatus;
  final Set<int> processingEmployeeIds; // Track những employee đang được xử lý

  // Messages
  final String? successMessage;
  final String? errorMessage;

  const TaskState({
    this.status = BlocTaskStatus.initial,
    this.tasks = const [],
    this.pagination,
    this.currentTask,
    this.assignees,
    this.assignStatus = TaskOperationStatus.idle,
    this.processingEmployeeIds = const {},
    this.successMessage,
    this.errorMessage,
  });

  factory TaskState.initial() => const TaskState();

  TaskState copyWith({
    BlocTaskStatus? status,
    List<TaskModel>? tasks,
    Pagination? pagination,
    TaskModel? currentTask,
    List<TaskAssigneeModel>? assignees,
    TaskOperationStatus? assignStatus,
    Set<int>? processingEmployeeIds,
    String? successMessage,
    String? errorMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearPagination = false,
    bool clearCurrentTask = false,
    bool clearAssignees = false,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      pagination: clearPagination ? null : (pagination ?? this.pagination),
      currentTask:
          clearCurrentTask ? null : (currentTask ?? this.currentTask),
      assignees: clearAssignees ? null : (assignees ?? this.assignees),
      assignStatus: assignStatus ?? this.assignStatus,
      processingEmployeeIds:
          processingEmployeeIds ?? this.processingEmployeeIds,
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  // ============ HELPER GETTERS ============

  bool get isInitial => status == BlocTaskStatus.initial;
  bool get isLoading => status == BlocTaskStatus.loading;
  bool get isLoaded => status == BlocTaskStatus.loaded;
  bool get isSuccess => status == BlocTaskStatus.success;
  bool get isError => status == BlocTaskStatus.error;

  // Operation helpers
  bool get isAssigning => assignStatus == TaskOperationStatus.processing;
  bool isProcessingEmployee(int employeeId) =>
      processingEmployeeIds.contains(employeeId);

  // Data helpers
  bool get hasTasks => tasks != null && tasks!.isNotEmpty;
  bool get hasAssignees => assignees != null && assignees!.isNotEmpty;
  int get taskCount => tasks?.length ?? 0;
  int get assigneeCount => assignees?.length ?? 0;

  /// Lấy task theo ID từ cache
  TaskModel? getTaskById(int taskId) {
    return tasks?.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw StateError('Task not found'),
    );
  }

  @override
  List<Object?> get props => [
        status,
        tasks,
        pagination,
        currentTask,
        assignees,
        assignStatus,
        processingEmployeeIds,
        successMessage,
        errorMessage,
      ];
}