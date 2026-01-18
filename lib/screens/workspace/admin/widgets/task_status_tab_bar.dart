import 'package:flutter/material.dart';
import 'package:mobile/utils/task/task_status.dart';

class TaskStatusTabBar extends StatelessWidget {
  final TaskStatus? selectedStatus;
  final ValueChanged<TaskStatus?> onStatusChanged;

  const TaskStatusTabBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(
            label: 'Tất cả',
            selected: selectedStatus == null,
            onTap: () => onStatusChanged(null),
          ),
          ...TaskStatus.values.map(
            (status) => _buildChip(
              label: status.label,
              selected: selectedStatus == status,
              onTap: () => onStatusChanged(status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0B79D0) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? const Color(0xFF0B79D0) : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
