import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/task/task_bloc.dart';
import 'package:mobile/blocs/task/task_event.dart';
import 'package:mobile/blocs/task/task_state.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/screens/workspace/manager/widgets/add_employee_task.dart';
import 'widgets/task_shared_widgets.dart';
import 'widgets/task_employee_section.dart';

class TaskDetailPage extends StatefulWidget {
  final int taskId;
  final TaskModel? initialTask;

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
                  /// ===== HEADER TASK =====
                  TaskHeaderCard(task: task),

                  const SizedBox(height: 24),

                  /// ===== EMPLOYEE SECTION =====
                  TaskEmployeeSection(
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
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
            PopupMenuItem(value: 'delete', child: Text('Xóa')),
          ],
        ),
      ],
    );
  }

  // MENU ACTION

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit task page
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  // DELETE

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
              context
                  .read<TaskBloc>()
                  .add(DeleteTaskEvent(taskId: widget.taskId));
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // ERROR STATE

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

  // NAVIGATION

  Future<void> _navigateToAddEmployee(TaskModel task) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEmployeeTask(task: task),
      ),
    );

    if (result == true && mounted) {
      _loadTaskDetail();
    }
  }
}
