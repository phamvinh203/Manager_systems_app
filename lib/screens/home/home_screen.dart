import 'package:flutter/material.dart';
import 'widgets/home_header.dart';
import 'widgets/date_selector.dart';
import 'widgets/attendance_card.dart';
import 'widgets/activity_section.dart';
import 'widgets/swipe_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isCheckedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    HomeHeader(),
                    SizedBox(height: 24),
                    DateSelector(),
                    SizedBox(height: 24),
                    AttendanceCard(),
                    SizedBox(height: 24),
                    ActivitySection(),
                    SizedBox(height: 100), // Space for swipe button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Swipe button ở dưới cùng
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: _isCheckedIn
            ? SwipeActionButton.checkOut(
                onSwipeComplete: () {
                  setState(() => _isCheckedIn = false);
                  _showSnackBar('Checked Out Successfully!');
                },
              )
            : SwipeActionButton.checkIn(
                onSwipeComplete: () {
                  setState(() => _isCheckedIn = true);
                  _showSnackBar('Checked In Successfully!');
                },
              ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}