import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/employee/employee_bloc.dart';
import 'package:mobile/blocs/employee/employee_event.dart';
import 'package:mobile/blocs/employee/employee_state.dart';
import 'package:mobile/models/employee_model.dart';
import 'package:mobile/screens/employee/widgets/employee_form.dart';

class EditEmployeeScreen extends StatefulWidget {
  final Employee employee;
  const EditEmployeeScreen({super.key, required this.employee});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Edit Employee')),
      body: BlocListener<EmployeeBloc, EmployeeState>(
        listener: (context, state) {
          /// UPDATE SUCCESS
          if (state.successMessage != null && _isUpdating) {
            setState(() => _isUpdating = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pop(context);
          }

          /// UPDATE ERROR
          if (state.errorMessage != null && _isUpdating) {
            setState(() => _isUpdating = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );

            context.read<EmployeeBloc>().add(const ClearMessagesEvent());
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: EmployeeForm(
            initialEmployee: widget.employee,
            submitText: 'Edit Employee',
            isSubmitting: _isUpdating,
            onSubmit: (employee) {
              setState(() => _isUpdating = true);

              context.read<EmployeeBloc>().add(
                UpdateEmployeeEvent(widget.employee.id, employee),
              );
            },
          ),
        ),
      ),
    );
  }
}
