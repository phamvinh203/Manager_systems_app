import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:mobile/core/network/api_url.dart';
import 'package:mobile/core/network/dio_api.dart';
import 'package:mobile/models/pagination_model.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/utils/task/task_priority.dart';
import 'package:mobile/utils/task/task_type.dart';

/// Custom exception cho Task operations
class TaskException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const TaskException(this.message, {this.code, this.statusCode});

  @override
  String toString() => message;

}

class TaskRepository {
  final DioClient client;
  final Logger _logger = Logger();

  TaskRepository({DioClient? client}) : client = client ?? DioClient();

  // CREATE task

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
          'title': title.trim(),
          'departmentId': departmentId,
          if (description?.isNotEmpty == true) 'description': description!.trim(),
          'priority': priority.toApi,
          'type': type.toApi,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        },
      );

      _logger.i('[TaskRepository] Create task success');
      return TaskModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw _handleError(e, 'Tạo công việc thất bại');
    }
  }

  // get task

  Future<({List<TaskModel> tasks, Pagination pagination})> getTasks({
    required int page,
    required int limit,
    String? status,
    String? priority,
    int? departmentId,
  }) async {
    try {
      final res = await client.get(
        ApiUrl.getTasks,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (priority != null) 'priority': priority,
          if (departmentId != null) 'departmentId': departmentId,
        },
      );

      final data = res.data as Map<String, dynamic>;
      final tasks =
          (data['data'] as List).map((e) => TaskModel.fromJson(e)).toList();
      final pagination = Pagination.fromJson(data['pagination']);

      _logger.i(
        '[TaskRepository] Loaded ${tasks.length} tasks (page ${pagination.page})',
      );

      return (tasks: tasks, pagination: pagination);
    } on DioException catch (e) {
      throw _handleError(e, 'Không thể tải danh sách công việc');
    }
  }

  Future<TaskModel> getTaskById(int taskId) async {
    try {
      final res = await client.get(ApiUrl.getTaskById(taskId));
      _logger.i('[TaskRepository] Get task detail success');
      return TaskModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw _handleError(e, 'Không thể tải chi tiết công việc');
    }
  }

  // UPDATE task

  Future<TaskModel> updateTask(
    int taskId, {
    String? title,
    String? description,
    TaskPriority? priority,
    TaskType? type,
    DateTime? startDate,
    DateTime? dueDate,
  }) async {
    // Build data map only with non-null values
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title.trim();
    if (description != null) data['description'] = description.trim();
    if (priority != null) data['priority'] = priority.toApi;
    if (type != null) data['type'] = type.toApi;
    if (startDate != null) data['startDate'] = startDate.toIso8601String();
    if (dueDate != null) data['dueDate'] = dueDate.toIso8601String();

    if (data.isEmpty) {
      throw const TaskException('Không có thay đổi để cập nhật');
    }

    try {
      final res = await client.put(ApiUrl.updateTask(taskId), data: data);
      _logger.i('[TaskRepository] Update task success');
      return TaskModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw _handleError(e, 'Cập nhật công việc thất bại');
    }
  }

  // DELETE task

  Future<void> deleteTask(int taskId) async {
    try {
      await client.delete(ApiUrl.deleteTask(taskId));
      _logger.i('[TaskRepository] Delete task success');
    } on DioException catch (e) {
      throw _handleError(e, 'Xóa công việc thất bại');
    }
  }

  // ASSIGNMENTS task

  Future<Map<String, dynamic>> assignTask({
    required int taskId,
    required List<int> employeeIds,
  }) async {
    if (employeeIds.isEmpty) {
      throw const TaskException('Danh sách nhân viên không được trống');
    }

    try {
      final res = await client.put(
        ApiUrl.assignTask(taskId),
        data: {'employeeIds': employeeIds},
      );

      _logger.i('[TaskRepository] Assign task success');
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e, 'Gán công việc thất bại');
    }
  }

  // get assignees employee 

  Future<List<TaskAssigneeModel>> getTaskAssignees(int taskId) async {
    try {
      final res = await client.get(ApiUrl.getTaskAssignees(taskId));

      final assignees = (res.data['data'] as List)
          .map((e) => TaskAssigneeModel.fromJson(e))
          .toList();

      _logger.i(
        '[TaskRepository] Get task assignees success: ${assignees.length}',
      );
      return assignees;
    } on DioException catch (e) {
      throw _handleError(e, 'Không thể tải danh sách nhân viên được gán');
    }
  }


  // delete assignee employee
  Future<void> unassignTask({
    required int taskId,
    required int employeeId,
  }) async {
    try {
      await client.delete(ApiUrl.unassignTask(taskId, employeeId));
      _logger.i('[TaskRepository] Unassign task success');
    } on DioException catch (e) {
      throw _handleError(e, 'Bỏ gán công việc thất bại');
    }
  }

  // ============ ERROR HANDLING ============

  /// Centralized error handling với custom exception
  TaskException _handleError(DioException e, String defaultMessage) {
    final statusCode = e.response?.statusCode;
    String message = defaultMessage;
    String? code;

    // Extract message from response
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      message = data['message'] as String? ?? defaultMessage;
      code = data['code'] as String?;
    }

    _logger.e('[TaskRepository] Error: $message (code: $code, status: $statusCode)');

    return TaskException(message, code: code, statusCode: statusCode);
  }
}