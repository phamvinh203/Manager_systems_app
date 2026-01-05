import 'package:flutter/material.dart';
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

  late String _position;
  late String _department;
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
    _salaryController =
        TextEditingController(text: e?.salary.toString() ?? '');

    _position = e?.position ?? EmployeeConstants.positions.first;
    _department = e?.department ?? EmployeeConstants.departments.first;
    _status = e?.status ?? EmployeeConstants.statuses.first;
    _hiredAt = e?.hiredAt ?? DateTime.now();
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();

    final employee = Employee(
      id: widget.initialEmployee?.id ?? 0,
      code: _codeController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      position: _position,
      department: _department,
      salary: int.tryParse(_salaryController.text.trim()) ?? 0,
      status: _status,
      hiredAt: _hiredAt,
      createdAt: widget.initialEmployee?.createdAt ?? now,
      updatedAt: now,
    );

    widget.onSubmit(employee);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _codeController,
            label: 'Employee Code',
            icon: Icons.badge,
            validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _firstNameController,
            label: 'First Name',
            icon: Icons.person,
            validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _lastNameController,
            label: 'Last Name',
            icon: Icons.person_outline,
            validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                v != null && v.contains('@') ? null : 'Invalid email',
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _phoneController,
            label: 'Phone',
            icon: Icons.phone,
          ),
          const SizedBox(height: 16),

          CustomDropdown(
            label: 'Position',
            icon: Icons.work,
            value: _position,
            items: EmployeeConstants.positions,
            onChanged: (v) => setState(() => _position = v!),
          ),
          const SizedBox(height: 16),

          CustomDropdown(
            label: 'Department',
            icon: Icons.business,
            value: _department,
            items: EmployeeConstants.departments,
            onChanged: (v) => setState(() => _department = v!),
          ),
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
  }
}
