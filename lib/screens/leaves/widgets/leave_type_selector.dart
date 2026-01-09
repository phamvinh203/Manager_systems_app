import 'package:flutter/material.dart';
import 'package:mobile/utils/enum/leave_type.dart';

class LeaveTypeSelector extends StatelessWidget {
  final LeaveType selectedType;
  final ValueChanged<LeaveType> onChanged;

  const LeaveTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: LeaveType.values.map((type) {
        final isSelected = type == selectedType;
        final color = type.color;
        return InkWell(
          onTap: () => onChanged(type),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.15)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type.icon,
                  size: 20,
                  color: isSelected ? color : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  type.label,
                  style: TextStyle(
                    color: isSelected ? color : Colors.grey.shade700,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
