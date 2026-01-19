import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/departments/departments_bloc.dart';
import 'package:mobile/blocs/departments/departments_event.dart';
import 'package:mobile/blocs/task/task_bloc.dart';
import 'package:mobile/blocs/task/task_event.dart';
import 'package:mobile/blocs/task/task_state.dart';
import 'package:mobile/models/department_model.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/screens/workspace/widgets/create_task_fab.dart';
import 'package:mobile/screens/workspace/admin/widgets/department_selector.dart';
import 'package:mobile/screens/workspace/admin/widgets/task_status_tab_bar.dart';
import 'package:mobile/screens/workspace/admin/widgets/task_list_view.dart';
import 'package:mobile/screens/workspace/task_detail.dart';
import 'package:mobile/screens/workspace/widgets/update_task.dart';
import 'package:mobile/utils/task/task_status.dart';
import 'package:mobile/utils/snackbar_utils.dart';

class AdminTaskPage extends StatefulWidget {
  const AdminTaskPage({super.key});

  @override
  State<AdminTaskPage> createState() => _AdminTaskPageState();
}

class _AdminTaskPageState extends State<AdminTaskPage> {
  Department? _selectedDepartment;
  TaskStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Load departments on init
    context.read<DepartmentsBloc>().add(LoadDepartments());
    // Load tasks
    context.read<TaskBloc>().add(const LoadTasksEvent());
  }

  void _filterTasks() {
    // Reload tasks - filtering is done locally in the builder
    context.read<TaskBloc>().add(const LoadTasksEvent());
  }

  void _handleTaskTap(TaskModel task) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailPage(taskId: task.id)),
    );

    // If user clicked edit from detail page, navigate to update
    if (result == 'edit') {
      _handleTaskEdit(task);
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

  void _handleTaskDelete(TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa công việc "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TaskBloc>().add(DeleteTaskEvent(taskId: task.id));

              // Show success message
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(
              //     content: Text('Đã xóa công việc thành công'),
              //     backgroundColor: Colors.green,
              //   ),
              // );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        // Show error message if any
        if (state.isError && state.errorMessage != null) {
          SnackBarUtils.showError(context, state.errorMessage!);
        }

        // Show success message if any
        if (state.isSuccess && state.successMessage != null) {
          SnackBarUtils.showSuccess(context, state.successMessage!);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text(
            'Quản lý công việc',
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
            TextButton(
              onPressed: () {
                // TODO: Implement help
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Trợ giúp'),
                    content: const Text(
                      '• Nhấn nút + để tạo công việc mới\n'
                      '• Nhấn vào card để xem chi tiết\n'
                      '• Sử dụng bộ lọc để tìm kiếm công việc\n'
                      '• Nhấn icon chỉnh sửa để sửa công việc\n'
                      '• Nhấn icon xóa để xóa công việc',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Help',
                style: TextStyle(color: Color(0xFF2F80ED), fontSize: 14),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Filter Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Department Selector
                  DepartmentSelector(
                    selectedDepartment: _selectedDepartment,
                    onDepartmentChanged: (dept) {
                                setState(() {
                        _selectedDepartment = dept;
                                });
                                _filterTasks();
                              },
                            ),
                  const SizedBox(height: 16),
                  // Status Tab Bar
                  TaskStatusTabBar(
                    selectedStatus: _selectedStatus,
                    onStatusChanged: (status) {
                                setState(() {
                        _selectedStatus = status;
                                });
                                _filterTasks();
                              },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Task List
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  final tasks = state.tasks ?? [];

                  // Filter tasks locally based on selected department and status
                  var filteredTasks = tasks;
                  if (_selectedDepartment != null) {
                    filteredTasks = filteredTasks
                        .where(
                          (task) =>
                              task.department?.id == _selectedDepartment?.id,
                        )
                        .toList();
                  }
                  if (_selectedStatus != null) {
                    filteredTasks = filteredTasks
                        .where((task) => task.status == _selectedStatus)
                        .toList();
                  }

                  return TaskListView(
                    tasks: filteredTasks,
                    isLoading: state.isLoading,
                    onTaskTap: _handleTaskTap,
                    onTaskEdit: _handleTaskEdit,
                    onTaskDelete: _handleTaskDelete,
                    emptyMessage: _getEmptyMessage(),
                    currentPage: state.pagination?.page,
                    totalPages: state.pagination?.totalPages,
                    onPageChanged: (page) {
                      context.read<TaskBloc>().add(LoadTasksEvent(page: page));
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: const CreateTaskFAB(),
        bottomNavigationBar: const SizedBox(height: 80),
      ),
    );
  }

  String _getEmptyMessage() {
    if (_selectedDepartment != null && _selectedStatus != null) {
      return 'Không có công việc nào của ${_selectedDepartment!.name} với trạng thái ${_selectedStatus!.label}';
    } else if (_selectedDepartment != null) {
      return 'Không có công việc nào của ${_selectedDepartment!.name}';
    } else if (_selectedStatus != null) {
      return 'Không có công việc nào với trạng thái ${_selectedStatus!.label}';
    }
    return 'Không có công việc nào';
  }
}
