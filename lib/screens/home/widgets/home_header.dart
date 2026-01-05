import 'package:flutter/material.dart';
import 'package:mobile/models/employee_model.dart';
import 'package:mobile/utils/employee_helpers.dart';

class HomeHeader extends StatelessWidget {
  final Employee employee;

  const HomeHeader({super.key, required this.employee});

  static const Color darkText = Color(0xFF1E293B);
  static const Color grayText = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: EmployeeHelpers.getAvatarColor(employee.department),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
          ),
        ),
        const SizedBox(width: 12),

        // Name & Role
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 2),
              Text(
                '${employee.position} • ${employee.department}',
                style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
              ),
            ],
          ),
        ),

        // Notification Icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
