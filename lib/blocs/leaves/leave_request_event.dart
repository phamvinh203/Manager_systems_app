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

  const LoadLeaveRequestsEvent({this.page = 1, this.limit = 10});
  @override
  List<Object?> get props => [page, limit];
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