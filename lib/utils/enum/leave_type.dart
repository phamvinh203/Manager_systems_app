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
        return Icons.beach_access;
      case LeaveType.sick:
        return Icons.local_hospital;
      case LeaveType.unpaid:
        return Icons.money_off;
      case LeaveType.wfh:
        return Icons.home_work;
      case LeaveType.other:
        return Icons.more_horiz;
    }
  }

  /// Lấy màu tương ứng với loại nghỉ phép
  Color get color {
    switch (this) {
      case LeaveType.annual:
        return Colors.blue;
      case LeaveType.sick:
        return Colors.red;
      case LeaveType.unpaid:
        return Colors.orange;
      case LeaveType.wfh:
        return Colors.green;
      case LeaveType.other:
        return Colors.grey;
    }
  }

  /// Widget icon container với background màu
  Widget buildIconContainer({double size = 20}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}
