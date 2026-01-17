import 'package:flutter/material.dart';

class Tabmanager extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const Tabmanager({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab(
            label: 'Yêu cầu của nhóm',
            index: 0,
            isSelected: currentIndex == 0,
          ),
          _buildTab(
            label: 'Đơn nghỉ của tôi',
            index: 1,
            isSelected: currentIndex == 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF2F80ED)
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
