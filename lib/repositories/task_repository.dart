import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:mobile/core/network/api_url.dart';
import 'package:mobile/core/network/dio_api.dart';
import 'package:mobile/models/pagination_model.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/utils/task/task_priority.dart';
import 'package:mobile/utils/task/task_type.dart';

class TaskRepository {
  final DioClient client;
  final Logger _logger = Logger();

  TaskRepository({DioClient? client}) : client = client ?? DioClient();

  // CREATE TASK
  Future<TaskModel> createTask({
    required String title,
    required int departmentId, 
    String? description,
    required TaskPriority priority,
    required TaskType type,

    DateTime? startDate,
    DateTime? dueDate,
  }) async {
    try {
      final res = await client.post(
        ApiUrl.createTask,
        data: {
          'title': title,
          'departmentId': departmentId,
          if (description != null) 'description': description,
          'priority': priority.toApi,
          'type': type.toApi,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        },
      );

      _logger.i('[TaskRepository] Create task success');
      return TaskModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[TaskRepository] Create task error: $message');
      throw Exception(message);
    }
  }

  // GET TASKS
  Future<({List<TaskModel> tasks, Pagination pagination})> getTasks({
    required int page,
    required int limit,
  }) async {
    try {
      final res = await client.get(
        ApiUrl.getTasks,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = res.data as Map<String, dynamic>;

      final tasks = (data['data'] as List)
          .map((e) => TaskModel.fromJson(e))
          .toList();

      final pagination = Pagination.fromJson(data['pagination']);

      _logger.i(
        '[TaskRepository] Loaded ${tasks.length} tasks (page ${pagination.page})',
      );

      return (tasks: tasks, pagination: pagination);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[TaskRepository] Get tasks error: $message');
      throw Exception(message);
    }
  }

  // GET TASK DETAIL
  Future<TaskModel> getTaskById(int taskId) async {
    try {
      final res = await client.get(ApiUrl.getTaskById(taskId));
      _logger.i('[TaskRepository] Get task detail success');
      return TaskModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[TaskRepository] Get task detail error: $message');
      throw Exception(message);
    }
  }

  // UPDATE TASK (PARTIAL)
  Future<TaskModel> updateTask(
    int taskId, {
    String? title,
    String? description,
    TaskPriority? priority,
    TaskType? type,
    DateTime? startDate,
    DateTime? dueDate,
  }) async {
    try {
      final res = await client.put(
        ApiUrl.updateTask(taskId),
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (priority != null) 'priority': priority.toApi,
          if (type != null) 'type': type.toApi,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        },
      );

      _logger.i('[TaskRepository] Update task success');
      return TaskModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[TaskRepository] Update task error: $message');
      throw Exception(message);
    }
  }

  // DELETE TASK
  Future<void> deleteTask(int taskId) async {
    try {
      await client.delete(ApiUrl.deleteTask(taskId));
      _logger.i('[TaskRepository] Delete task success');
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[TaskRepository] Delete task error: $message');
      throw Exception(message);
    }
  }

  // ASSIGN TASK - Gán task cho nhiều nhân viên
  Future<Map<String, dynamic>> assignTask({
    required int taskId,
    required List<int> employeeIds,
  }) async {
    try {
      final res = await client.put(
        ApiUrl.assignTask(taskId),
        data: {
          'employeeIds': employeeIds,
        },
      );

      _logger.i('[TaskRepository] Assign task success');
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[TaskRepository] Assign task error: $message');
      throw Exception(message);
    }
  }

  // GET TASK ASSIGNEES - Lấy danh sách nhân viên được gán task
  Future<List<TaskAssigneeModel>> getTaskAssignees(int taskId) async {
    try {
      final res = await client.get(ApiUrl.getTaskAssignees(taskId));

      final assignees = (res.data['data'] as List)
          .map((e) => TaskAssigneeModel.fromJson(e))
          .toList();

      _logger.i('[TaskRepository] Get task assignees success: ${assignees.length}');
      return assignees;
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[TaskRepository] Get task assignees error: $message');
      throw Exception(message);
    }
  }

  // UNASSIGN TASK - Bỏ gán task cho nhân viên
  Future<void> unassignTask({
    required int taskId,
    required int employeeId,
  }) async {
    try {
      await client.delete(ApiUrl.unassignTask(taskId, employeeId));
      _logger.i('[TaskRepository] Unassign task success');
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[TaskRepository] Unassign task error: $message');
      throw Exception(message);
    }
  }

  // HELPER
  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['message'] ??
          e.message ??
          'Đã xảy ra lỗi';
    }
    return e.message ?? 'Đã xảy ra lỗi';
  }
}
