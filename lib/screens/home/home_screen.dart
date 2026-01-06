import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/attendance/attendance_bloc.dart';
import 'package:mobile/blocs/attendance/attendance_event.dart';
import 'package:mobile/blocs/attendance/attendance_state.dart';
import 'package:mobile/blocs/employee/employee_bloc.dart';
import 'package:mobile/blocs/employee/employee_state.dart';
import 'widgets/home_header.dart';
import 'widgets/date_selector.dart';
import 'widgets/activity_section.dart';
import 'widgets/swipe_action_button.dart';
import 'widgets/attendance_card.dart';
import 'package:mobile/core/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
    _setupReminders();
  }

  /// Setup daily reminders
  void _setupReminders() {
    // Nhắc check-in lúc 8:00
    _notificationService.scheduleCheckInReminder(hour: 8, minute: 0);
    
    // Nhắc check-out lúc 17:30
    _notificationService.scheduleCheckOutReminder(hour: 17, minute: 30);
  }

  void _loadTodayAttendance() {
    context.read<AttendanceBloc>().add(const LoadTodayAttendanceEvent());

    final now = DateTime.now();
    context.read<AttendanceBloc>().add(
      LoadMyAttendanceEvent(month: now.month, year: now.year),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: BlocListener<AttendanceBloc, AttendanceState>(
        listenWhen: (previous, current) =>
            previous.status != current.status,
        listener: (context, state) {
          // Check-in thành công
          if (state.status == AttendanceStatus.checkedIn) {
            // _showSnackBar('Đã check-in thành công lúc ${state.todayCheckInTime}!', isSuccess: true);
            _refreshAttendanceList();
            
            // Gửi notification
            _notificationService.showCheckInSuccess(
              time: state.todayCheckInTime,
              employeeName: _getEmployeeName(),
            );
          }
          
          // Check-out thành công
          if (state.status == AttendanceStatus.checkedOut) {
            // _showSnackBar('Đã check-out thành công lúc ${state.todayCheckOutTime}!', isSuccess: true);
            _refreshAttendanceList();
            
            // Gửi notification
            _notificationService.showCheckOutSuccess(
              time: state.todayCheckOutTime,
              totalHours: state.todayTotalHours,
              employeeName: _getEmployeeName(),
            );
          }
          
          // Error
          if (state.status == AttendanceStatus.error) {
            // _showSnackBar(state.errorMessage ?? 'Đã xảy ra lỗi', isSuccess: false);
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<EmployeeBloc, EmployeeState>(
                        builder: (context, state) {
                          if (state.employees.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return HomeHeader(employee: state.employees.first);
                        },
                      ),
                      const SizedBox(height: 24),
                      const DateSelector(),
                      const SizedBox(height: 24),
                      const AttendanceCard(),
                      const SizedBox(height: 24),
                      BlocBuilder<AttendanceBloc, AttendanceState>(
                        buildWhen: (previous, current) =>
                            previous.myAttendances != current.myAttendances,
                        builder: (context, state) {
                          return ActivitySection(
                            attendances: state.myAttendances,
                            onViewAll: () {
                              print('Navigate to Attendance Screen');
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Swipe button
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: BlocBuilder<AttendanceBloc, AttendanceState>(
                  buildWhen: (previous, current) =>
                      previous.hasCheckedInToday != current.hasCheckedInToday ||
                      previous.hasCheckedOutToday != current.hasCheckedOutToday ||
                      previous.isCheckingIn != current.isCheckingIn ||
                      previous.isCheckingOut != current.isCheckingOut,
                  builder: (context, state) {
                    // Hiển thị loading khi đang check-in/check-out
                    if (state.isCheckingIn || state.isCheckingOut) {
                      return _buildLoadingButton(state.isCheckingIn);
                    }

                    // Đã check-out xong -> hiển thị completed
                    if (state.hasCheckedOutToday) {
                      return _buildCompletedButton();
                    }

                    // Có thể check-out
                    if (state.canCheckOut) {
                      return SwipeActionButton.checkOut(
                        onSwipeComplete: _handleCheckOut,
                      );
                    }

                    // Có thể check-in
                    return SwipeActionButton.checkIn(
                      onSwipeComplete: _handleCheckIn,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Loading button khi đang xử lý
  Widget _buildLoadingButton(bool isCheckingIn) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isCheckingIn ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isCheckingIn ? 'Đang check-in...' : 'Đang check-out...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Completed button khi đã check-out xong
  Widget _buildCompletedButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Text(
            'Đã hoàn thành hôm nay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Xử lý check-in
  void _handleCheckIn() {
    final currentTime = AttendanceBloc.getCurrentTimeFormatted();
    context.read<AttendanceBloc>().add(CheckInEvent(time: currentTime));
  }

  /// Xử lý check-out
  void _handleCheckOut() {
    final currentTime = AttendanceBloc.getCurrentTimeFormatted();
    context.read<AttendanceBloc>().add(CheckOutEvent(time: currentTime));
  }

  /// Refresh attendance list sau khi check-in/check-out
  void _refreshAttendanceList() {
    final now = DateTime.now();
    context.read<AttendanceBloc>().add(
      LoadMyAttendanceEvent(month: now.month, year: now.year),
    );
  }


  /// Lấy tên nhân viên từ EmployeeBloc
  String? _getEmployeeName() {
    final employeeState = context.read<EmployeeBloc>().state;
    if (employeeState.employees.isNotEmpty) {
      final emp = employeeState.employees.first;
      return '${emp.firstName} ${emp.lastName}';
    }
    return null;
  }

}
