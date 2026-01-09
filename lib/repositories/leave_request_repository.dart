import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:mobile/core/network/api_url.dart';
import 'package:mobile/core/network/dio_api.dart';
import 'package:mobile/models/leave_request_model.dart';
import 'package:mobile/models/pagination_model.dart';
import 'package:mobile/utils/enum/leave_type.dart';

class LeaveRequestRepository {
  final DioClient client;
  final Logger _logger = Logger();

  LeaveRequestRepository({DioClient? client}) : client = client ?? DioClient();

  // CREATE LEAVE REQUEST - Tạo đơn xin nghỉ phép
  Future<LeaveRequestModel> createLeaveRequest({
    required LeaveType leaveType,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    try {
      final res = await client.post(
        ApiUrl.leaveRequests,
        data: {
          'leaveType': leaveType.toApi,
          'startDate': startDate,
          'endDate': endDate,
          'reason': reason,
        },
      );

      final data = res.data as Map<String, dynamic>;
      _logger.i('[LeaveRequestRepository] Create leave request successful');

      return LeaveRequestModel.fromJson(data['data']);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[LeaveRequestRepository] Create leave request error: $message');
      throw Exception(message);
    }
  }

  // GET MY LEAVE REQUESTS - Lấy danh sách đơn xin nghỉ của bản thân
  Future<({List<LeaveRequestModel> leaveRequests, Pagination pagination})> getMyLeaveRequests({
    required int page,
    required int limit,
  }) async {
    try {
      final res = await client.get(
        ApiUrl.myLeaveRequests,
        queryParameters: {'page': page, 'limit': limit},
      );

      final data = res.data as Map<String, dynamic>;

      final leaveRequests = (data['data'] as List)
          .map((e) => LeaveRequestModel.fromJson(e))
          .toList();

      final pagination = Pagination.fromJson(data['pagination']);

      _logger.i(
        '[LeaveRequestRepository] Fetched ${leaveRequests.length} leave requests | page ${pagination.page}/${pagination.totalPages}',
      );

      return (leaveRequests: leaveRequests, pagination: pagination);
    } on DioException catch (e) {
      _logger.e(
        '[LeaveRequestRepository] getMyLeaveRequests error: ${e.message}',
      );
      throw Exception(_getErrorMessage(e));
    }
  }

  // Get LEAVE REQUEST DETAIL - Lấy chi tiết đơn xin nghỉ phép theo ID
  Future<LeaveRequestModel> getLeaveRequestDetail(String requestId) async {
    try {
      final res = await client.get('${ApiUrl.myIdLeaveRequests}/$requestId');
      final data = res.data as Map<String, dynamic>;
      _logger.i('[LeaveRequestRepository] Fetched leave request detail');
      return LeaveRequestModel.fromJson(data['data']);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[LeaveRequestRepository] getLeaveRequestDetail error: $message');
      throw Exception(message);
    }
  }

  // Patch CANCEL LEAVE REQUEST - Hủy đơn xin nghỉ phép
  Future<void> cancelLeaveRequest(String requestId) async {
    try {
      await client.patch(ApiUrl.cancelLeaveRequest(requestId));
      _logger.i('[LeaveRequestRepository] Cancelled leave request $requestId');
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      _logger.e('[LeaveRequestRepository] cancelLeaveRequest error: $message');
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
