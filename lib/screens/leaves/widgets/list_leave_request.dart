import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_event.dart';
import 'package:mobile/blocs/leaves/leave_request_state.dart';
import 'package:mobile/screens/leaves/widgets/leave_request_card.dart';

class ListLeaveRequest extends StatefulWidget {
  const ListLeaveRequest({super.key});

  @override
  State<ListLeaveRequest> createState() => _ListLeaveRequestState();
}

class _ListLeaveRequestState extends State<ListLeaveRequest> {
  @override
  void initState() {
    super.initState();
    _loadLeaveRequests();
  }

  void _loadLeaveRequests() {
    context.read<LeaveRequestBloc>().add(const LoadLeaveRequestsEvent());
  }

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
                Text(
                  state.errorMessage ?? 'Đã xảy ra lỗi',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadLeaveRequests,
                  child: const Text('Thử lại'),
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

        return RefreshIndicator(
          onRefresh: () async => _loadLeaveRequests(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: leaveRequests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = leaveRequests[index];
              return LeaveRequestCard(leaveRequest: request);
            },
          ),
        );
      },
    );
  }
}
