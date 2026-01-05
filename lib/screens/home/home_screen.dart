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

/// Home Screen - Màn hình chính
/// Hiển thị attendance today và cho phép check-in/check-out
/// Sử dụng AttendanceBloc để quản lý state và gọi API
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load today's attendance khi khởi tạo màn hình
    _loadTodayAttendance();
  }

  /// Load today's attendance và my attendance list
  void _loadTodayAttendance() {
    context.read<AttendanceBloc>().add(const LoadTodayAttendanceEvent());

    // Load my attendance list cho ActivitySection
    final now = DateTime.now();
    context.read<AttendanceBloc>().add(
      LoadMyAttendanceEvent(month: now.month, year: now.year),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                            // Navigate to AttendanceScreen khi người dùng bấm "View All"
                            Navigator.pushNamed(context, '/attendance');
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Swipe button ở dưới, trên navbar
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
                  final canCheckOut = state.canCheckOut;

                  return canCheckOut
                      ? SwipeActionButton.checkOut(
                          onSwipeComplete: _handleCheckOut,
                        )
                      : SwipeActionButton.checkIn(
                          onSwipeComplete: _handleCheckIn,
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xử lý check-in
  void _handleCheckIn() {
    final currentTime = AttendanceBloc.getCurrentTimeFormatted();
    context.read<AttendanceBloc>().add(CheckInEvent(time: currentTime));
    _showSnackBar('Đã check-in thành công!');
  }

  /// Xử lý check-out
  void _handleCheckOut() {
    final currentTime = AttendanceBloc.getCurrentTimeFormatted();
    context.read<AttendanceBloc>().add(CheckOutEvent(time: currentTime));
    _showSnackBar('Đã check-out thành công!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
