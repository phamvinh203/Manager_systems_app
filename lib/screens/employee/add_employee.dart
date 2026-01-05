import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/employee/employee_bloc.dart';
import 'package:mobile/blocs/employee/employee_event.dart';
import 'package:mobile/blocs/employee/employee_state.dart';
import 'package:mobile/screens/employee/widgets/employee_form.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Add Employee')),
      body: BlocListener<EmployeeBloc, EmployeeState>(
        listener: (context, state) {
          /// CREATE SUCCESS
          if (state.successMessage != null && _isCreating) {
            setState(() => _isCreating = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pop(context);
          }

          /// CREATE ERROR
          if (state.errorMessage != null && _isCreating) {
            setState(() => _isCreating = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );

            context
                .read<EmployeeBloc>()
                .add(const ClearMessagesEvent());
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: EmployeeForm(
            submitText: 'Create Employee',
            isSubmitting: _isCreating,
            onSubmit: (employee) {
              setState(() => _isCreating = true);

              context
                  .read<EmployeeBloc>()
                  .add(CreateEmployeeEvent(employee));
            },
          ),
        ),
      ),
    );
  }
}
