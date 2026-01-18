import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/departments/departments_bloc.dart';
import 'package:mobile/blocs/departments/departments_event.dart';
import 'package:mobile/blocs/departments/departments_state.dart';
import 'package:mobile/blocs/task/task_bloc.dart';
import 'package:mobile/blocs/task/task_event.dart';
import 'package:mobile/blocs/task/task_state.dart';
import 'package:mobile/models/department_model.dart';
import 'package:mobile/models/task_model.dart';
import 'package:mobile/utils/employee_helpers.dart';

class AddEmployeeTask extends StatefulWidget {
  final TaskModel task;

  const AddEmployeeTask({super.key, required this.task});

  @override
  State<AddEmployeeTask> createState() => _AddEmployeeTaskState();
}

class _AddEmployeeTaskState extends State<AddEmployeeTask> {
  final Set<int> _selectedIds = {};
  late final Set<int> _initialIds;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialIds = widget.task.assignees?.map((e) => e.employeeId).toSet() ?? {};
    _selectedIds.addAll(_initialIds);

    // Load employees for the department
    if (widget.task.department?.id != null) {
      context.read<DepartmentsBloc>().add(
        LoadEmployeesByDepartment(widget.task.department!.id),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final newIds = _selectedIds.difference(_initialIds);
    final removedIds = _initialIds.difference(_selectedIds);

    // Call assignTask for new ones (Batch)
    if (newIds.isNotEmpty) {
      context.read<TaskBloc>().add(
        AssignTaskEvent(taskId: widget.task.id, employeeIds: newIds.toList()),
      );
    }

    // Call unassignTask for each removed one
    for (final id in removedIds) {
      context.read<TaskBloc>().add(
        UnassignTaskEvent(taskId: widget.task.id, employeeId: id),
      );
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state.status == BlocTaskStatus.success) {
          // You could show a snackbar here if needed
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Color(0xFF333333),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Thêm nhân viên',
            style: TextStyle(
              color: Color(0xFF1D2939),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: 'Tìm tên hoặc mã nhân viên...',
                    prefixIcon: Icon(Icons.search, color: Color(0xFF667085)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: BlocBuilder<DepartmentsBloc, DepartmentsState>(
          builder: (context, state) {
            if (state is EmployeesByDepartmentLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DepartmentsError) {
              return Center(child: Text(state.message));
            }

            if (state is EmployeesByDepartmentLoaded) {
              final employees = state.employees;
              final filteredEmployees = employees.where((e) {
                final fullName = '${e.firstName} ${e.lastName}'.toLowerCase();
                return fullName.contains(_searchQuery) ||
                    e.code.toLowerCase().contains(_searchQuery);
              }).toList();

              final selectedEmployees = employees
                  .where((e) => _selectedIds.contains(e.id))
                  .toList();

              return Column(
                children: [
                  if (selectedEmployees.isNotEmpty)
                    _buildSelectedSection(selectedEmployees),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        if (_searchQuery.isEmpty) ...[
                          _buildSectionTitle('GỢI Ý'),
                          ...filteredEmployees
                              .take(2)
                              .map((e) => _buildEmployeeTile(e)),
                          const Divider(height: 32, indent: 16, endIndent: 16),
                        ],
                        _buildSectionTitle('TẤT CẢ NHÂN VIÊN'),
                        ...filteredEmployees.map((e) => _buildEmployeeTile(e)),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('Không có dữ liệu nhân viên'));
          },
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1570EF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectanglePlatform.isIOS
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )
                    : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ), // Using standard but custom for look
              ),
              child: Text(
                'Xác nhận thêm (${_selectedIds.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSection(List<DepartmentEmployee> selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ĐÃ CHỌN (${selected.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475467),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedIds.clear()),
                child: const Text(
                  'Xóa tất cả',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F80ED),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: selected.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final e = selected[index];
              return Container(
                padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF8FF),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: const Color(0xFFB2DDFF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: EmployeeHelpers.getAvatarColor(
                        '${e.firstName} ${e.lastName}',
                      ),
                      child: Text(
                        EmployeeHelpers.getNameInitials(
                          '${e.firstName} ${e.lastName}',
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${e.firstName} ${e.lastName}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF175CD3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _selectedIds.remove(e.id)),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Color(0xFF175CD3),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF475467),
        ),
      ),
    );
  }

  Widget _buildEmployeeTile(DepartmentEmployee e) {
    final isSelected = _selectedIds.contains(e.id);
    final fullName = '${e.firstName} ${e.lastName}';

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedIds.remove(e.id);
          } else {
            _selectedIds.add(e.id);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: EmployeeHelpers.getAvatarColor(fullName),
                  child: Text(
                    EmployeeHelpers.getNameInitials(fullName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (e.status == 'ACTIVE')
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF101828),
                    ),
                  ),
                  Text(
                    '${e.position.name} • ${widget.task.department?.name ?? ""}',
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF1570EF) : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1570EF)
                      : const Color(0xFFD0D5DD),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper to avoid build error if RoundedRectanglePlatform not exists, normally I'd use standard button
class RoundedRectanglePlatform {
  static bool get isIOS => true; // Mocking for aesthetic
}
