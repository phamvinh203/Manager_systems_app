import 'package:flutter/material.dart';
import 'package:mobile/models/attendance_model.dart';
import 'activity_item.dart';

class ActivitySection extends StatelessWidget {
  final List<AttendanceModel> attendances;
  final VoidCallback? onViewAll;

  const ActivitySection({
    super.key,
    required this.attendances,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Activity List - Hiển thị tối đa 3 items gần nhất
        if (attendances.isEmpty) _buildEmptyState(),
        if (attendances.isNotEmpty)
          ..._buildActivityList(),
      ],
    );
  }

  /// Build danh sách activity items
  List<Widget> _buildActivityList() {
    final recentAttendances = attendances.take(3).toList();

    final List<Widget> widgets = [];

    for (int i = 0; i < recentAttendances.length; i++) {
      final attendance = recentAttendances[i];
      widgets.add(_buildActivityItem(attendance));

      // Thêm divider nếu không phải item cuối
      if (i < recentAttendances.length - 1) {
        widgets.add(const Divider(height: 1));
      }
    }

    return widgets;
  }

  /// Build activity item từ AttendanceModel
  Widget _buildActivityItem(AttendanceModel attendance) {
    IconData icon;
    String title;
    String status;

    if (!attendance.hasCheckedIn) {
      icon = Icons.event_busy_rounded;
      title = 'Nghỉ';
      status = 'Không có dữ liệu';
    } else if (!attendance.hasCheckedOut) {
      icon = Icons.login_rounded;
      title = 'Check In';
      status = 'Đang làm việc';
    } else {
      icon = Icons.logout_rounded;
      title = 'Check Out';
      status = 'Hoàn thành';
    }

    return ActivityItem(
      icon: icon,
      title: title,
      date: _formatDate(attendance.date),
      time: attendance.checkInTimeFormatted,
      status: status,
    );
  }

  /// Build empty state khi không có activity
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          const Text(
            'Chưa có hoạt động',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  /// Định dạng ngày thành chuỗi dễ đọc
  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
