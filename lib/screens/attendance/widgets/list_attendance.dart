import 'package:flutter/material.dart';
import 'package:mobile/models/attendance_model.dart';

/// Widget hiển thị danh sách attendance
/// Chỉ tập trung render UI, không gọi API trực tiếp
class ListAttendance extends StatelessWidget {
  final List<AttendanceModel> attendances;
  final VoidCallback? onRefresh;

  const ListAttendance({
    super.key,
    required this.attendances,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Empty state
    if (attendances.isEmpty) {
      return _buildEmptyState();
    }

    // Convert attendances thành timeline records
    final records = _convertToRecords(attendances);

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: records.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return AttendanceRecordItem(
          record: records[index],
          showDate: _shouldShowDate(records, index),
        );
      },
    );
  }

  /// Convert list AttendanceModel thành list AttendanceRecord
  /// Mỗi attendance có thể tạo ra 1-2 records (check-in và check-out)
  List<AttendanceRecord> _convertToRecords(List<AttendanceModel> attendances) {
    final List<AttendanceRecord> records = [];

    for (final attendance in attendances) {
      // Thêm record Check-in
      if (attendance.hasCheckedIn) {
        records.add(AttendanceRecord(
          type: RecordType.checkIn,
          date: attendance.date,
          time: attendance.checkIn!,
          attendance: attendance,
        ));
      }

      // Thêm record Check-out
      if (attendance.hasCheckedOut) {
        records.add(AttendanceRecord(
          type: RecordType.checkOut,
          date: attendance.date,
          time: attendance.checkOut!,
          attendance: attendance,
        ));
      }
    }

    // Sắp xếp theo thời gian giảm dần (mới nhất lên đầu)
    records.sort((a, b) => b.time.compareTo(a.time));

    return records;
  }

  /// Kiểm tra có nên hiển thị date header không
  /// Chỉ hiển thị khi record đầu tiên hoặc khi đổi ngày
  bool _shouldShowDate(List<AttendanceRecord> records, int index) {
    if (index == 0) return true;

    final currentDate = DateTime(
      records[index].date.year,
      records[index].date.month,
      records[index].date.day,
    );

    final previousDate = DateTime(
      records[index - 1].date.year,
      records[index - 1].date.month,
      records[index - 1].date.day,
    );

    return currentDate != previousDate;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_outlined,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không có dữ liệu chấm công',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chưa có bản ghi nào trong khoảng thời gian này',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget hiển thị một record check-in/check-out
class AttendanceRecordItem extends StatelessWidget {
  final AttendanceRecord record;
  final bool showDate;

  const AttendanceRecordItem({
    super.key,
    required this.record,
    required this.showDate,
  });

  @override
  Widget build(BuildContext context) {
    final isCheckIn = record.type == RecordType.checkIn;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header (chỉ hiển thị khi cần)
          if (showDate) ...[
            _buildDateHeader(),
            const SizedBox(height: 12),
          ],

          // Record content
          Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCheckIn
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
                  color: isCheckIn
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCheckIn ? 'Check In' : 'Check Out',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(record.time),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isCheckIn
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),

              // Total hours nếu là check-out
              if (!isCheckIn && record.attendance.totalHours != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 14,
                        color: Color(0xFF3B82F6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        record.attendance.totalHoursFormatted,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    return Row(
      children: [
        Container(
          height: 4,
          width: 4,
          decoration: const BoxDecoration(
            color: Color(0xFF3B82F6),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatDate(record.date),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3B82F6),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final attendanceDate = DateTime(date.year, date.month, date.day);

    if (attendanceDate == today) {
      return 'Hôm nay, ${date.day}/${date.month}/${date.year}';
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (attendanceDate == yesterday) {
      return 'Hôm qua, ${date.day}/${date.month}/${date.year}';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Model cho một record check-in hoặc check-out
class AttendanceRecord {
  final RecordType type;
  final DateTime date;
  final DateTime time;
  final AttendanceModel attendance;

  AttendanceRecord({
    required this.type,
    required this.date,
    required this.time,
    required this.attendance,
  });
}

/// Enum loại record
enum RecordType {
  checkIn,
  checkOut,
}
