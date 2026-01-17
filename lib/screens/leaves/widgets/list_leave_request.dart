import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_state.dart';
import 'package:mobile/screens/leaves/widgets/leave_request_card.dart';

class ListLeaveRequest extends StatelessWidget {
  const ListLeaveRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaveRequestBloc, LeaveRequestState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage ?? 'Đã xảy ra lỗi',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        }

        final leaveRequests = state.leaveRequests ?? [];

        if (leaveRequests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Chưa có đơn nghỉ phép nào',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          itemCount: leaveRequests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 0),
          itemBuilder: (context, index) {
            final request = leaveRequests[index];
            return LeaveRequestCard(leaveRequest: request);
          },
        );
      },
    );
  }
}
