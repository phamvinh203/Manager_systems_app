import 'package:flutter/material.dart';

/// Mapping với enum TaskPriority trong DB
/// LOW | MEDIUM | HIGH | URGENT
enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

extension TaskPriorityX on TaskPriority {
  /// Parse từ API (DB enum)
  static TaskPriority fromApi(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => TaskPriority.medium,
    );
  }

  /// Gửi ngược lại API
  String get toApi => name.toUpperCase();

  /// Label hiển thị (UI)
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Thấp';
      case TaskPriority.medium:
        return 'Trung bình';
      case TaskPriority.high:
        return 'Cao';
      case TaskPriority.urgent:
        return 'Khẩn cấp';
    }
  }

  /// Icon theo mức độ ưu tiên
  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
      case TaskPriority.urgent:
        return Icons.priority_high_rounded;
    }
  }

  /// Màu chính
  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF27AE60); // Green
      case TaskPriority.medium:
        return const Color(0xFF2F80ED); // Blue
      case TaskPriority.high:
        return const Color(0xFFF2994A); // Orange
      case TaskPriority.urgent:
        return const Color(0xFFEB5757); // Red
    }
  }

  /// Badge / Chip hiển thị độ ưu tiên
  Widget buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
