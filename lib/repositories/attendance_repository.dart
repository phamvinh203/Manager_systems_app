import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:mobile/core/network/api_url.dart';
import 'package:mobile/core/network/dio_api.dart';
import 'package:mobile/models/attendance_model.dart';
import 'package:mobile/models/pagination_model.dart';

class AttendanceRepository {
  final DioClient client;
  final Logger _logger = Logger();

  AttendanceRepository({DioClient? client}) : client = client ?? DioClient();

  // CHECK-IN
  Future<AttendanceModel> checkIn(String time) async {
    try {
      final res = await client.post(ApiUrl.checkIn, data: {'time': time});

      final data = res.data as Map<String, dynamic>;
      _logger.i('[AttendanceRepository] Check-in successful at $time');

      return AttendanceModel.fromJson(data['data']);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[AttendanceRepository] Check-in error: $message');
      throw Exception(message);
    }
  }

  // CHECK-OUT
  Future<AttendanceModel> checkOut(String time) async {
    try {
      final res = await client.post(ApiUrl.checkOut, data: {'time': time});

      final data = res.data as Map<String, dynamic>;
      _logger.i('[AttendanceRepository] Check-out successful at $time');

      return AttendanceModel.fromJson(data['data']);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[AttendanceRepository] Check-out error: $message');
      throw Exception(message);
    }
  }

  // MY ATTENDANCE - Lấy danh sách chấm công của mình
  Future<MyAttendanceResponse> getMyAttendance({int? month, int? year}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final res = await client.get(
        ApiUrl.meAttendance,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = res.data as Map<String, dynamic>;
      final responseData = data['data'] as Map<String, dynamic>;

      final attendances = (responseData['attendances'] as List)
          .map((e) => AttendanceModel.fromJson(e))
          .toList();

      final summary = AttendanceSummary.fromJson(responseData['summary']);

      _logger.i(
        '[AttendanceRepository] Fetched my attendance: ${attendances.length} records',
      );

      return MyAttendanceResponse(attendances: attendances, summary: summary);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[AttendanceRepository] Fetch my attendance error: $message');
      throw Exception(message);
    }
  }

  // TODAY ATTENDANCE - Lấy chấm công hôm nay
  Future<AttendanceModel?> getTodayAttendance() async {
    try {
      final now = DateTime.now();
      final response = await getMyAttendance(month: now.month, year: now.year);

      final today = DateTime(now.year, now.month, now.day);

      for (final att in response.attendances) {
        final attDate = DateTime(att.date.year, att.date.month, att.date.day);
        if (attDate.isAtSameMomentAs(today)) {
          _logger.i('[AttendanceRepository] Found today\'s attendance');
          return att;
        }
      }

      _logger.i('[AttendanceRepository] No attendance record for today');
      return null;
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e(
        '[AttendanceRepository] Fetch today attendance error: $message',
      );
      throw Exception(message);
    }
  }

  // ALL ATTENDANCE - HR/Admin xem toàn bộ
  Future<AllAttendanceResponse> getAllAttendance({
    int page = 1,
    int limit = 10,
    int? employeeId,
    int? month,
    int? year,
    DateTime? date,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (employeeId != null) queryParams['employeeId'] = employeeId;
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;
      if (date != null)
        queryParams['date'] = date.toIso8601String().split('T')[0];

      final res = await client.get(
        ApiUrl.allAttendance,
        queryParameters: queryParams,
      );

      final data = res.data as Map<String, dynamic>;

      final attendances = (data['data'] as List)
          .map((e) => AttendanceModel.fromJson(e))
          .toList();

      final pagination = Pagination.fromJson(data['pagination']);

      _logger.i(
        '[AttendanceRepository] Fetched all attendance: ${attendances.length} records',
      );

      return AllAttendanceResponse(
        attendances: attendances,
        pagination: pagination,
      );
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[AttendanceRepository] Fetch all attendance error: $message');
      throw Exception(message);
    }
  }

  // Helper: Extract error message from DioException
  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? e.message ?? 'Đã xảy ra lỗi';
    }
    return e.message ?? 'Đã xảy ra lỗi';
  }
}

// Response classes
class MyAttendanceResponse {
  final List<AttendanceModel> attendances;
  final AttendanceSummary summary;

  MyAttendanceResponse({required this.attendances, required this.summary});
}

class AllAttendanceResponse {
  final List<AttendanceModel> attendances;
  final Pagination pagination;

  AllAttendanceResponse({required this.attendances, required this.pagination});
}

// class AttendanceSummary {
//   final int totalDays;
//   final double totalWorkedHours;

//   AttendanceSummary({
//     required this.totalDays,
//     required this.totalWorkedHours,
//   });

//   factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
//     return AttendanceSummary(
//       totalDays: json['totalDays'] as int,
//       totalWorkedHours: (json['totalWorkedHours'] as num).toDouble(),
//     );
//   }
// }
