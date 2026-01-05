import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:mobile/repositories/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;
  final Logger _logger = Logger();

  AttendanceBloc(this.repository) : super(const AttendanceInitial()) {
    on<CheckInEvent>(_onCheckIn);
    on<CheckOutEvent>(_onCheckOut);
    on<LoadTodayAttendanceEvent>(_onLoadTodayAttendance);
    on<LoadMyAttendanceEvent>(_onLoadMyAttendance);
    on<LoadAllAttendanceEvent>(_onLoadAllAttendance);
    on<RefreshAttendanceEvent>(_onRefresh);
    on<ResetAttendanceEvent>(_onReset);
    on<ChangeFilterEvent>(_onChangeFilter);
  }

  // Check-in
  Future<void> _onCheckIn(
    CheckInEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatus.checkingIn, clearError: true));

    try {
      final attendance = await repository.checkIn(event.time);

      emit(state.copyWith(
        status: AttendanceStatus.checkedIn,
        todayAttendance: attendance,
      ));

      _logger.i('Checked in at ${event.time}');
    } on Exception  catch (e) {
      _logger.e('Check-in error: ${e.toString()}');
      emit(state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: e.toString(),
      ));
    } catch (e) {
      _logger.e('Check-in error: $e');
      emit(state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: 'Đã xảy ra lỗi không xác định',
      ));
    }
  }

  // Check-out
  Future<void> _onCheckOut(
    CheckOutEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatus.checkingOut, clearError: true));

    try {
      final attendance = await repository.checkOut(event.time);

      emit(state.copyWith(
        status: AttendanceStatus.checkedOut,
        todayAttendance: attendance,
      ));

      _logger.i('Checked out at ${event.time}');
    } on Exception  catch (e) {
      _logger.e('Check-out error: ${e.toString()}');
      emit(state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: e.toString(),
      ));
    } catch (e) {
      _logger.e('Check-out error: $e');
      emit(state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: 'Đã xảy ra lỗi không xác định',
      ));
    }
  }

  // Load today attendance
  Future<void> _onLoadTodayAttendance(
    LoadTodayAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatus.loading, clearError: true));

    try {
      final todayAttendance = await repository.getTodayAttendance();

      emit(state.copyWith(
        status: AttendanceStatus.loaded,
        todayAttendance: todayAttendance,
        clearTodayAttendance: todayAttendance == null,
      ));

      _logger.i('Loaded today attendance: ${todayAttendance != null ? "Found" : "Not found"}');
    } on Exception  catch (e) {
      _logger.e('Load today attendance error: ${e.toString()}');
      emit(state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: e.toString(),
      ));
    } catch (e) {
      _logger.e('Load today attendance error: $e');
      emit(state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: 'Đã xảy ra lỗi không xác định',
      ));
    }
  }

  // Load my attendance
  Future<void> _onLoadMyAttendance(
    LoadMyAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(
      status: AttendanceStatus.loading,
      clearError: true,
      filterMonth: event.month,
      filterYear: event.year,
    ));

    try {
      final response = await repository.getMyAttendance(
        month: event.month,
        year: event.year,
      );

      // Also get today's attendance
      final todayAttendance = await repository.getTodayAttendance();

      emit(state.copyWith(
        status: AttendanceStatus.loaded,
        myAttendances: response.attendances,
        summary: response.summary,
        todayAttendance: todayAttendance,
      ));

      _logger.i('Loaded ${response.attendances.length} attendances for ${event.month}/${event.year}');
    } on Exception  catch (e) {
      _logger.e('Load my attendance error: ${e.toString()}');
      emit(state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: e.toString(),
      ));
    } catch (e) {
      _logger.e('Load my attendance error: $e');
      emit(state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: 'Đã xảy ra lỗi không xác định',
      ));
    }
  }

  // Load all attendance (HR/Admin)
  Future<void> _onLoadAllAttendance(
    LoadAllAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(
      status: AttendanceStatus.loading,
      clearError: true,
      filterMonth: event.month,
      filterYear: event.year,
      filterEmployeeId: event.employeeId,
      hasReachedMax: false,
    ));

    try {
      final response = await repository.getAllAttendance(
        page: event.page,
        limit: event.limit,
        employeeId: event.employeeId,
        month: event.month,
        year: event.year,
        date: event.date,
      );

      emit(state.copyWith(
        status: AttendanceStatus.loaded,
        allAttendances: response.attendances,
        pagination: response.pagination,
      ));

      _logger.i('Loaded ${response.attendances.length} attendances (page ${response.pagination.page})');
    } on Exception  catch (e) {
      _logger.e('Load all attendance error: ${e.toString()}');
      emit(state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: e.toString(),
      ));
    } catch (e) {
      _logger.e('Load all attendance error: $e');
      emit(state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: 'Đã xảy ra lỗi không xác định',
      ));
    }
  }

  // Refresh
  Future<void> _onRefresh(
    RefreshAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      final now = DateTime.now();

      // Refresh my attendance
      final myResponse = await repository.getMyAttendance(
        month: state.filterMonth ?? now.month,
        year: state.filterYear ?? now.year,
      );

      // Refresh today's attendance
      final todayAttendance = await repository.getTodayAttendance();

      emit(state.copyWith(
        status: AttendanceStatus.loaded,
        myAttendances: myResponse.attendances,
        summary: myResponse.summary,
        todayAttendance: todayAttendance,
        clearError: true,
      ));

      _logger.i('Refreshed ${myResponse.attendances.length} attendances');
    } on Exception  catch (e) {
      _logger.e('Refresh attendance error: ${e.toString()}');
      emit(state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: e.toString(),
      ));
    } catch (e) {
      _logger.e('Refresh attendance error: $e');
      emit(state.copyWith(
        status: AttendanceStatus.error,
        errorMessage: 'Đã xảy ra lỗi không xác định',
      ));
    }
  }

  // Reset
  void _onReset(
    ResetAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) {
    emit(const AttendanceInitial());
  }

  // Change filter
  Future<void> _onChangeFilter(
    ChangeFilterEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(
      filterMonth: event.month,
      filterYear: event.year,
      filterEmployeeId: event.employeeId,
    ));

    // Reload data with new filters
    add(LoadMyAttendanceEvent(
      month: event.month,
      year: event.year,
    ));
  }

  // Helper methods

  /// Get current time formatted as HH:mm
  static String getCurrentTimeFormatted() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  /// Quick check-in with current time
  void quickCheckIn() {
    add(CheckInEvent(time: getCurrentTimeFormatted()));
  }

  /// Quick check-out with current time
  void quickCheckOut() {
    add(CheckOutEvent(time: getCurrentTimeFormatted()));
  }
}