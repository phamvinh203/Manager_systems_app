import 'package:flutter/material.dart';
import 'stat_item_card.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today Attendance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        
        // Grid 2x2
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: const [
            StatItemCard(
              icon: Icons.login_rounded,
              iconColor: Color(0xFF3B82F6),
              title: 'Check In',
              value: '10:20 am',
              subtitle: 'On Time',
            ),
            StatItemCard(
              icon: Icons.logout_rounded,
              iconColor: Color(0xFF3B82F6),
              title: 'Check Out',
              value: '07:00 pm',
              subtitle: 'Go Home',
            ),
            StatItemCard(
              icon: Icons.coffee_rounded,
              iconColor: Color(0xFFF59E0B),
              title: 'Break Time',
              value: '00:30 min',
              subtitle: 'Avg Time 30 min',
            ),
            StatItemCard(
              icon: Icons.calendar_month_rounded,
              iconColor: Color(0xFF3B82F6),
              title: 'Total Days',
              value: '28',
              subtitle: 'Working Days',
            ),
          ],
        ),
      ],
    );
  }
}