import 'package:flutter/material.dart';
import 'package:mobile/screens/notification/notification_screen.dart';
import 'package:mobile/screens/notification/widgets/notification_buttom_sheet.dart';
import 'package:mobile/utils/employee_helpers.dart';

class HomeHeader extends StatelessWidget {
  final String fullName;
  final String position;
  final String department;

  const HomeHeader({
    super.key,
    required this.fullName,
    required this.position,
    required this.department,
  });

  static const Color darkText = Color(0xFF1E293B);
  static const Color grayText = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar with initials
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: EmployeeHelpers.getAvatarColor(fullName),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
          ),
          child: Center(
            child: Text(
              EmployeeHelpers.getInitials(
                fullName.split(' ').first,
                fullName.split(' ').last,
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Name & Role
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 2),
              Text(
                '$position • $department',
                style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
              ),
            ],
          ),
        ),

        // Notification Icon
        GestureDetector(
          onTap: () {
            _openNotificationPopup(context);
          },
          child: Container(
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
        ),
      ],
    );
  }

  void _openNotificationPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return NotificationBottomSheet(
          builder: (controller) =>
              NotificationScreen(scrollController: controller),
        );
      },
    );
  }
}
