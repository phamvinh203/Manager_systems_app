import 'package:flutter/material.dart';

// Constants for dropdown lists (chỉ giữ statuses vì departments và positions lấy từ API)
class EmployeeConstants {
  static const List<String> statuses = ['ACTIVE', 'INACTIVE', 'ON_LEAVE'];
}

class EmployeeHelpers {
  /// Lấy màu avatar dựa trên tên department
  static Color getAvatarColor(String? departmentName) {
    if (departmentName == null || departmentName.isEmpty) {
      return const Color(0xFF64748B);
    }

    final colors = {
      'IT': const Color(0xFF3B82F6),
      'HR': const Color(0xFFEC4899),
      'Finance': const Color(0xFF10B981),
      'Marketing': const Color(0xFFF59E0B),
      'Sales': const Color(0xFF8B5CF6),
      'Operations': const Color(0xFFEF4444),
    };
    return colors[departmentName] ?? const Color(0xFF64748B);
  }

  static String getInitials(String firstName, String lastName) {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        break;
      case 'inactive':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        break;
      case 'on_leave':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
