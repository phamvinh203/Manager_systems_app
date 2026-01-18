import 'package:flutter/material.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/screens/workspace/manager/widgets/manager_task_card_header.dart';
import 'package:mobile/screens/workspace/manager/widgets/manager_task_card_meta.dart';
import 'package:mobile/utils/task/task_priority.dart';
import 'package:mobile/utils/task/task_status.dart';

class ManagerTaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onMore;

  const ManagerTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: _getStatusColor(), width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title + Edit
            ManagerTaskCardHeader(task: task),

            const SizedBox(height: 12),

            // Status and Priority chips
            Row(
              children: [
                task.status.buildStatusChip(),
                const SizedBox(width: 8),
                task.priority.buildPriorityChip(),
              ],
            ),

            const SizedBox(height: 12),

            // Meta: Assignees + Deadline
            ManagerTaskCardMeta(task: task),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    return task.status.color;
  }
}
