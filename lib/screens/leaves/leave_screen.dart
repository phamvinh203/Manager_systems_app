import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_event.dart';
import 'package:mobile/repositories/leave_request_repository.dart';
import 'package:mobile/screens/leaves/widgets/button_leave.dart';
import 'package:mobile/screens/leaves/widgets/list_leave_request.dart';

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeaveRequestBloc(LeaveRequestRepository()),
      child: const _LeaveScreenContent(),
    );
  }
}

class _LeaveScreenContent extends StatelessWidget {
  const _LeaveScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn nghỉ phép'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LeaveRequestBloc>().add(
                const LoadLeaveRequestsEvent(),
              );
            },
          ),
        ],
      ),
      body: const ListLeaveRequest(),
      floatingActionButton: const ButtonLeave(),
    );
  }
}
