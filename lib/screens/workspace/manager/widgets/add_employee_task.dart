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
  late Set<int> _selectedIds;
  late Set<int> _initialIds;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initialIds = widget.task.assignees?.map((e) => e.employeeId).toSet() ?? {};
    _selectedIds = Set.from(_initialIds);

    _loadEmployees();
  }

  void _loadEmployees() {
    final departmentId = widget.task.department?.id;
    if (departmentId != null) {
      context.read<DepartmentsBloc>().add(
        LoadEmployeesByDepartment(departmentId),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 🔧 TỐI ƯU: Dùng batch event thay vì nhiều events riêng lẻ
  void _onConfirm() {
    final toAssign = _selectedIds.difference(_initialIds);
    final toUnassign = _initialIds.difference(_selectedIds);

    // Không có thay đổi gì
    if (toAssign.isEmpty && toUnassign.isEmpty) {
      Navigator.pop(context);
      return;
    }

    // 🆕 Sử dụng single batch event
    context.read<TaskBloc>().add(
      UpdateTaskAssignmentsEvent(
        taskId: widget.task.id,
        toAssign: toAssign,
        toUnassign: toUnassign,
      ),
    );
  }

  // Helper để check có thay đổi không
  bool get _hasChanges {
    final toAssign = _selectedIds.difference(_initialIds);
    final toUnassign = _initialIds.difference(_selectedIds);
    return toAssign.isNotEmpty || toUnassign.isNotEmpty;
  }

  // Helper để lấy summary text
  String get _changesSummary {
    final added = _selectedIds.difference(_initialIds).length;
    final removed = _initialIds.difference(_selectedIds).length;

    if (added > 0 && removed > 0) return '+$added, -$removed';
    if (added > 0) return '+$added';
    if (removed > 0) return '-$removed';
    return '${_selectedIds.length} đã chọn';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listenWhen: (prev, curr) =>
          prev.assignStatus != curr.assignStatus ||
          prev.errorMessage != curr.errorMessage ||
          prev.successMessage != curr.successMessage,
      listener: _handleTaskStateChanges,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  void _handleTaskStateChanges(BuildContext context, TaskState state) {
    // Show error
    if (state.assignStatus == TaskOperationStatus.failed &&
        state.errorMessage != null) {
      _showSnackBar(state.errorMessage!, isError: true);
      return;
    }

    // Success - pop với result
    if (state.assignStatus == TaskOperationStatus.completed) {
      if (state.successMessage != null) {
        _showSnackBar(state.successMessage!);
      }
      Navigator.pop(context, true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
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
        onPressed: () => _handleBackPress(),
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
        child: _buildSearchBar(),
      ),
    );
  }

  // 🔧 TỐI ƯU: Confirm dialog khi có unsaved changes
  Future<void> _handleBackPress() async {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy thay đổi?'),
        content: const Text(
          'Bạn có thay đổi chưa lưu. Bạn có chắc muốn thoát?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ở lại'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );

    if (shouldDiscard == true && mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildSearchBar() {
    return Padding(
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
          decoration: InputDecoration(
            hintText: 'Tìm tên hoặc mã nhân viên...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF667085)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<DepartmentsBloc, DepartmentsState>(
      builder: (context, state) {
        if (state is EmployeesByDepartmentLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DepartmentsError) {
          return _buildErrorState(state.message);
        }

        if (state is EmployeesByDepartmentLoaded) {
          return _buildEmployeeList(state.employees);
        }

        return const Center(child: Text('Không có dữ liệu nhân viên'));
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadEmployees,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList(List<DepartmentEmployee> employees) {
    // Filter employees
    final filtered = _searchQuery.isEmpty
        ? employees
        : employees.where((e) {
            final fullName = '${e.firstName} ${e.lastName}'.toLowerCase();
            return fullName.contains(_searchQuery) ||
                e.code.toLowerCase().contains(_searchQuery);
          }).toList();

    // Get selected employees for header chips
    final selectedEmployees = employees
        .where((e) => _selectedIds.contains(e.id))
        .toList();

    return Column(
      children: [
        // Selected chips section
        if (selectedEmployees.isNotEmpty)
          _buildSelectedSection(selectedEmployees),

        // Employee list
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptySearch()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: filtered.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildSectionTitle('TẤT CẢ NHÂN VIÊN');
                    }

                    final employee = filtered[index - 1];
                    return _EmployeeTile(
                      employee: employee,
                      isSelected: _selectedIds.contains(employee.id),
                      task: widget.task,
                      onTap: () => _toggleEmployee(employee.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy nhân viên',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
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
            itemBuilder: (context, index) =>
                _buildSelectedChip(selected[index]),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSelectedChip(DepartmentEmployee e) {
    final fullName = '${e.firstName} ${e.lastName}';

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
            backgroundColor: EmployeeHelpers.getAvatarColor(fullName),
            child: Text(
              EmployeeHelpers.getNameInitials(fullName),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF175CD3),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _selectedIds.remove(e.id)),
            child: const Icon(Icons.close, size: 14, color: Color(0xFF175CD3)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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

  void _toggleEmployee(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Widget _buildBottomBar() {
    return BlocBuilder<TaskBloc, TaskState>(
      buildWhen: (prev, curr) => prev.assignStatus != curr.assignStatus,
      builder: (context, state) {
        final isProcessing = state.isAssigning;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: isProcessing ? null : _onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1570EF),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(
                  0xFF1570EF,
                ).withOpacity(0.5),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _hasChanges
                          ? 'Xác nhận ($_changesSummary)'
                          : 'Xác nhận (${_selectedIds.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  final DepartmentEmployee employee;
  final bool isSelected;
  final TaskModel task;
  final VoidCallback onTap;

  const _EmployeeTile({
    required this.employee,
    required this.isSelected,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fullName = '${employee.firstName} ${employee.lastName}';

    // BlocSelector hoạt động trong mọi context, kể cả itemBuilder
    return BlocSelector<TaskBloc, TaskState, bool>(
      selector: (state) => state.isProcessingEmployee(employee.id),
      builder: (context, isProcessing) {
        return InkWell(
          onTap: isProcessing ? null : onTap,
          child: Opacity(
            opacity: isProcessing ? 0.5 : 1.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildEmployeeAvatar(fullName),
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
                          '${employee.position.name} • ${task.department?.name ?? ""}',
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isProcessing)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    _buildCheckbox(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmployeeAvatar(String fullName) {
    return Stack(
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
        if (employee.status == 'ACTIVE')
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
    );
  }

  Widget _buildCheckbox() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFF1570EF) : Colors.white,
        border: Border.all(
          color: isSelected ? const Color(0xFF1570EF) : const Color(0xFFD0D5DD),
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
