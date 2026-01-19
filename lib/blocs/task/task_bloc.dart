import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:mobile/blocs/task/task_event.dart';
import 'package:mobile/blocs/task/task_state.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/repositories/task_repository.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;
  final Logger _logger = Logger();

  // 🆕 Simple cache để tránh load lại assignees không cần thiết
  final Map<int, DateTime> _assigneesLastFetched = {};
  static const _cacheValidDuration = Duration(minutes: 5);

  TaskBloc(this.taskRepository) : super(const TaskState()) {
    // Load events
    on<LoadTasksEvent>(_onLoadTasks);
    on<LoadTaskDetailEvent>(_onLoadTaskDetail);
    on<LoadTaskAssigneesEvent>(_onLoadTaskAssignees);

    // CRUD events
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);

    // Assignment events
    on<AssignTaskEvent>(_onAssignTask);
    on<UnassignTaskEvent>(_onUnassignTask);
    on<UpdateTaskAssignmentsEvent>(_onUpdateTaskAssignments);

    // Utility events
    on<ClearTaskMessagesEvent>(_onClearMessages);
    on<ResetTaskStateEvent>(_onResetState);
  }

  // ============ LOAD HANDLERS ============

  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    // Nếu refresh, emit loading. Nếu load more, giữ data cũ
    if (event.refresh || state.tasks?.isEmpty == true) {
      emit(state.copyWith(status: BlocTaskStatus.loading, clearError: true));
    }

    try {
      final response = await taskRepository.getTasks(
        page: event.page,
        limit: event.limit,
      );

      // 🔧 TỐI ƯU: Load assignees song song với giới hạn concurrent
      final tasksWithAssignees = await _loadAssigneesForTasks(response.tasks);

      // Nếu load more (page > 1), append vào list cũ
      final updatedTasks = event.page > 1 && !event.refresh
          ? [...?state.tasks, ...tasksWithAssignees]
          : tasksWithAssignees;

      emit(state.copyWith(
        status: BlocTaskStatus.loaded,
        tasks: updatedTasks,
        pagination: response.pagination,
      ));

      _logger.i('Loaded ${response.tasks.length} tasks (page ${event.page})');
    } catch (e) {
      _logger.e('Load tasks error: $e');
      emit(state.copyWith(
        status: BlocTaskStatus.error,
        errorMessage: 'Không thể tải danh sách công việc',
      ));
    }
  }

  Future<void> _onLoadTaskDetail(
    LoadTaskDetailEvent event,
    Emitter<TaskState> emit,
  ) async {
    // 🔧 TỐI ƯU: Check cache trước khi call API
    if (!event.forceRefresh) {
      final cachedTask = state.tasks?.firstWhere(
        (t) => t.id == event.taskId,
        orElse: () => throw StateError('Not found'),
      );
      if (cachedTask != null && cachedTask.assignees?.isNotEmpty == true) {
        emit(state.copyWith(
          status: BlocTaskStatus.loaded,
          currentTask: cachedTask,
        ));
        return;
      }
    }

    emit(state.copyWith(status: BlocTaskStatus.loading, clearError: true));

    try {
      final task = await taskRepository.getTaskById(event.taskId);

      // Load assignees nếu chưa có
      final assignees = await taskRepository.getTaskAssignees(event.taskId);
      final taskWithAssignees = task.copyWith(assignees: assignees);

      // Update cả trong list tasks nếu có
      final updatedTasks = _updateTaskInList(taskWithAssignees);

      emit(state.copyWith(
        status: BlocTaskStatus.loaded,
        currentTask: taskWithAssignees,
        tasks: updatedTasks,
        assignees: assignees,
      ));

      _logger.i('Loaded task detail id=${task.id}');
    } catch (e) {
      _logger.e('Load task detail error: $e');
      emit(state.copyWith(
        status: BlocTaskStatus.error,
        errorMessage: 'Không thể tải chi tiết công việc',
      ));
    }
  }

  Future<void> _onLoadTaskAssignees(
    LoadTaskAssigneesEvent event,
    Emitter<TaskState> emit,
  ) async {
    // 🔧 TỐI ƯU: Check cache validity
    if (_isCacheValid(event.taskId) && state.assignees?.isNotEmpty == true) {
      _logger.i('Using cached assignees for task ${event.taskId}');
      return;
    }

    emit(state.copyWith(status: BlocTaskStatus.loading, clearError: true));

    try {
      final assignees = await taskRepository.getTaskAssignees(event.taskId);
      _assigneesLastFetched[event.taskId] = DateTime.now();

      emit(state.copyWith(
        status: BlocTaskStatus.loaded,
        assignees: assignees,
      ));

      _logger.i('Loaded ${assignees.length} assignees for task ${event.taskId}');
    } catch (e) {
      _logger.e('Load task assignees error: $e');
      emit(state.copyWith(
        status: BlocTaskStatus.error,
        errorMessage: 'Không thể tải danh sách nhân viên được gán',
      ));
    }
  }

  // ============ CRUD HANDLERS ============

  Future<void> _onCreateTask(
    CreateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: BlocTaskStatus.loading, clearError: true));

    try {
      final task = await taskRepository.createTask(
        title: event.title,
        departmentId: event.departmentId,
        description: event.description,
        priority: event.priority,
        type: event.type,
        startDate: event.startDate,
        dueDate: event.dueDate,
      );

      // Thêm task mới vào đầu list
      final updatedTasks = [task, ...?state.tasks];

      emit(state.copyWith(
        status: BlocTaskStatus.success,
        currentTask: task,
        tasks: updatedTasks,
        successMessage: 'Tạo công việc thành công',
      ));

      _logger.i('Created task id=${task.id}');
    } catch (e) {
      _logger.e('Create task error: $e');
      emit(state.copyWith(
        status: BlocTaskStatus.error,
        errorMessage: 'Tạo công việc thất bại',
      ));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (!event.hasChanges) {
      _logger.w('UpdateTaskEvent called without any changes');
      return;
    }

    emit(state.copyWith(status: BlocTaskStatus.loading, clearError: true));

    try {
      final updatedTask = await taskRepository.updateTask(
        event.taskId,
        title: event.title,
        description: event.description,
        priority: event.priority,
        type: event.type,
        startDate: event.startDate,
        dueDate: event.dueDate,
      );

      final updatedTasks = _updateTaskInList(updatedTask);

      emit(state.copyWith(
        status: BlocTaskStatus.success,
        tasks: updatedTasks,
        currentTask: updatedTask,
        successMessage: 'Cập nhật công việc thành công',
      ));

      _logger.i('Updated task id=${updatedTask.id}');
    } catch (e) {
      _logger.e('Update task error: $e');
      emit(state.copyWith(
        status: BlocTaskStatus.error,
        errorMessage: 'Cập nhật công việc thất bại',
      ));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: BlocTaskStatus.loading, clearError: true));

    try {
      await taskRepository.deleteTask(event.taskId);

      final updatedTasks =
          state.tasks?.where((t) => t.id != event.taskId).toList();

      // Clear cache
      _assigneesLastFetched.remove(event.taskId);

      emit(state.copyWith(
        status: BlocTaskStatus.success,
        tasks: updatedTasks,
        successMessage: 'Xóa công việc thành công',
        clearCurrentTask: state.currentTask?.id == event.taskId,
      ));

      _logger.i('Deleted task id=${event.taskId}');
    } catch (e) {
      _logger.e('Delete task error: $e');
      emit(state.copyWith(
        status: BlocTaskStatus.error,
        errorMessage: 'Xóa công việc thất bại',
      ));
    }
  }

  // ============ ASSIGNMENT HANDLERS ============

  Future<void> _onAssignTask(
    AssignTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (event.employeeIds.isEmpty) return;

    emit(state.copyWith(
      assignStatus: TaskOperationStatus.processing,
      processingEmployeeIds: event.employeeIds.toSet(),
      clearError: true,
    ));

    try {
      final result = await taskRepository.assignTask(
        taskId: event.taskId,
        employeeIds: event.employeeIds,
      );

      // Refresh assignees
      final assignees = await taskRepository.getTaskAssignees(event.taskId);
      _assigneesLastFetched[event.taskId] = DateTime.now();

      // Update task trong list
      final updatedTasks = state.tasks?.map((t) {
        if (t.id == event.taskId) {
          return t.copyWith(
            assignedCount: assignees.length,
            assignees: assignees,
          );
        }
        return t;
      }).toList();

      emit(state.copyWith(
        assignStatus: TaskOperationStatus.completed,
        processingEmployeeIds: const {},
        tasks: updatedTasks,
        assignees: assignees,
        successMessage:
            'Đã gán công việc cho ${result['assignedCount'] ?? assignees.length} nhân viên',
      ));

      _logger.i('Assigned task ${event.taskId} to ${event.employeeIds.length} employees');
    } catch (e) {
      _logger.e('Assign task error: $e');
      emit(state.copyWith(
        assignStatus: TaskOperationStatus.failed,
        processingEmployeeIds: const {},
        errorMessage: 'Gán công việc thất bại',
      ));
    }
  }

  Future<void> _onUnassignTask(
    UnassignTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(
      assignStatus: TaskOperationStatus.processing,
      processingEmployeeIds: {event.employeeId},
      clearError: true,
    ));

    try {
      await taskRepository.unassignTask(
        taskId: event.taskId,
        employeeId: event.employeeId,
      );

      // Optimistic update - remove từ local state
      final updatedAssignees =
          state.assignees?.where((a) => a.employeeId != event.employeeId).toList();

      // Update task trong list
      final updatedTasks = state.tasks?.map((t) {
        if (t.id == event.taskId) {
          return t.copyWith(
            assignedCount: (t.assignedCount ?? 1) - 1,
            assignees: t.assignees
                ?.where((a) => a.employeeId != event.employeeId)
                .toList(),
          );
        }
        return t;
      }).toList();

      emit(state.copyWith(
        assignStatus: TaskOperationStatus.completed,
        processingEmployeeIds: const {},
        assignees: updatedAssignees,
        tasks: updatedTasks,
        successMessage: 'Đã bỏ gán nhân viên khỏi công việc',
      ));

      _logger.i('Unassigned employee ${event.employeeId} from task ${event.taskId}');
    } catch (e) {
      _logger.e('Unassign task error: $e');
      emit(state.copyWith(
        assignStatus: TaskOperationStatus.failed,
        processingEmployeeIds: const {},
        errorMessage: 'Bỏ gán công việc thất bại',
      ));
    }
  }

  /// 🆕 BATCH UPDATE: Xử lý thêm + xóa assignments trong 1 event
  Future<void> _onUpdateTaskAssignments(
    UpdateTaskAssignmentsEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (!event.hasChanges) return;

    final allProcessingIds = {...event.toAssign, ...event.toUnassign};

    emit(state.copyWith(
      assignStatus: TaskOperationStatus.processing,
      processingEmployeeIds: allProcessingIds,
      clearError: true,
    ));

    try {
      // Chạy song song: assign batch + unassign từng cái
      final futures = <Future>[];

      if (event.toAssign.isNotEmpty) {
        futures.add(taskRepository.assignTask(
          taskId: event.taskId,
          employeeIds: event.toAssign.toList(),
        ));
      }

      for (final employeeId in event.toUnassign) {
        futures.add(taskRepository.unassignTask(
          taskId: event.taskId,
          employeeId: employeeId,
        ));
      }

      await Future.wait(futures);

      // Refresh assignees sau khi hoàn tất
      final assignees = await taskRepository.getTaskAssignees(event.taskId);
      _assigneesLastFetched[event.taskId] = DateTime.now();

      // Update tasks list
      final updatedTasks = state.tasks?.map((t) {
        if (t.id == event.taskId) {
          return t.copyWith(
            assignedCount: assignees.length,
            assignees: assignees,
          );
        }
        return t;
      }).toList();

      final message = _buildAssignmentMessage(
        event.toAssign.length,
        event.toUnassign.length,
      );

      emit(state.copyWith(
        assignStatus: TaskOperationStatus.completed,
        processingEmployeeIds: const {},
        tasks: updatedTasks,
        assignees: assignees,
        successMessage: message,
      ));

      _logger.i(
        'Updated assignments for task ${event.taskId}: '
        '+${event.toAssign.length}, -${event.toUnassign.length}',
      );
    } catch (e) {
      _logger.e('Update task assignments error: $e');
      emit(state.copyWith(
        assignStatus: TaskOperationStatus.failed,
        processingEmployeeIds: const {},
        errorMessage: 'Cập nhật phân công thất bại',
      ));
    }
  }

  // ============ UTILITY HANDLERS ============

  void _onClearMessages(
    ClearTaskMessagesEvent event,
    Emitter<TaskState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  void _onResetState(
    ResetTaskStateEvent event,
    Emitter<TaskState> emit,
  ) {
    _assigneesLastFetched.clear();
    emit(const TaskState());
  }

  // ============ PRIVATE HELPERS ============

  /// Load assignees cho list tasks với concurrency limit
  Future<List<TaskModel>> _loadAssigneesForTasks(List<TaskModel> tasks) async {
    const batchSize = 5; // Giới hạn concurrent requests
    final results = <TaskModel>[];

    for (var i = 0; i < tasks.length; i += batchSize) {
      final batch = tasks.skip(i).take(batchSize);
      final batchResults = await Future.wait(
        batch.map((task) async {
          try {
            // Check cache trước
            if (_isCacheValid(task.id) && task.assignees?.isNotEmpty == true) {
              return task;
            }
            final assignees = await taskRepository.getTaskAssignees(task.id);
            _assigneesLastFetched[task.id] = DateTime.now();
            return task.copyWith(assignees: assignees);
          } catch (_) {
            return task;
          }
        }),
      );
      results.addAll(batchResults);
    }

    return results;
  }

  /// Check xem cache có còn valid không
  bool _isCacheValid(int taskId) {
    final lastFetched = _assigneesLastFetched[taskId];
    if (lastFetched == null) return false;
    return DateTime.now().difference(lastFetched) < _cacheValidDuration;
  }

  /// Update task trong list
  List<TaskModel>? _updateTaskInList(TaskModel updatedTask) {
    return state.tasks?.map((t) {
      return t.id == updatedTask.id ? updatedTask : t;
    }).toList();
  }

  /// Build message cho batch assignment
  String _buildAssignmentMessage(int added, int removed) {
    final parts = <String>[];
    if (added > 0) parts.add('thêm $added');
    if (removed > 0) parts.add('bỏ $removed');
    return 'Đã ${parts.join(', ')} nhân viên';
  }
}