import 'package:flutter/material.dart';

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

    if (colors.containsKey(departmentName)) {
      return colors[departmentName]!;
    }

    // Generate a deterministic "random" color from a palette
    final List<Color> palette = [
      const Color(0xFF6366F1), 
      const Color(0xFF8B5CF6), 
      const Color(0xFFD946EF), 
      const Color(0xFFF43F5E), 
      const Color(0xFFF97316), 
      const Color(0xFFEAB308), 
      const Color(0xFF22C55E), 
      const Color(0xFF06B6D4), 
      const Color(0xFF3B82F6), 
      const Color(0xFF64748B), 
    ];

    return palette[departmentName.hashCode.abs() % palette.length];
  }

  static String getInitials(String firstName, String lastName) {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  static String getNameInitials(String fullName) {
    if (fullName.isEmpty) return 'U';
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return getInitials(parts.first, parts.last);
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
