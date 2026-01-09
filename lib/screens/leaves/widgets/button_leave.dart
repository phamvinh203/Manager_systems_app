import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_event.dart';
import 'package:mobile/screens/leaves/create_leave_screen.dart';

class ButtonLeave extends StatelessWidget {
  const ButtonLeave({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToCreateLeave(context),
      icon: const Icon(Icons.add),
      label: const Text('Tạo đơn'),
    );
  }

  void _navigateToCreateLeave(BuildContext context) async {
    final bloc = context.read<LeaveRequestBloc>();

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: bloc, child: const CreateLeaveScreen()),
      ),
    );

    // Reload danh sách nếu tạo đơn thành công
    if (result == true) {
      bloc.add(const LoadLeaveRequestsEvent());
    }
  }
}
