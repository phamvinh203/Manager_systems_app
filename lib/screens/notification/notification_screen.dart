// lib/screens/notification/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/attendance/attendance_bloc.dart';
import 'package:mobile/blocs/attendance/attendance_state.dart';
import 'package:mobile/models/attendance_model.dart';
import 'package:mobile/screens/notification/widgets/notification_buttom_sheet.dart';
import 'package:mobile/screens/notification/widgets/notification_setting.dart';

class NotificationScreen extends StatefulWidget {
  final ScrollController scrollController;

  const NotificationScreen({super.key, required this.scrollController});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      buildWhen: (previous, current) =>
          previous.myAttendances != current.myAttendances,
      builder: (context, state) {
        final attendances = state.myAttendances;

        return ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            _buildHeader(),

            // Content
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (attendances.isEmpty)
              _buildEmptyState()
            else
              ...attendances.map((att) => _buildAttendanceItem(att)),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 40),
            const Text(
              'Thông báo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            IconButton(
              onPressed: _openSettings,
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xFF64748B),
              ),
              tooltip: 'Cài đặt',
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAttendanceItem(AttendanceModel attendance) {
    final bool isCheckOut = attendance.hasCheckedOut;
    final bool isCheckIn = attendance.hasCheckedIn && !attendance.hasCheckedOut;

    final String title;
    final String body;
    final IconData icon;
    final Color color;

    if (isCheckOut) {
      title = 'Check-out thành công';
      body = 'Đã check-out lúc ${attendance.checkOutTimeFormatted} - Tổng: ${attendance.totalHoursFormatted}';
      icon = Icons.logout_rounded;
      color = const Color(0xFFF59E0B);
    } else if (isCheckIn) {
      title = 'Check-in thành công';
      body = 'Đã check-in lúc ${attendance.checkInTimeFormatted}';
      icon = Icons.login_rounded;
      color = const Color(0xFF22C55E);
    } else {
      title = 'Chưa chấm công';
      body = 'Bạn chưa check-in ngày này';
      icon = Icons.warning_amber_rounded;
      color = const Color(0xFFEF4444);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(attendance.date),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có thông báo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Các thông báo chấm công sẽ xuất hiện ở đây',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hôm nay';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationBottomSheet(
        initialChildSize: 0.7,
        builder: (controller) => NotificationSetting(scrollController: controller),
      ),
    );
  }
}