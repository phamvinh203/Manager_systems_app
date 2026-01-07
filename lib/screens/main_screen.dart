import 'package:flutter/material.dart';
import 'package:mobile/screens/attendance/attendance_screen.dart';
import 'package:mobile/screens/employee/employee_screen.dart';
import 'package:mobile/screens/home/home_screen.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/screens/workspace/workspace_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    AttendanceScreen(),
    EmployeeScreen(),
    WorkspaceScreen(),
    ProfileScreen(),
  ];

  final List<Widget> _icons = <Widget>[
    const Icon(Icons.home_rounded),
    const Icon(Icons.calendar_today_outlined),
    const Icon(Icons.groups_rounded),
    Image.asset(
      'assets/images/icon_work.png',
      width: 24,
      height: 24,
      color: const Color(0xFFBDBDBD),
    ),
    const Icon(Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _pages),

      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          heroTag: 'main_fab',
          backgroundColor: const Color(0xFF3B82F6),
          elevation: 4,
          shape: const CircleBorder(),
          onPressed: () {
            setState(() {
              _selectedIndex = 2;
            });
          },
          child: const Icon(
            Icons.groups_rounded,
            size: 26,
            color: Colors.white,
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 8,
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _buildNavItem(0),
                _buildNavItem(1),
                const Spacer(),
                _buildNavItem(3),
                _buildNavItem(4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final bool isSelected = _selectedIndex == index;

    // LẤY ICON
    Widget icon = _icons[index];

    // NẾU LÀ IMAGE → ĐỔI MÀU THEO SELECT
    if (icon is Image && icon.image is AssetImage) {
      final String assetName = (icon.image as AssetImage).assetName;
      icon = Image.asset(
        assetName,
        width: 24,
        height: 24,
        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFBDBDBD),
      );
    } else if (icon is Icon) {
      icon = Icon(
        icon.icon,
        size: 24,
        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFBDBDBD),
      );
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thanh gạch xanh phía trên
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 3,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3B82F6).withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(width: 24, height: 24, child: icon),
            ),
          ],
        ),
      ),
    );
  }
}
