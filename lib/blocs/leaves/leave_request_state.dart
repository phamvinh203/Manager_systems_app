import 'package:equatable/equatable.dart';
import 'package:mobile/models/leave_request_model.dart';
import 'package:mobile/models/pagination_model.dart';

enum LeaveRequestStatus { initial, loading, loaded ,success, error }

class LeaveRequestState extends Equatable {
  final LeaveRequestStatus status;

  final List<LeaveRequestModel>? leaveRequests;
  final Pagination? pagination;
  final LeaveRequestModel? currentLeaveRequest;

  final String? successMessage;
  final String? errorMessage;

  const LeaveRequestState({
    this.status = LeaveRequestStatus.initial,
    this.leaveRequests = const [],
    this.pagination,
    this.currentLeaveRequest,
    this.successMessage,
    this.errorMessage,
  });

  factory LeaveRequestState.initial() {
    return const LeaveRequestState();
  }

  LeaveRequestState copyWith({
    LeaveRequestStatus? status,
    List<LeaveRequestModel>? leaveRequests,
    Pagination? pagination,
    LeaveRequestModel? currentLeaveRequest,
    String? successMessage,
    String? errorMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearPagination = false,
  }) {
    return LeaveRequestState(
      status: status ?? this.status,
      leaveRequests: leaveRequests ?? this.leaveRequests,
      pagination: clearPagination ? null : (pagination ?? this.pagination),
      currentLeaveRequest: currentLeaveRequest ?? this.currentLeaveRequest,
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  // Helper getters
  bool get isInitial => status == LeaveRequestStatus.initial;
  bool get isLoading => status == LeaveRequestStatus.loading;
  bool get isSuccess => status == LeaveRequestStatus.success;
  bool get isError => status == LeaveRequestStatus.error;

  @override
  List<Object?> get props => [
    status,
    leaveRequests,
    pagination,
    currentLeaveRequest,
    successMessage,
    errorMessage,
  ];
}
