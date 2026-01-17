import 'package:flutter/material.dart';

enum LeaveType { annual, sick, unpaid, wfh, other }

extension LeaveTypeX on LeaveType {
  /// Parse từ API (DB enum)
  static LeaveType fromApi(String value) {
    return LeaveType.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => LeaveType.other,
    );
  }

  /// Gửi ngược lại API
  String get toApi => name.toUpperCase();

  String get label {
    switch (this) {
      case LeaveType.annual:
        return 'Nghỉ phép năm';
      case LeaveType.sick:
        return 'Nghỉ ốm';
      case LeaveType.unpaid:
        return 'Nghỉ không lương';
      case LeaveType.wfh:
        return 'Làm việc tại nhà';
      case LeaveType.other:
        return 'Khác';
    }
  }

  /// Lấy icon tương ứng với loại nghỉ phép
  IconData get icon {
    switch (this) {
      case LeaveType.annual:
        return Icons.calendar_today_rounded;
      case LeaveType.sick:
        return Icons.medical_services_rounded;
      case LeaveType.unpaid:
        return Icons.event_busy_rounded;
      case LeaveType.wfh:
        return Icons.home_work_rounded;
      case LeaveType.other:
        return Icons.more_time_rounded;
    }
  }

  /// Lấy màu tương ứng với loại nghỉ phép
  Color get color {
    switch (this) {
      case LeaveType.annual:
        return const Color(0xFF2F80ED);
      case LeaveType.sick:
        return const Color(0xFFEB5757);
      case LeaveType.unpaid:
        return const Color(0xFFF2994A);
      case LeaveType.wfh:
        return const Color(0xFF27AE60);
      case LeaveType.other:
        return const Color(0xFF828282);
    }
  }

  /// Widget icon container với background màu (theo ảnh)
  Widget buildIconContainer({double size = 24}) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}
