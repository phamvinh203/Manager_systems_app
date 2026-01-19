import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/task/task_bloc.dart';
import 'package:mobile/blocs/task/task_event.dart';
import 'package:mobile/blocs/task/task_state.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/screens/workspace/manager/widgets/add_employee_task.dart';
import 'package:mobile/utils/task/task_priority.dart';
import 'package:mobile/utils/task/task_status.dart';
import 'package:mobile/utils/formatters.dart';
import 'package:mobile/utils/employee_helpers.dart';

class TaskDetailPage extends StatefulWidget {
  final int taskId;
  final TaskModel? initialTask; // Optional: để hiển thị ngay nếu có

  const TaskDetailPage({
    super.key,
    required this.taskId,
    this.initialTask,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load task detail và assignees
    _loadTaskDetail();
  }

  void _loadTaskDetail() {
    context.read<TaskBloc>().add(
          LoadTaskDetailEvent(
            taskId: widget.taskId,
            forceRefresh: widget.initialTask == null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: BlocBuilder<TaskBloc, TaskState>(
        buildWhen: (prev, curr) =>
            prev.currentTask != curr.currentTask ||
            prev.status != curr.status ||
            prev.assignees != curr.assignees,
        builder: (context, state) {
          // Ưu tiên hiển thị currentTask từ state, fallback về initialTask
          final task = state.currentTask ?? widget.initialTask;

          if (task == null) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.isError) {
              return _buildErrorState(state.errorMessage);
            }
            return const Center(child: Text('Không tìm thấy công việc'));
          }

          return RefreshIndicator(
            onRefresh: () async => _loadTaskDetail(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TaskHeaderCard(task: task),
                  const SizedBox(height: 24),
                  _EmployeeSection(
                    task: task,
                    // Dùng assignees từ state nếu có (mới hơn)
                    assignees: state.assignees ?? task.assignees ?? [],
                    onAddEmployee: () => _navigateToAddEmployee(task),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: Color(0xFF333333),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Chi tiết công việc',
        style: TextStyle(
          color: Color(0xFF1D2939),
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, color: Color(0xFF333333)),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
            const PopupMenuItem(value: 'delete', child: Text('Xóa')),
          ],
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit screen
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa công việc?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TaskBloc>().add(DeleteTaskEvent(taskId: widget.taskId));
              Navigator.pop(context); // Pop detail page
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message ?? 'Đã xảy ra lỗi',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadTaskDetail,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddEmployee(TaskModel task) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => AddEmployeeTask(task: task)),
    );

    // Refresh nếu có thay đổi
    if (result == true && mounted) {
      _loadTaskDetail();
    }
  }
}

// ============ EXTRACTED WIDGETS ============

/// Card hiển thị thông tin chính của task
class _TaskHeaderCard extends StatelessWidget {
  final TaskModel task;

  const _TaskHeaderCard({required this.task});

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
          // Blue top bar
          Container(
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF2F80ED),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status & Priority badges
                Row(
                  children: [
                    _StatusBadge(status: task.status),
                    const SizedBox(width: 8),
                    _PriorityBadge(priority: task.priority),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D2939),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                if (task.description?.isNotEmpty == true)
                  Text(
                    task.description!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF667085),
                      height: 1.5,
                    ),
                  ),

                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFEAECF0)),
                const SizedBox(height: 20),

                // Due date & Avatars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: Color(0xFF2F80ED),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hạn chót: ${Formatters.formatDateVN(task.dueDate ?? DateTime.now())}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                    _AvatarStack(assignees: task.assignees ?? []),
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

/// Badge hiển thị status
class _StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge hiển thị priority
class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = priority.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            'Ưu tiên ${priority.label.toLowerCase()}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stack avatar của assignees
class _AvatarStack extends StatelessWidget {
  final List<TaskAssigneeModel> assignees;
  final int maxVisible;

  const _AvatarStack({
    required this.assignees,
    this.maxVisible = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (assignees.isEmpty) return const SizedBox.shrink();

    final displayCount = assignees.length > maxVisible ? maxVisible : assignees.length;
    final remaining = assignees.length - maxVisible;
    final totalCircles = displayCount + (remaining > 0 ? 1 : 0);
    final width = (totalCircles - 1) * 16.0 + 24.0;

    return SizedBox(
      height: 24,
      width: width,
      child: Stack(
        children: [
          ...List.generate(displayCount, (index) {
            return Positioned(
              left: index * 16.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 11,
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
              left: displayCount * 16.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 11,
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
}

/// Section hiển thị danh sách nhân viên được gán
class _EmployeeSection extends StatelessWidget {
  final TaskModel task;
  final List<TaskAssigneeModel> assignees;
  final VoidCallback onAddEmployee;

  const _EmployeeSection({
    required this.task,
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Danh sách nhân viên',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D2939),
                ),
              ),
              TextButton.icon(
                onPressed: onAddEmployee,
                icon: const Icon(
                  Icons.add_circle,
                  size: 20,
                  color: Color(0xFF2F80ED),
                ),
                label: const Text(
                  'Thêm nhân viên',
                  style: TextStyle(
                    color: Color(0xFF2F80ED),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // List
          if (assignees.isEmpty)
            _buildEmptyState()
          else
            ...assignees.map((assignee) => _EmployeeCard(assignee: assignee)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Chưa có nhân viên nào được gán',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card hiển thị thông tin 1 nhân viên được gán
class _EmployeeCard extends StatelessWidget {
  final TaskAssigneeModel assignee;

  const _EmployeeCard({required this.assignee});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F4F7)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with online indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: EmployeeHelpers.getAvatarColor(
                      assignee.fullName,
                    ),
                    child: Text(
                      EmployeeHelpers.getNameInitials(assignee.fullName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Name & Position
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignee.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF101828),
                      ),
                    ),
                    Text(
                      assignee.position?.name ?? 'Nhân viên',
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Progress percentage
              Text(
                '${assignee.progress}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF2F80ED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: assignee.progress / 100,
              backgroundColor: const Color(0xFFF2F4F7),
              color: _getProgressColor(assignee.progress),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress >= 100) return const Color(0xFF27AE60);
    if (progress >= 50) return const Color(0xFF2F80ED);
    if (progress >= 25) return const Color(0xFFF2994A);
    return const Color(0xFFEB5757);
  }
}