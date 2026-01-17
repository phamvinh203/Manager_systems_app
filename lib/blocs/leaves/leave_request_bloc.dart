import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:mobile/blocs/leaves/leave_request_event.dart';
import 'package:mobile/blocs/leaves/leave_request_state.dart';
import 'package:mobile/repositories/leave_request_repository.dart';

class LeaveRequestBloc extends Bloc<LeaveRequestEvent, LeaveRequestState> {
  final LeaveRequestRepository leaveRequestRepository;
  final Logger _logger = Logger();

  LeaveRequestBloc(this.leaveRequestRepository)
    : super(const LeaveRequestState()) {
    on<LoadLeaveRequestsEvent>(_onLoadLeaveRequests);
    on<CreateLeaveRequestEvent>(_onCreateLeaveRequest);
    on<LeaveRequestDetailEvent>(_onLeaveRequestDetail);
    on<CancelLeaveRequestEvent>(_onCancelLeaveRequest);
    on<LoadAllLeaveRequestsEvent>(_onLoadAllLeaveRequests);
    on<LoadTeamLeaveRequestsEvent>(_onLoadTeamLeaveRequests);
    // on<ApproveTeamLeaveRequestEvent>(_onApproveTeamLeaveRequest);
    // on<RejectTeamLeaveRequestEvent>(_onRejectTeamLeaveRequest);
  }

  // Load leave requests
  Future<void> _onLoadLeaveRequests(
    LoadLeaveRequestsEvent event,
    Emitter<LeaveRequestState> emit,
  ) async {
    emit(state.copyWith(status: LeaveRequestStatus.loading, clearError: true));

    try {
      final respone = await leaveRequestRepository.getMyLeaveRequests(
        page: 1,
        limit: event.limit,
      );

      emit(
        state.copyWith(
          status: LeaveRequestStatus.loaded,
          leaveRequests: respone.leaveRequests,
          pagination: respone.pagination,
        ),
      );

      _logger.i(
        'Loaded ${respone.leaveRequests.length} leave requests (page ${respone.pagination.page})',
      );
    } catch (e) {
      _logger.e('Load leave requests error: $e');

      emit(
        state.copyWith(
          status: LeaveRequestStatus.error,
          errorMessage: 'Failed to load leave requests',
        ),
      );
    }
  }

  // Create leave request
  Future<void> _onCreateLeaveRequest(
    CreateLeaveRequestEvent event,
    Emitter<LeaveRequestState> emit,
  ) async {
    emit(state.copyWith(status: LeaveRequestStatus.loading, clearError: true));

    try {
      final newLeaveRequest = await leaveRequestRepository.createLeaveRequest(
        leaveType: event.leaveType,
        startDate: event.startDate,
        endDate: event.endDate,
        reason: event.reason,
      );
      emit(
        state.copyWith(
          status: LeaveRequestStatus.success,
          currentLeaveRequest: newLeaveRequest,
          successMessage: 'Leave request created successfully',
        ),
      );

      _logger.i('Created leave request id=${newLeaveRequest.id}');
    } catch (e) {
      _logger.e('Create leave request error: $e');

      emit(
        state.copyWith(
          status: LeaveRequestStatus.error,
          errorMessage: 'Failed to create leave request',
        ),
      );
    }
  }

  // Load leave request detail
  Future<void> _onLeaveRequestDetail(
    LeaveRequestDetailEvent event,
    Emitter<LeaveRequestState> emit,
  ) async {
    emit(state.copyWith(status: LeaveRequestStatus.loading, clearError: true));

    try {
      final leaveRequest = await leaveRequestRepository.getLeaveRequestDetail(
        event.requestId,
      );

      emit(
        state.copyWith(
          status: LeaveRequestStatus.loaded,
          currentLeaveRequest: leaveRequest,
        ),
      );

      _logger.i('Loaded leave request detail id=${leaveRequest.id}');
    } catch (e) {
      _logger.e('Load leave request detail error: $e');

      emit(
        state.copyWith(
          status: LeaveRequestStatus.error,
          errorMessage: 'Failed to load leave request detail',
        ),
      );
    }
  }

  // Cancel leave request - hủy đơn nghỉ phép
  Future<void> _onCancelLeaveRequest(
    CancelLeaveRequestEvent event,
    Emitter<LeaveRequestState> emit,
  ) async {
    emit(state.copyWith(status: LeaveRequestStatus.loading, clearError: true));
    try {
      await leaveRequestRepository.cancelLeaveRequest(event.requestId);

      emit(
        state.copyWith(
          status: LeaveRequestStatus.success,
          successMessage: 'Leave request canceled successfully',
        ),
      );

      _logger.i('Canceled leave request id=${event.requestId}');
    } catch (e) {
      _logger.e('Cancel leave request error: $e');

      emit(
        state.copyWith(
          status: LeaveRequestStatus.error,
          errorMessage: 'Failed to cancel leave request',
        ),
      );
    }
  }

  // Load all leave requests (for HR/Manager)
  Future<void> _onLoadAllLeaveRequests(
    LoadAllLeaveRequestsEvent event,
    Emitter<LeaveRequestState> emit,
  ) async {
    emit(state.copyWith(status: LeaveRequestStatus.loading, clearError: true));

    try {
      final response = await leaveRequestRepository.getAllLeaveRequests(
        page: event.page,
        limit: event.limit,
        departmentId: event.departmentId,
      );

      emit(
        state.copyWith(
          status: LeaveRequestStatus.loaded,
          leaveRequests: response.leaveRequests,
          pagination: response.pagination,
        ),
      );

      _logger.i(
        'Loaded ALL leave requests '
        '(page=${event.page}, departmentId=${event.departmentId})',
      );
    } catch (e) {
      _logger.e('Load all leave requests error: $e');

      emit(
        state.copyWith(
          status: LeaveRequestStatus.error,
          errorMessage: 'Failed to load all leave requests',
        ),
      );
    }
  }

  // Load manager's team leave requests
  Future<void> _onLoadTeamLeaveRequests(
    LoadTeamLeaveRequestsEvent event,
    Emitter<LeaveRequestState> emit,
  ) async {
    emit(state.copyWith(status: LeaveRequestStatus.loading, clearError: true));

    try {
      final response = await leaveRequestRepository.getTeamLeaveRequests(
        page: event.page,
        limit: event.limit,
      );

      emit(
        state.copyWith(
          status: LeaveRequestStatus.loaded,
          leaveRequests: response.leaveRequests,
          pagination: response.pagination,
        ),
      );

      _logger.i(
        'Loaded TEAM leave requests '
        '(page=${event.page})',
      );
    } catch (e) {
      _logger.e('Load team leave requests error: $e');

      emit(
        state.copyWith(
          status: LeaveRequestStatus.error,
          errorMessage: 'Failed to load team leave requests',
        ),
      );
    }
  }
}
