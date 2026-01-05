import 'package:flutter/material.dart';
import 'activity_item.dart';

class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Activity List
        const ActivityItem(
          icon: Icons.login_rounded,
          title: 'Check In',
          date: 'April 17, 2023',
          time: '10:00 am',
          status: 'On Time',
        ),
        const Divider(height: 1),
        const ActivityItem(
          icon: Icons.coffee_rounded,
          title: 'Break In',
          date: 'April 17, 2023',
          time: '12:30 am',
          status: 'On Time',
        ),
      ],
    );
  }
}