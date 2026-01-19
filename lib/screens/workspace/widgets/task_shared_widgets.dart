import 'package:flutter/material.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/utils/task/task_priority.dart';
import 'package:mobile/utils/task/task_status.dart';
import 'package:mobile/utils/formatters.dart';
import 'package:mobile/utils/employee_helpers.dart';

class TaskHeaderCard extends StatelessWidget {
  final TaskModel task;

  const TaskHeaderCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF2F80ED),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusBadge(status: task.status),
                    const SizedBox(width: 8),
                    PriorityBadge(priority: task.priority),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D2939),
                  ),
                ),
                if (task.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Text(
                    task.description!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Hạn chót: ${Formatters.formatDateVN(task.dueDate ?? DateTime.now())}',
                        ),
                      ],
                    ),
                    AvatarStack(assignees: task.assignees ?? []),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ===== BADGES ===== */

class StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = priority.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(priority.icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            'Ưu tiên ${priority.label.toLowerCase()}',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/* ===== AVATAR STACK ===== */

class AvatarStack extends StatelessWidget {
  final List<TaskAssigneeModel> assignees;
  final int maxVisible;

  const AvatarStack({super.key, required this.assignees, this.maxVisible = 3});

  @override
  Widget build(BuildContext context) {
    if (assignees.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 24,
      child: Row(
        children: assignees.take(maxVisible).map((e) {
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: 11,
              backgroundColor: EmployeeHelpers.getAvatarColor(e.fullName),
              child: Text(
                EmployeeHelpers.getNameInitials(e.fullName),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
