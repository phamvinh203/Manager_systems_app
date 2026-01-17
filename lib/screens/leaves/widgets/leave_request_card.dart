import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_event.dart';
import 'package:mobile/models/leave_request_model.dart';
import 'package:mobile/utils/enum/leave_status.dart';
import 'package:mobile/utils/enum/leave_type.dart';
import 'package:mobile/utils/formatters.dart';

class LeaveRequestCard extends StatelessWidget {
  final LeaveRequestModel leaveRequest;
  final VoidCallback? onTap;

  const LeaveRequestCard({super.key, required this.leaveRequest, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isTeamRequest = leaveRequest.employee != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isTeamRequest) ...[
                _buildEmployeeHeader(),
                const Divider(height: 24, thickness: 0.5),
              ],
              Row(
                children: [
                  // Icon Container
                  leaveRequest.leaveType.buildIconContainer(),
                  const SizedBox(width: 16),

                  // Middle Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${Formatters.formatDateVN(leaveRequest.startDate)} - ${Formatters.formatDateVN(leaveRequest.endDate)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF828282),
                            ),
                            children: [
                              TextSpan(text: leaveRequest.leaveType.label),
                              if (leaveRequest.reason != null &&
                                  leaveRequest.reason!.isNotEmpty) ...[
                                const TextSpan(text: ' • '),
                                TextSpan(text: leaveRequest.reason),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Chip
                  leaveRequest.status.buildStatusChip(),
                ],
              ),
              if (isTeamRequest && leaveRequest.status.isPending) ...[
                const SizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeHeader() {
    final employee = leaveRequest.employee!;
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF2F80ED).withOpacity(0.1),
          child: Text(
            employee.initials,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F80ED),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.fullName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              if (employee.position != null)
                Text(
                  employee.position!.name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF828282),
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Formatters.formatDays(leaveRequest.totalDays),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const Text(
              'Ngày',
              style: TextStyle(fontSize: 11, color: Color(0xFF828282)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              context.read<LeaveRequestBloc>().add(
                RejectTeamLeaveRequestEvent(
                  requestId: leaveRequest.id.toString(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEB5757),
              side: const BorderSide(color: Color(0xFFEB5757)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: const Text(
              'Từ chối',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              context.read<LeaveRequestBloc>().add(
                ApproveTeamLeaveRequestEvent(
                  requestId: leaveRequest.id.toString(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: const Text(
              'Phê duyệt',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
