import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/departments/departments_bloc.dart';
import 'package:mobile/blocs/departments/departments_event.dart';
import 'package:mobile/blocs/departments/departments_state.dart';
import 'package:mobile/blocs/employee/employee_bloc.dart';
import 'package:mobile/blocs/employee/employee_event.dart';
import 'package:mobile/blocs/employee/employee_state.dart';
import 'package:mobile/blocs/positions/positions_bloc.dart';
import 'package:mobile/blocs/positions/positions_event.dart';
import 'package:mobile/blocs/positions/positions_state.dart';
import 'package:mobile/models/employee_model.dart';
import 'package:mobile/screens/employee/widgets/form_fields.dart';
import 'package:mobile/utils/employee_helpers.dart';

class EmployeeForm extends StatefulWidget {
  final Employee? initialEmployee;
  final bool isSubmitting;
  final void Function(Employee employee) onSubmit;
  final String submitText;

  const EmployeeForm({
    super.key,
    this.initialEmployee,
    required this.isSubmitting,
    required this.onSubmit,
    required this.submitText,
  });

  @override
  State<EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _salaryController;

  int? _departmentId;
  int? _positionId;
  late String _status;
  late DateTime _hiredAt;

  @override
  void initState() {
    super.initState();
    final e = widget.initialEmployee;

    _codeController = TextEditingController(text: e?.code ?? '');
    _firstNameController = TextEditingController(text: e?.firstName ?? '');
    _lastNameController = TextEditingController(text: e?.lastName ?? '');
    _emailController = TextEditingController(text: e?.email ?? '');
    _phoneController = TextEditingController(text: e?.phone ?? '');
    _salaryController = TextEditingController(
      text: e?.salary?.toStringAsFixed(0) ?? '',
    );

    _departmentId = e?.departmentId;
    _positionId = e?.positionId;
    _status = e?.status ?? EmployeeConstants.statuses.first;
    _hiredAt = e?.hiredAt ?? DateTime.now();

    // Load departments và positions khi form được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepartmentsBloc>().add(LoadDepartments());
      context.read<PositionsBloc>().add(LoadPositions());
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _onDepartmentChanged(int? departmentId) {
    setState(() {
      _departmentId = departmentId;
      _positionId = null; // Reset position khi đổi department
    });


  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();

    final employee = Employee(
      id: widget.initialEmployee?.id ?? 0,
      code: _codeController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      departmentId: _departmentId,
      positionId: _positionId,
      salary: double.tryParse(_salaryController.text.trim()),
      status: _status,
      hiredAt: _hiredAt,
      createdAt: widget.initialEmployee?.createdAt ?? now,
      updatedAt: now,
    );

    widget.onSubmit(employee);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _codeController,
                label: 'Employee Code',
                icon: Icons.badge,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _firstNameController,
                label: 'First Name',
                icon: Icons.person,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _lastNameController,
                label: 'Last Name',
                icon: Icons.person_outline,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return null; // Email optional
                  return v.contains('@') ? null : 'Invalid email';
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _phoneController,
                label: 'Phone',
                icon: Icons.phone,
              ),
              const SizedBox(height: 16),

              // Department dropdown from API
              _buildDepartmentDropdown(),
              const SizedBox(height: 16),

              // Position dropdown from API (filtered by department)
              _buildPositionDropdown(),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _salaryController,
                label: 'Salary',
                icon: Icons.account_balance_wallet,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              CustomDropdown(
                label: 'Status',
                icon: Icons.verified,
                value: _status,
                items: EmployeeConstants.statuses,
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),

              CustomDatePicker(
                selectedDate: _hiredAt,
                onDateChanged: (d) => setState(() => _hiredAt = d),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: widget.isSubmitting ? null : _submit,
                  child: widget.isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.submitText),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDepartmentDropdown() {
    return BlocBuilder<DepartmentsBloc, DepartmentsState>(
      builder: (context, state) {
        if (state is DepartmentsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DepartmentsError) {
          return DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Department',
              prefixIcon: const Icon(Icons.business),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorText: 'Failed to load',
            ),
            items: const [],
            onChanged: null,
            validator: (v) => v == null ? 'Please select a department' : null,
          );
        }

        if (state is DepartmentsLoaded) {
          return DropdownButtonFormField<int>(
            value: _departmentId,
            decoration: InputDecoration(
              labelText: 'Department',
              prefixIcon: const Icon(Icons.business),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: state.departments.map((dept) {
              return DropdownMenuItem<int>(
                value: dept.id,
                child: Text(dept.name),
              );
            }).toList(),
            onChanged: _onDepartmentChanged,
            validator: (v) => v == null ? 'Please select a department' : null,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPositionDropdown() {
    return BlocBuilder<PositionsBloc, PositionsState>(
      builder: (context, state) {
        if (state is PositionsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PositionsError) {
          return DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Position',
              prefixIcon: const Icon(Icons.work),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorText: 'Failed to load',
            ),
            items: const [],
            onChanged: null,
            validator: (v) => v == null ? 'Please select a position' : null,
          );
        }

        if (state is PositionsLoaded) {
          // Filter positions by selected department
          final filteredPositions = _departmentId != null
              ? state.positions
                  .where((p) => p.departmentId == _departmentId)
                  .toList()
              : state.positions;

          return DropdownButtonFormField<int>(
            value: filteredPositions.any((p) => p.id == _positionId)
                ? _positionId
                : null,
            decoration: InputDecoration(
              labelText: 'Position',
              prefixIcon: const Icon(Icons.work),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: filteredPositions.map((pos) {
              return DropdownMenuItem<int>(
                value: pos.id,
                child: Text(pos.name),
              );
            }).toList(),
            onChanged: (v) => setState(() => _positionId = v),
            validator: (v) => v == null ? 'Please select a position' : null,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
