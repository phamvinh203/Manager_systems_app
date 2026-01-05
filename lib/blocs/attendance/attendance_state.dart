import 'package:equatable/equatable.dart';
import 'package:mobile/models/attendance_model.dart';
import 'package:mobile/models/pagination_model.dart';

enum AttendanceStatus {
  initial,
  loading,
  loaded,
  error,
  checkingIn,
  checkedIn,
  checkingOut,
  checkedOut,
  loadingMore,
}

class AttendanceState extends Equatable {
  // Status
  final AttendanceStatus status;
  final String? errorMessage;

  // Today's attendance
  final AttendanceModel? todayAttendance;

  // My attendance list
  final List<AttendanceModel> myAttendances;
  final AttendanceSummary? summary;

  // All attendance list (HR/Admin)
  final List<AttendanceModel> allAttendances;
  final Pagination? pagination;

  // Filters
  final int? filterMonth;
  final int? filterYear;
  final int? filterEmployeeId;

  // Flags
  final bool hasReachedMax;

  const AttendanceState({
    this.status = AttendanceStatus.initial,
    this.errorMessage,
    this.todayAttendance,
    this.myAttendances = const [],
    this.summary,
    this.allAttendances = const [],
    this.pagination,
    this.filterMonth,
    this.filterYear,
    this.filterEmployeeId,
    this.hasReachedMax = false,
  });

  // ============== COPY WITH ==============
  AttendanceState copyWith({
    AttendanceStatus? status,
    String? errorMessage,
    AttendanceModel? todayAttendance,
    List<AttendanceModel>? myAttendances,
    AttendanceSummary? summary,
    List<AttendanceModel>? allAttendances,
    Pagination? pagination,
    int? filterMonth,
    int? filterYear,
    int? filterEmployeeId,
    bool? hasReachedMax,
    bool clearError = false,
    bool clearTodayAttendance = false,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      todayAttendance: clearTodayAttendance 
          ? null 
          : (todayAttendance ?? this.todayAttendance),
      myAttendances: myAttendances ?? this.myAttendances,
      summary: summary ?? this.summary,
      allAttendances: allAttendances ?? this.allAttendances,
      pagination: pagination ?? this.pagination,
      filterMonth: filterMonth ?? this.filterMonth,
      filterYear: filterYear ?? this.filterYear,
      filterEmployeeId: filterEmployeeId ?? this.filterEmployeeId,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  // ============== HELPER GETTERS ==============
  
  bool get isLoading => status == AttendanceStatus.loading;
  bool get isLoaded => status == AttendanceStatus.loaded;
  bool get isError => status == AttendanceStatus.error;
  bool get isCheckingIn => status == AttendanceStatus.checkingIn;
  bool get isCheckingOut => status == AttendanceStatus.checkingOut;
  bool get isLoadingMore => status == AttendanceStatus.loadingMore;

  // Today attendance helpers
  bool get hasCheckedInToday => todayAttendance?.hasCheckedIn ?? false;
  bool get hasCheckedOutToday => todayAttendance?.hasCheckedOut ?? false;
  bool get canCheckIn => !hasCheckedInToday;
  bool get canCheckOut => hasCheckedInToday && !hasCheckedOutToday;

  // Get today's check-in time formatted
  String get todayCheckInTime => todayAttendance?.checkInTimeFormatted ?? '--:--';
  String get todayCheckOutTime => todayAttendance?.checkOutTimeFormatted ?? '--:--';
  String get todayTotalHours => todayAttendance?.totalHoursFormatted ?? '--';


  // Filter display
  String get filterDisplay {
    if (filterMonth != null && filterYear != null) {
      return 'Tháng $filterMonth/$filterYear';
    }
    return 'Tất cả';
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        todayAttendance,
        myAttendances,
        summary,
        allAttendances,
        pagination,
        filterMonth,
        filterYear,
        filterEmployeeId,
        hasReachedMax,
      ];
}

// ============== INITIAL STATE ==============
class AttendanceInitial extends AttendanceState {
  const AttendanceInitial() : super();
}