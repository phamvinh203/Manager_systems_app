import 'package:flutter/material.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/utils/formatters.dart';
import 'package:mobile/utils/employee_helpers.dart';

class ManagerTaskCardMeta extends StatelessWidget {
  final TaskModel task;

  const ManagerTaskCardMeta({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Avatar Stack (Assignees)
            _buildAvatarStack(),

            // Deadline info
            if (task.dueDate != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getDeadlineIcon(),
                    size: 16,
                    color: _getDeadlineColor(),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getDeadlineText(),
                    style: TextStyle(
                      fontSize: 13,
                      color: _getDeadlineColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),

        if (task.status.name == 'done') ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                size: 16,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(width: 6),
              const Text(
                'Đã hoàn thành',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAvatarStack() {
    final assignees = task.assignees ?? [];
    const maxVisible = 3;
    final displayCount = assignees.length > maxVisible
        ? maxVisible
        : assignees.length;
    final remaining = assignees.length - maxVisible;

    if (assignees.isEmpty) {
      if (task.assignedCount != null && task.assignedCount! > 0) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '+${task.assignedCount}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    final totalCircles = displayCount + (remaining > 0 ? 1 : 0);
    final width = totalCircles > 0 ? ((totalCircles - 1) * 18.0 + 24.0) : 0.0;

    return SizedBox(
      height: 28,
      width: width,
      child: Stack(
        children: [
          ...List.generate(displayCount, (index) {
            return Positioned(
              left: index * 18.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: EmployeeHelpers.getAvatarColor(
                    assignees[index].fullName,
                  ),
                  child: Text(
                    EmployeeHelpers.getNameInitials(assignees[index].fullName),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
          if (remaining > 0)
            Positioned(
              left: displayCount * 18.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFFEAECF0),
                  child: Text(
                    '+$remaining',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF475467),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getDeadlineIcon() {
    if (task.status.name == 'done') return Icons.check_circle;

    final now = DateTime.now();
    final dueDate = task.dueDate!;
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) return Icons.error;
    if (difference <= 1) return Icons.access_time;
    return Icons.calendar_today;
  }

  Color _getDeadlineColor() {
    if (task.status.name == 'done') return const Color(0xFF4CAF50);

    final now = DateTime.now();
    final dueDate = task.dueDate!;
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) return const Color(0xFFEB5757);
    if (difference <= 1) return const Color(0xFFF2994A);
    return const Color(0xFF757575);
  }

  String _getDeadlineText() {
    if (task.status.name == 'done') {
      return 'Hoàn thành';
    }

    final now = DateTime.now();
    final dueDate = task.dueDate!;
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return 'Quá hạn ${Formatters.formatDateVN(dueDate)}';
    } else if (difference == 0) {
      return 'Hôm nay';
    } else if (difference == 1) {
      return 'Ngày mai';
    } else if (difference <= 7) {
      return 'Còn $difference ngày';
    } else {
      return Formatters.formatDateVN(dueDate);
    }
  }
}
