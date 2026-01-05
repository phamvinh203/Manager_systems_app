import 'package:flutter/material.dart';
import 'package:mobile/models/employee_model.dart';
import 'package:mobile/utils/employee_helpers.dart';

class EmployeeItem extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onTap;
  final VoidCallback? onMenuPressed;

  const EmployeeItem({
    super.key,
    required this.employee,
    this.onTap,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Get initials from first and last name
    final String initials = '${employee.firstName[0]}${employee.lastName[0]}'.toUpperCase();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Avatar with initials
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EmployeeHelpers.getAvatarColor(employee.department),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name, Email & Position
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
                    employee.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${employee.position} • ${employee.department}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
            ),

            // Status badge
            StatusBadge(status: employee.status),

            const SizedBox(width: 8),

            // Menu icon
            GestureDetector(
              onTap: onMenuPressed,
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}