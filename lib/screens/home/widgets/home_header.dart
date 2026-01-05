import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

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
            border: Border.all(color: const Color(0xFF3B82F6), width: 2),
            image: const DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/150?img=8'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Name & Role
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Michael Mitc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              Text(
                'Lead UI/UX Designer',
                style: TextStyle(
                  fontSize: 14,
                  color: grayText,
                ),
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