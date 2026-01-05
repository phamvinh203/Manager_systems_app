import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/attendance/attendance_bloc.dart';
import 'package:mobile/blocs/attendance/attendance_state.dart';
import 'stat_item_card.dart';

/// Widget hiển thị Attendance Today Card với dữ liệu thật từ Bloc
class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      buildWhen: (previous, current) =>
          previous.todayAttendance != current.todayAttendance ||
          previous.status != current.status,
      builder: (context, state) {
        // Loading state
        if (state.isLoading && state.todayAttendance == null) {
          return _buildLoadingCard();
        }

        // Success state hoặc Empty state
        final checkInTime = state.todayCheckInTime;
        final checkOutTime = state.todayCheckOutTime;
        final hasCheckedIn = state.hasCheckedInToday;
        final hasCheckedOut = state.hasCheckedOutToday;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            // Grid 2x2 với real data
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                // Check In
                StatItemCard(
                  icon: Icons.login_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'Check In',
                  value: checkInTime,
                  subtitle: hasCheckedIn ? 'Đã check-in' : 'Chưa check-in',
                ),
                // Check Out
                StatItemCard(
                  icon: Icons.logout_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Check Out',
                  value: checkOutTime,
                  subtitle: hasCheckedOut ? 'Đã check-out' : 'Chưa check-out',
                ),
                // Break Time - giữ nguyên hardcoded
                const StatItemCard(
                  icon: Icons.coffee_rounded,
                  iconColor: Color(0xFFF59E0B),
                  title: 'Break Time',
                  value: '00:30 min',
                  subtitle: 'Avg Time 30 min',
                ),
                // Total Days - tính từ summary nếu có
                StatItemCard(
                  icon: Icons.calendar_month_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'Total Days',
                  value: state.summary?.totalDays.toString() ?? '0',
                  subtitle: 'Working Days',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Loading state card
  Widget _buildLoadingCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Today Attendance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          ),
        ),
      ],
    );
  }
}
