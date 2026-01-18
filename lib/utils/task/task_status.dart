import 'package:flutter/material.dart';

/// Mapping với enum TaskStatus trong DB
/// TODO | IN_PROGRESS | REVIEW | DONE | CANCELLED
enum TaskStatus { todo, inProgress, review, done, cancelled }

extension TaskStatusX on TaskStatus {
  /// Parse từ API (DB enum)
  static TaskStatus fromApi(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.replaceAll('_', ''),
      orElse: () => TaskStatus.todo,
    );
  }

  /// Gửi ngược lại API
  String get toApi {
    switch (this) {
      case TaskStatus.todo:
        return 'TODO';
      case TaskStatus.inProgress:
        return 'IN_PROGRESS';
      case TaskStatus.review:
        return 'REVIEW';
      case TaskStatus.done:
        return 'DONE';
      case TaskStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Label hiển thị (UI)
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'Chưa làm';
      case TaskStatus.inProgress:
        return 'Đang làm';
      case TaskStatus.review:
        return 'Chờ duyệt';
      case TaskStatus.done:
        return 'Hoàn thành';
      case TaskStatus.cancelled:
        return 'Đã hủy';
    }
  }

  bool get isDone => this == TaskStatus.done;
  bool get isInProgress => this == TaskStatus.inProgress;
  bool get isReview => this == TaskStatus.review;

  /// Màu chính theo trạng thái
  Color get color {
    switch (this) {
      case TaskStatus.todo:
        return const Color(0xFF828282); // Grey
      case TaskStatus.inProgress:
        return const Color(0xFF2F80ED); // Blue
      case TaskStatus.review:
        return const Color(0xFFF2994A); // Orange
      case TaskStatus.done:
        return const Color(0xFF27AE60); // Green
      case TaskStatus.cancelled:
        return const Color(0xFFEB5757); // Red
    }
  }

  /// Màu nền (nhạt)
  Color get backgroundColor => color.withOpacity(0.1);

  /// Widget chip hiển thị trạng thái (giống LeaveStatus)
  Widget buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
