import 'package:mobile/core/network/api_url.dart';
import 'package:mobile/core/network/dio_api.dart';
import 'package:mobile/models/department_model.dart';

class DepartmentsRepository {
  final DioClient client;

  DepartmentsRepository({DioClient? client}) : client = client ?? DioClient();

  // get all departments
  Future<List<Department>> getDepartments() async {
    try {
      final res = await client.get(ApiUrl.getDepartments);

      final data = res.data as Map<String, dynamic>;
      final departments = (data['data'] as List)
          .map((e) => Department.fromJson(e))
          .toList();

      return departments;
    } catch (e) {
      throw Exception('Failed to load departments: $e');
    }
  }
}