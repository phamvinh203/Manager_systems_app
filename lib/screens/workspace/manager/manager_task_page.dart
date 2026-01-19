import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/auth/auth_bloc.dart';
import 'package:mobile/blocs/auth/auth_state.dart';
import 'package:mobile/blocs/task/task_bloc.dart';
import 'package:mobile/blocs/task/task_event.dart';
import 'package:mobile/blocs/task/task_state.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/screens/workspace/manager/widgets/manager_header.dart';
import 'package:mobile/screens/workspace/manager/widgets/manager_task_list_view.dart';
import 'package:mobile/screens/workspace/manager/widgets/manager_task_status_tab_bar.dart';
import 'package:mobile/screens/workspace/widgets/task_detail.dart';
import 'package:mobile/screens/workspace/widgets/update_task.dart';
import 'package:mobile/screens/workspace/widgets/create_task_fab.dart';
import 'package:mobile/utils/task/task_status.dart';

class ManagerTaskPage extends StatefulWidget {
  const ManagerTaskPage({super.key});

  @override
  State<ManagerTaskPage> createState() => _ManagerTaskPageState();
}

class _ManagerTaskPageState extends State<ManagerTaskPage> {
  TaskStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Load tasks on init
    context.read<TaskBloc>().add(const LoadTasksEvent());
  }

  Map<TaskStatus, int> _getTaskCounts(List<TaskModel> tasks) {
    final counts = <TaskStatus, int>{};
    for (var status in TaskStatus.values) {
      counts[status] = tasks.where((t) => t.status == status).length;
    }
    return counts;
  }

  void _handleTaskTap(TaskModel task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailPage(taskId: task.id)),
    );
    // Reload tasks after returning from detail
    if (mounted) {
      context.read<TaskBloc>().add(const LoadTasksEvent());
    }
  }

  void _handleTaskEdit(TaskModel task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateTaskPage(task: task)),
    );
    // Reload tasks after update
    if (mounted) {
      context.read<TaskBloc>().add(const LoadTasksEvent());
    }
  }

  void _handleSearchTap() {}

  String _resolveDepartmentName({
    required AuthState authState,
    required List<TaskModel> tasks,
  }) {
    if (authState is! AuthAuthenticated) return 'Phòng ban';

    final user = authState.user;

    if (user.role != 'MANAGER') return 'Phòng ban';

    if (tasks.isEmpty) return 'Phòng ban';

    return tasks.first.department?.name ?? 'Phòng ban';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        // Show error message if any
        if (state.isError && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }

        // Show success message if any
        if (state.isSuccess && state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            final tasks = state.tasks ?? [];

            // Filter tasks based on selected status
            var filteredTasks = tasks;
            if (_selectedStatus != null) {
              filteredTasks = tasks
                  .where((task) => task.status == _selectedStatus)
                  .toList();
            }

            return SafeArea(
              child: Column(
                children: [
                  // Header
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final user = authState is AuthAuthenticated
                          ? authState.user
                          : null;

                      return ManagerHeader(
                        departmentName: _resolveDepartmentName(
                          authState: authState,
                          tasks: tasks,
                        ),
                        userName: user?.name ?? 'User',
                        userAvatar: null,
                        onSearchTap: _handleSearchTap,
                        onAvatarTap: () {
                          // TODO: Navigate to profile
                        },
                      );
                    },
                  ),

                  // Status Tab Bar
                  ManagerTaskStatusTabBar(
                    selectedStatus: _selectedStatus,
                    onStatusChanged: (status) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    taskCounts: _getTaskCounts(tasks),
                  ),

                  const SizedBox(height: 8),

                  // Task List
                  Expanded(
                    child: ManagerTaskListView(
                      tasks: filteredTasks,
                      isLoading: state.isLoading,
                      onTaskTap: _handleTaskTap,
                      onTaskEdit: _handleTaskEdit,
                      emptyMessage: _getEmptyMessage(),
                      currentPage: state.pagination?.page,
                      totalPages: state.pagination?.totalPages,
                      onPageChanged: (page) {
                        context.read<TaskBloc>().add(
                          LoadTasksEvent(page: page),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: const CreateTaskFAB(),
        bottomNavigationBar: const SizedBox(height: 80),
      ),
    );
  }

  String _getEmptyMessage() {
    if (_selectedStatus != null) {
      return 'Không có công việc ${_selectedStatus!.label.toLowerCase()}';
    }
    return 'Không có công việc nào';
  }
}
