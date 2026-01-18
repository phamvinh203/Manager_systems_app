import 'package:flutter/material.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/screens/widgets/pagination_widget.dart';
import 'package:mobile/screens/workspace/admin/widgets/task_card.dart';

class TaskListView extends StatelessWidget {
  final List<TaskModel> tasks;
  final Function(TaskModel task)? onTaskTap;
  final Function(TaskModel task)? onTaskEdit;
  final Function(TaskModel task)? onTaskDelete;
  final bool isLoading;
  final String? emptyMessage;
  final int? currentPage;
  final int? totalPages;
  final Function(int)? onPageChanged;

  const TaskListView({
    super.key,
    required this.tasks,
    this.onTaskTap,
    this.onTaskEdit,
    this.onTaskDelete,
    this.isLoading = false,
    this.emptyMessage,
    this.currentPage,
    this.totalPages,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'Không có công việc nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tasks.length + (totalPages != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == tasks.length) {
          return PaginationWidget(
            currentPage: currentPage ?? 1,
            totalPages: totalPages ?? 1,
            onPageChanged: onPageChanged ?? (_) {},
          );
        }
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: onTaskTap != null ? () => onTaskTap?.call(task) : null,
          onEdit: onTaskEdit != null ? () => onTaskEdit?.call(task) : null,
          onDelete: onTaskDelete != null
              ? () => onTaskDelete?.call(task)
              : null,
        );
      },
    );
  }
}
