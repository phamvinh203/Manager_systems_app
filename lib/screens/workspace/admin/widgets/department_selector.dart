import 'package:flutter/material.dart';
import 'package:mobile/blocs/departments/departments_bloc.dart';
import 'package:mobile/blocs/departments/departments_state.dart';
import 'package:mobile/models/department_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DepartmentSelector extends StatelessWidget {
  final Department? selectedDepartment;
  final ValueChanged<Department?> onDepartmentChanged;

  const DepartmentSelector({
    super.key,
    required this.selectedDepartment,
    required this.onDepartmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepartmentsBloc, DepartmentsState>(
      builder: (context, state) {
        if (state is DepartmentsLoading) {
          return _buildDropdown(context, items: const [], isLoading: true);
        }

        if (state is DepartmentsError) {
          return _buildDropdown(context, items: const [], isError: true);
        }

        final departments = state is DepartmentsLoaded
            ? state.departments
            : <Department>[];

        // Ensure unique departments by ID to avoid Dropdown duplicate value error
        final Map<int, Department> uniqueDepts = {};
        for (var dept in departments) {
          uniqueDepts[dept.id] = dept;
        }
        final uniqueDeptsList = uniqueDepts.values.toList();

        return _buildDropdown(context, items: uniqueDeptsList);
      },
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required List<Department> items,
    bool isLoading = false,
    bool isError = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Department?>(
          value:
              (selectedDepartment == null || items.contains(selectedDepartment))
              ? selectedDepartment
              : null,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF666666)),
          hint: const Text(
            'Tất cả phòng ban',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
          style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
          items: [
            const DropdownMenuItem<Department?>(
              value: null,
              child: Text('Tất cả phòng ban'),
            ),
            ...items.map((dept) {
              return DropdownMenuItem<Department>(
                value: dept,
                child: Text(dept.name),
              );
            }),
          ],
          onChanged: isLoading || isError
              ? null
              : (Department? dept) {
                  onDepartmentChanged(dept);
                },
        ),
      ),
    );
  }
}
