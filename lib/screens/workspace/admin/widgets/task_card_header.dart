import 'package:flutter/material.dart';
import 'package:mobile/models/task_model.dart';

class TaskCardHeader extends StatelessWidget {
  final TaskModel task;

  const TaskCardHeader({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final department = task.department;
    final departmentName = department?.name ?? 'Nội bộ';
    // final employeeCount = department?.employeeCount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.business, size: 14, color: Color(0xFF6E7175)),
            const SizedBox(width: 6),
            Text(
              departmentName,
              style: const TextStyle(
                color: Color(0xFF6E7175),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text('•', style: TextStyle(color: Color(0xFFD0D5DD))),
            ),
            const Icon(
              Icons.people_alt_rounded,
              size: 14,
              color: Color(0xFF6E7175),
            ),
            const SizedBox(width: 4),
            Text(
              '${(task.assignees != null && task.assignees!.isNotEmpty) ? task.assignees!.length : (task.assignedCount ?? 0)} nhân sự',
              style: const TextStyle(
                color: Color(0xFF6E7175),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          task.title,
          style: const TextStyle(
            color: Color(0xFF101828),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
