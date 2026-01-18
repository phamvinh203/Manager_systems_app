import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:mobile/blocs/task/task_event.dart';
import 'package:mobile/blocs/task/task_state.dart';
import 'package:mobile/repositories/task_repository.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;
  final Logger _logger = Logger();

  TaskBloc(this.taskRepository) : super(const TaskState()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<LoadTaskDetailEvent>(_onLoadTaskDetail);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<AssignTaskEvent>(_onAssignTask);
    on<LoadTaskAssigneesEvent>(_onLoadTaskAssignees);
    on<UnassignTaskEvent>(_onUnassignTask);
  }

  // LOAD TASKS
  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: BlocTaskStatus.loading, clearError: true));

    try {
      final response = await taskRepository.getTasks(
        page: event.page,
        limit: event.limit,
      );

      // Fetch assignees for each task to ensure they show up on cards
      final tasksWithAssignees = await Future.wait(
        response.tasks.map((t) async {
          try {
            final assignees = await taskRepository.getTaskAssignees(t.id);
            return t.copyWith(assignees: assignees);
          } catch (_) {
            return t;
          }
        }),
      );

      emit(
        state.copyWith(
          status: BlocTaskStatus.loaded,
          tasks: tasksWithAssignees,
          pagination: response.pagination,
        ),
      );

      _logger.i('Loaded ${response.tasks.length} tasks');
    } catch (e) {
      _logger.e('Load tasks error: $e');
      emit(
        state.copyWith(
          status: BlocTaskStatus.error,
          errorMessage: 'Không thể tải danh sách công việc',
        ),
      );
    }
  }

  // CREATE TASK
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

      emit(
        state.copyWith(
          status: BlocTaskStatus.success,
          currentTask: task,
          successMessage: 'Tạo công việc thành công',
        ),
      );

      _logger.i('Created task id=${task.id}');
    } catch (e) {
      _logger.e('Create task error: $e');
      emit(
        state.copyWith(
          status: BlocTaskStatus.error,
          errorMessage: 'Tạo công việc thất bại',
        ),
      );
    }
  }

  // LOAD TASK DETAIL
  Future<void> _onLoadTaskDetail(
    LoadTaskDetailEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: BlocTaskStatus.loading, clearError: true));

    try {
      final task = await taskRepository.getTaskById(event.taskId);

      emit(state.copyWith(status: BlocTaskStatus.loaded, currentTask: task));

      _logger.i('Loaded task detail id=${task.id}');
    } catch (e) {
      _logger.e('Load task detail error: $e');
      emit(
        state.copyWith(
          status: BlocTaskStatus.error,
          errorMessage: 'Không thể tải chi tiết công việc',
        ),
      );
    }
  }

  // UPDATE TASK
  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
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

      final updatedTasks = state.tasks
          ?.map((t) => t.id == updatedTask.id ? updatedTask : t)
          .toList();

      emit(
        state.copyWith(
          status: BlocTaskStatus.loaded,
          tasks: updatedTasks,
          currentTask: updatedTask,
          successMessage: 'Cập nhật công việc thành công',
        ),
      );

      _logger.i('Updated task id=${updatedTask.id}');
    } catch (e) {
      _logger.e('Update task error: $e');
      emit(
        state.copyWith(
          status: BlocTaskStatus.error,
          errorMessage: 'Cập nhật công việc thất bại',
        ),
      );
    }
  }

  // DELETE TASK
  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: BlocTaskStatus.loading, clearError: true));

    try {
      await taskRepository.deleteTask(event.taskId);

      final updatedTasks = state.tasks
          ?.where((t) => t.id != event.taskId)
          .toList();

      emit(
        state.copyWith(
          status: BlocTaskStatus.success,
          tasks: updatedTasks,
          successMessage: 'Xóa công việc thành công',
        ),
      );

      _logger.i('Deleted task id=${event.taskId}');
    } catch (e) {
      _logger.e('Delete task error: $e');
      emit(
        state.copyWith(
          status: BlocTaskStatus.error,
          errorMessage: 'Xóa công việc thất bại',
        ),
      );
    }
  }

  // ASSIGN TASK
  Future<void> _onAssignTask(
    AssignTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: BlocTaskStatus.loading, clearError: true));

    try {
      final result = await taskRepository.assignTask(
        taskId: event.taskId,
        employeeIds: event.employeeIds,
      );

      // Fetch full assignees detail to update names on cards
      final assignees = await taskRepository.getTaskAssignees(event.taskId);

      final updatedTasks = state.tasks?.map((t) {
        if (t.id == event.taskId) {
          return t.copyWith(
            assignedCount: result['assignedCount'] ?? assignees.length,
            assignees: assignees,
          );
        }
        return t;
      }).toList();

      emit(
        state.copyWith(
          status: BlocTaskStatus.success,
          tasks: updatedTasks,
          successMessage:
              'Đã gán công việc cho ${result['assignedCount'] ?? assignees.length} nhân viên',
        ),
      );

      _logger.i(
        'Assigned task id=${event.taskId} to ${event.employeeIds.length} employees',
      );
    } catch (e) {
      _logger.e('Assign task error: $e');
      emit(
        state.copyWith(
          status: BlocTaskStatus.error,
          errorMessage: 'Gán công việc thất bại',
        ),
      );
    }
  }

  // LOAD TASK ASSIGNEES
  Future<void> _onLoadTaskAssignees(
    LoadTaskAssigneesEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: BlocTaskStatus.loading, clearError: true));

    try {
      final assignees = await taskRepository.getTaskAssignees(event.taskId);

      emit(state.copyWith(status: BlocTaskStatus.loaded, assignees: assignees));

      _logger.i(
        'Loaded ${assignees.length} assignees for task id=${event.taskId}',
      );
    } catch (e) {
      _logger.e('Load task assignees error: $e');
      emit(
        state.copyWith(
          status: BlocTaskStatus.error,
          errorMessage: 'Không thể tải danh sách nhân viên được gán',
        ),
      );
    }
  }

  // UNASSIGN TASK
  Future<void> _onUnassignTask(
    UnassignTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: BlocTaskStatus.loading, clearError: true));

    try {
      await taskRepository.unassignTask(
        taskId: event.taskId,
        employeeId: event.employeeId,
      );

      final updatedAssignees = state.assignees
          ?.where((a) => a.employeeId != event.employeeId)
          .toList();

      emit(
        state.copyWith(
          status: BlocTaskStatus.success,
          assignees: updatedAssignees,
          successMessage: 'Đã bỏ gán nhân viên khỏi công việc',
        ),
      );

      _logger.i(
        'Unassigned employee id=${event.employeeId} from task id=${event.taskId}',
      );
    } catch (e) {
      _logger.e('Unassign task error: $e');
      emit(
        state.copyWith(
          status: BlocTaskStatus.error,
          errorMessage: 'Bỏ gán công việc thất bại',
        ),
      );
    }
  }
}
