import 'package:flutter/material.dart';

/// Mapping với enum TaskType trong DB
/// GENERAL | REPORT | TRAINING | MEETING | SYSTEM
enum TaskType {
  general,
  report,
  training,
  meeting,
  system,
}

extension TaskTypeX on TaskType {
  /// Parse từ API (DB enum)
  static TaskType fromApi(String value) {
    return TaskType.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => TaskType.general,
    );
  }

  /// Gửi ngược lại API
  String get toApi => name.toUpperCase();

  /// Label hiển thị (UI)
  String get label {
    switch (this) {
      case TaskType.general:
        return 'Công việc chung';
      case TaskType.report:
        return 'Báo cáo';
      case TaskType.training:
        return 'Đào tạo';
      case TaskType.meeting:
        return 'Họp';
      case TaskType.system:
        return 'Hệ thống';
    }
  }

  /// Icon tương ứng
  IconData get icon {
    switch (this) {
      case TaskType.general:
        return Icons.task_alt_rounded;
      case TaskType.report:
        return Icons.bar_chart_rounded;
      case TaskType.training:
        return Icons.school_rounded;
      case TaskType.meeting:
        return Icons.groups_rounded;
      case TaskType.system:
        return Icons.settings_rounded;
    }
  }

  /// Màu chính
  Color get color {
    switch (this) {
      case TaskType.general:
        return const Color(0xFF2F80ED); // Blue
      case TaskType.report:
        return const Color(0xFF9B51E0); // Purple
      case TaskType.training:
        return const Color(0xFF27AE60); // Green
      case TaskType.meeting:
        return const Color(0xFFF2994A); // Orange
      case TaskType.system:
        return const Color(0xFFEB5757); // Red
    }
  }

  /// Widget icon container 
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
