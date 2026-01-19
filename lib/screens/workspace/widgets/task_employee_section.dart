import 'package:flutter/material.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/utils/employee_helpers.dart';

class TaskEmployeeSection extends StatelessWidget {
  final List<TaskAssigneeModel> assignees;
  final VoidCallback onAddEmployee;

  const TaskEmployeeSection({
    super.key,
    required this.assignees,
    required this.onAddEmployee,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Danh sách nhân viên',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              TextButton.icon(
                onPressed: onAddEmployee,
                icon: const Icon(Icons.add_circle),
                label: const Text('Thêm nhân viên'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (assignees.isEmpty)
            const Center(child: Text('Chưa có nhân viên nào'))
          else
            ...assignees.map((e) => EmployeeCard(assignee: e)),
        ],
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final TaskAssigneeModel assignee;

  const EmployeeCard({super.key, required this.assignee});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: EmployeeHelpers.getAvatarColor(assignee.fullName),
                child: Text(
                  EmployeeHelpers.getNameInitials(assignee.fullName),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  assignee.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text('${assignee.progress}%'),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: assignee.progress / 100),
        ],
      ),
    );
  }
}
