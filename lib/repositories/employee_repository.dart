import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:mobile/core/network/dio_api.dart';
import 'package:mobile/models/employee_model.dart';
import 'package:mobile/models/pagination_model.dart';



class EmployeeRepository {
  final DioClient client;
  final Logger _logger = Logger();

    EmployeeRepository({DioClient? client}) : client = client ?? DioClient();


  // GET EMPLOYEES (LIST)
  Future<({
    List<Employee> employees,
    Pagination pagination,
  })> getEmployees({
    required int page,
    required int limit,
  }) async {
    try {
      final res = await client.get(
        '/employees',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = res.data as Map<String, dynamic>;

      final employees = (data['data'] as List)
          .map((e) => Employee.fromJson(e))
          .toList();

      final pagination = Pagination.fromJson(data['pagination']);

      _logger.i(
        '[EmployeeRepository] Fetched ${employees.length} employees | page ${pagination.page}/${pagination.totalPages}',
      );

      return (
        employees: employees,
        pagination: pagination,
      );
    } on DioException catch (e) {
      _logger.e(
        '[EmployeeRepository] fetchEmployees error: ${e.message}',
      );
      throw Exception(_mapDioError(e));
    }
  }

  // GET EMPLOYEE DETAIL
  Future<Employee> fetchEmployeeById(int id) async {
    try {
      final res = await client.get('employees/$id');

      final data = res.data as Map<String, dynamic>;
      final employee = Employee.fromJson(data['data']);

      _logger.i(
        '[EmployeeRepository] Fetched employee id=$id',
      );

      return employee;
    } on DioException catch (e) {
      _logger.e(
        '[EmployeeRepository] fetchEmployeeById error: ${e.message}',
      );
      throw Exception(_mapDioError(e));
    }
  }

  // CREATE EMPLOYEE
  Future<Employee> create(Employee employee) async {
    try {
      final res = await client.post(
        'employees',
        data: employee.toJson(),
      );

      final data = res.data as Map<String, dynamic>;
      final created = Employee.fromJson(data['data']);

      _logger.i(
        '[EmployeeRepository] Created employee id=${created.id}',
      );

      return created;
    } on DioException catch (e) {
      _logger.e(
        '[EmployeeRepository] create error: ${e.message}',
      );
      throw Exception(_mapDioError(e));
    }
  }

  // UPDATE EMPLOYEE
  Future<Employee> update(int id, Employee employee) async {
    try {
      final res = await client.put(
        'employees/$id',
        data: employee.toJson(),
      );

      final data = res.data as Map<String, dynamic>;
      final updated = Employee.fromJson(data['data']);

      _logger.i(
        '[EmployeeRepository] Updated employee id=$id',
      );

      return updated;
    } on DioException catch (e) {
      _logger.e(
        '[EmployeeRepository] update error: ${e.message}',
      );
      throw Exception(_mapDioError(e));
    }
  }

  // DELETE EMPLOYEE
  Future<void> delete(int id) async {
    try {
      await client.delete('employees/$id');

      _logger.i(
        '[EmployeeRepository] Deleted employee id=$id',
      );
    } on DioException catch (e) {
      _logger.e(
        '[EmployeeRepository] delete error: ${e.message}',
      );
      throw Exception(_mapDioError(e));
    }
  }

  // ERROR MAPPER
  String _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please try again.';
    }

    if (e.response?.statusCode == 401) {
      return 'Session expired. Please login again.';
    }

    if (e.response?.statusCode == 404) {
      return 'Resource not found.';
    }

    return 'Unexpected error occurred.';
  }
}
