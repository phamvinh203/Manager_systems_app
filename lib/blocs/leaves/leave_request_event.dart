import 'package:equatable/equatable.dart';
import 'package:mobile/utils/enum/leave_type.dart';

abstract class LeaveRequestEvent extends Equatable {
  const LeaveRequestEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeaveRequestsEvent extends LeaveRequestEvent {
  final int page;
  final int limit;
  final int? departmentId;

  const LoadLeaveRequestsEvent({
    this.page = 1,
    this.limit = 10,
    this.departmentId,
  });
  @override
  List<Object?> get props => [page, limit, departmentId];
}

// tạo đơn
class CreateLeaveRequestEvent extends LeaveRequestEvent {
  final LeaveType leaveType;
  final String startDate;
  final String endDate;
  final String reason;

  const CreateLeaveRequestEvent({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  @override
  List<Object?> get props => [leaveType, startDate, endDate, reason];
}

// detail đơn
class LeaveRequestDetailEvent extends LeaveRequestEvent {
  final String requestId;

  const LeaveRequestDetailEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

// hủy đơn
class CancelLeaveRequestEvent extends LeaveRequestEvent {
  final String requestId;

  const CancelLeaveRequestEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

// Load all leave requests (for HR/Manager)
class LoadAllLeaveRequestsEvent extends LeaveRequestEvent {
  final int page;
  final int limit;
  final int? departmentId;

  const LoadAllLeaveRequestsEvent({
    this.page = 1,
    this.limit = 10,
    this.departmentId,
  });

  @override
  List<Object?> get props => [page, limit, departmentId];
}

// Load manager's team leave requests
class LoadTeamLeaveRequestsEvent extends LeaveRequestEvent {
  final int page;
  final int limit;

  const LoadTeamLeaveRequestsEvent({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

// Phê duyệt đơn (Manager)
class ApproveTeamLeaveRequestEvent extends LeaveRequestEvent {
  final String requestId;

  const ApproveTeamLeaveRequestEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

// Từ chối đơn (Manager)
class RejectTeamLeaveRequestEvent extends LeaveRequestEvent {
  final String requestId;
  final String? rejectNote;

  const RejectTeamLeaveRequestEvent({required this.requestId, this.rejectNote});

  @override
  List<Object?> get props => [requestId, rejectNote];
}
