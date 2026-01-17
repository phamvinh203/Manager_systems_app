import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/departments/departments_bloc.dart';
import 'package:mobile/blocs/departments/departments_event.dart';
import 'package:mobile/blocs/departments/departments_state.dart';
import 'package:mobile/models/department_model.dart';

class TabFilterChip extends StatefulWidget {
  final Function(Department?) onSelected;

  const TabFilterChip({
    super.key,
    required this.onSelected,
  });

  @override
  State<TabFilterChip> createState() => _TabFilterChipState();
}

class _TabFilterChipState extends State<TabFilterChip> {
  int? _selectedDepartmentId; // null = All

  @override
  void initState() {
    super.initState();
    context.read<DepartmentsBloc>().add(LoadDepartments());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepartmentsBloc, DepartmentsState>(
      builder: (context, state) {
        if (state is DepartmentsLoading) {
          return const SizedBox(
            height: 40,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (state is DepartmentsLoaded) {
          return _buildChips(state.departments);
        }

        if (state is DepartmentsError) {
          return Text(
            state.message,
            style: const TextStyle(color: Colors.red),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildChips(List<Department> departments) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(
            label: 'All',
            selected: _selectedDepartmentId == null,
            onTap: () {
              setState(() => _selectedDepartmentId = null);
              widget.onSelected(null);
            },
          ),
          ...departments.map(
            (department) => _buildChip(
              label: department.name, 
              selected: _selectedDepartmentId == department.id,
              onTap: () {
                setState(() => _selectedDepartmentId = department.id);
                widget.onSelected(department);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0B79D0) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0xFF0B79D0)
                  : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
