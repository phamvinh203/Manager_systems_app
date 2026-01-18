import 'package:flutter/material.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/utils/formatters.dart';
import 'package:mobile/utils/task/task_priority.dart';
import 'package:mobile/utils/task/task_status.dart';
import 'package:mobile/utils/task/task_type.dart';

class TaskDetailPage extends StatelessWidget {
  final TaskModel task;

  const TaskDetailPage({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết công việc',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF2F80ED)),
            onPressed: () {
              // Navigate to edit task
              Navigator.pop(context, 'edit');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            _buildSection(
              title: 'Tiêu đề',
              content: Text(
                task.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mô tả
            if (task.description != null && task.description!.isNotEmpty)
              _buildSection(
                title: 'Mô tả',
                content: Text(
                  task.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ),
            if (task.description != null && task.description!.isNotEmpty)
              const SizedBox(height: 16),

            // Phòng ban
            _buildSection(
              title: 'Phòng ban',
              content: Row(
                children: [
                  const Icon(Icons.business, size: 16, color: Color(0xFF9E9E9E)),
                  const SizedBox(width: 8),
                  Text(
                    task.department?.name ?? 'Nội bộ',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Loại công việc
            _buildSection(
              title: 'Loại công việc',
              content: Row(
                children: [
                  Icon(task.type.icon, size: 16, color: task.type.color),
                  const SizedBox(width: 8),
                  Text(
                    task.type.label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mức độ ưu tiên
            _buildSection(
              title: 'Mức độ ưu tiên',
              content: Row(
                children: [
                  Icon(task.priority.icon, size: 16, color: task.priority.color),
                  const SizedBox(width: 8),
                  Text(
                    task.priority.label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Trạng thái
            _buildSection(
              title: 'Trạng thái',
              content: task.status.buildStatusChip(),
            ),
            const SizedBox(height: 16),

            // Ngày bắt đầu
            if (task.startDate != null)
              _buildSection(
                title: 'Ngày bắt đầu',
                content: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(task.startDate!),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            if (task.startDate != null)
              const SizedBox(height: 16),

            // Ngày hết hạn
            if (task.dueDate != null)
              _buildSection(
                title: 'Ngày hết hạn',
                content: Row(
                  children: [
                    const Icon(Icons.event, size: 16, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(task.dueDate!),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            if (task.dueDate != null)
              const SizedBox(height: 16),

            // Thời gian tạo
            _buildSection(
              title: 'Ngày tạo',
              content: Text(
                _formatDateTime(task.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Thời gian cập nhật
            _buildSection(
              title: 'Cập nhật lần cuối',
              content: Text(
                _formatDateTime(task.updatedAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return Formatters.formatDateVN(date);
  }

  String _formatDateTime(DateTime dateTime) {
    return Formatters.formatDateTimeVN(dateTime);
  }
}
