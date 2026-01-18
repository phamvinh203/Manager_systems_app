import 'package:flutter/material.dart';

class TaskCardActions extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCardActions({super.key, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          GestureDetector(
            onTap: onEdit,
            child: const Icon(Icons.edit, size: 20, color: Color(0xFF9EA5AD)),
          ),
        if (onEdit != null && onDelete != null) const SizedBox(width: 16),
        if (onDelete != null)
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: Color(0xFF9EA5AD),
            ),
          ),
      ],
    );
  }
}
