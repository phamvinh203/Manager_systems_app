import 'package:flutter/material.dart';

/// DateSelector - Hiển thị danh sách ngày để chọn
class DateSelector extends StatefulWidget {
  const DateSelector({super.key});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late int _selectedIndex;
  late List<DateItem> _dates;

  @override
  void initState() {
    super.initState();
    _initDates();
  }

  /// Khởi tạo danh sách 7 ngày tính từ hôm nay
  void _initDates() {
    _dates = [];
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      _dates.add(DateItem(
        day: date.day.toString().padLeft(2, '0'),
        label: _getDayLabel(date.weekday),
        fullDate: date,
      ));
    }

    // Mặc định chọn ngày hôm nay (index 0)
    _selectedIndex = 0;
  }

  /// Lấy nhãn ngày từ tuần (1 = Monday, 7 = Sunday)
  String _getDayLabel(int weekday) {
    const labels = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    return labels[weekday] ?? 'Sun';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          final dateItem = _dates[index];

          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateItem.day,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateItem.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white70
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Model cho một ngày trong date selector
class DateItem {
  final String day;
  final String label;
  final DateTime fullDate;

  DateItem({
    required this.day,
    required this.label,
    required this.fullDate,
  });
}
