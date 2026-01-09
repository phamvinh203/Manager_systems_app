import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_bloc.dart';
import 'package:mobile/models/leave_request_model.dart';
import 'package:mobile/repositories/leave_request_repository.dart';
import 'package:mobile/screens/leaves/leave_request_detail_screen.dart';
import 'package:mobile/utils/enum/leave_status.dart';
import 'package:mobile/utils/enum/leave_type.dart';
import 'package:mobile/utils/formatters.dart';

class LeaveRequestCard extends StatelessWidget {
  final LeaveRequestModel leaveRequest;

  const LeaveRequestCard({super.key, required this.leaveRequest});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => LeaveRequestBloc(LeaveRequestRepository()),
              child: LeaveRequestDetailScreen(
                requestId: leaveRequest.id.toString(),
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    leaveRequest.leaveType.buildIconContainer(),
                    const SizedBox(width: 8),
                    Text(
                      leaveRequest.leaveType.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                leaveRequest.status.buildStatusChip(),
              ],
            ),
            const Divider(height: 24),

            // Thông tin ngày
            _buildInfoRow(
              Icons.calendar_today,
              'Từ ngày',
              Formatters.formatDateVN(leaveRequest.startDate),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.event,
              'Đến ngày',
              Formatters.formatDateVN(leaveRequest.endDate),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.timelapse,
              'Số ngày',
              '${Formatters.formatDays(leaveRequest.totalDays)} ngày',
            ),

            // Lý do
            if (leaveRequest.reason != null &&
                leaveRequest.reason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lý do:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(leaveRequest.reason!),
                  ],
                ),
              ),
            ],

            // Ghi chú từ chối (nếu có)
            if (leaveRequest.isRejected && leaveRequest.rejectNote != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lý do từ chối:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      leaveRequest.rejectNote!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                ),
              ),
            ],

            // Thời gian tạo
            const SizedBox(height: 12),
            Text(
              'Tạo lúc: ${Formatters.formatDateTimeVN(leaveRequest.createdAt)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
