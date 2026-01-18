import 'package:flutter/material.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/screens/widgets/pagination_widget.dart';
import 'package:mobile/screens/workspace/manager/widgets/manager_task_card.dart';

class ManagerTaskListView extends StatelessWidget {
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? emptyMessage;
  final Function(TaskModel)? onTaskTap;
  final Function(TaskModel)? onTaskEdit;
  final int? currentPage;
  final int? totalPages;
  final Function(int)? onPageChanged;

  const ManagerTaskListView({
    super.key,
    required this.tasks,
    this.isLoading = false,
    this.emptyMessage,
    this.onTaskTap,
    this.onTaskEdit,
    this.currentPage,
    this.totalPages,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.task_alt_outlined,
                  size: 40,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage ?? 'Không có công việc nào',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF757575),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Thử thay đổi bộ lọc để xem kết quả khác',
                style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        return ManagerTaskCard(
          task: task,
          onTap: onTaskTap != null ? () => onTaskTap!(task) : null,
          onEdit: onTaskEdit != null ? () => onTaskEdit!(task) : null,
        );
      },
    );
  }
}
