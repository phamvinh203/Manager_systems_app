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

  /// Lấy màu nền cho trạng thái
  Color get backgroundColor {
    switch (this) {
      case LeaveStatus.pending:
        return Colors.orange.shade100;
      case LeaveStatus.approved:
        return Colors.green.shade100;
      case LeaveStatus.rejected:
        return Colors.red.shade100;
      case LeaveStatus.cancelled:
        return Colors.grey.shade200;
    }
  }

  /// Lấy màu chữ cho trạng thái
  Color get textColor {
    switch (this) {
      case LeaveStatus.pending:
        return Colors.orange.shade800;
      case LeaveStatus.approved:
        return Colors.green.shade800;
      case LeaveStatus.rejected:
        return Colors.red.shade800;
      case LeaveStatus.cancelled:
        return Colors.grey.shade700;
    }
  }

  /// Widget chip hiển thị trạng thái
  Widget buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
