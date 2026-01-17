import 'package:flutter/material.dart';

enum LeaveStatus { pending, approved, rejected, cancelled }

extension LeaveStatusX on LeaveStatus {
  /// Parse từ API (DB enum)
  static LeaveStatus fromApi(String value) {
    return LeaveStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => LeaveStatus.pending,
    );
  }

  /// Gửi lên backend
  String get toApi => name.toUpperCase();

  String get label {
    switch (this) {
      case LeaveStatus.pending:
        return 'Chờ duyệt';
      case LeaveStatus.approved:
        return 'Đã duyệt';
      case LeaveStatus.rejected:
        return 'Từ chối';
      case LeaveStatus.cancelled:
        return 'Đã hủy';
    }
  }

  bool get isPending => this == LeaveStatus.pending;

  /// Lấy màu chính cho trạng thái
  Color get color {
    switch (this) {
      case LeaveStatus.pending:
        return const Color(0xFFF2994A); // Orange
      case LeaveStatus.approved:
        return const Color(0xFF2F80ED); // Blue (matches image)
      case LeaveStatus.rejected:
        return const Color(0xFFEB5757); // Red
      case LeaveStatus.cancelled:
        return const Color(0xFF828282); // Grey
    }
  }

  /// Lấy màu nền (nhạt) cho trạng thái
  Color get backgroundColor => color.withOpacity(0.1);

  /// Lấy màu chữ
  Color get textColor => color;

  /// Widget chip hiển thị trạng thái (Solid theo ảnh)
  Widget buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label, // Dùng label để hiển thị tiếng Việt
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
