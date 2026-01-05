// lib/features/attendance/presentation/bloc/attendance_event.dart

import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

// ============== CHECK-IN EVENT ==============
class CheckInEvent extends AttendanceEvent {
  final String time;

  const CheckInEvent({required this.time});

  @override
  List<Object?> get props => [time];
}

// ============== CHECK-OUT EVENT ==============
class CheckOutEvent extends AttendanceEvent {
  final String time;

  const CheckOutEvent({required this.time});

  @override
  List<Object?> get props => [time];
}

// ============== LOAD MY ATTENDANCE EVENT ==============
class LoadMyAttendanceEvent extends AttendanceEvent {
  final int? month;
  final int? year;

  const LoadMyAttendanceEvent({
    this.month,
    this.year,
  });

  @override
  List<Object?> get props => [month, year];
}

// ============== LOAD ALL ATTENDANCE EVENT (HR/Admin) ==============
class LoadAllAttendanceEvent extends AttendanceEvent {
  final int page;
  final int limit;
  final int? employeeId;
  final int? month;
  final int? year;
  final DateTime? date;

  const LoadAllAttendanceEvent({
    this.page = 1,
    this.limit = 10,
    this.employeeId,
    this.month,
    this.year,
    this.date,
  });

  @override
  List<Object?> get props => [page, limit, employeeId, month, year, date];
}

// ============== LOAD TODAY ATTENDANCE EVENT ==============
class LoadTodayAttendanceEvent extends AttendanceEvent {
  const LoadTodayAttendanceEvent();
}

// ============== REFRESH EVENT ==============
class RefreshAttendanceEvent extends AttendanceEvent {
  const RefreshAttendanceEvent();
}

// ============== RESET EVENT ==============
class ResetAttendanceEvent extends AttendanceEvent {
  const ResetAttendanceEvent();
}

// ============== CHANGE FILTER EVENT ==============
class ChangeFilterEvent extends AttendanceEvent {
  final int? month;
  final int? year;
  final int? employeeId;

  const ChangeFilterEvent({
    this.month,
    this.year,
    this.employeeId,
  });

  @override
  List<Object?> get props => [month, year, employeeId];
}

// ============== LOAD MORE EVENT (Pagination) ==============
class LoadMoreAttendanceEvent extends AttendanceEvent {
  const LoadMoreAttendanceEvent();
}