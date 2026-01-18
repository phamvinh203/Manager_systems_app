import 'package:flutter/material.dart';
import 'package:mobile/models/task_model.dart';

class ManagerTaskCardHeader extends StatelessWidget {
  final TaskModel task;

  const ManagerTaskCardHeader({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task Title
        Expanded(
          child: Text(
            task.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(width: 8),

        // Edit button
        GestureDetector(
          onTap: () {
            // Handle edit
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            child: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ),
      ],
    );
  }
}
