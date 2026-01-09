import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_event.dart';
import 'package:mobile/blocs/leaves/leave_request_state.dart';
import 'package:mobile/models/leave_request_model.dart';
import 'package:mobile/utils/enum/leave_status.dart';
import 'package:mobile/utils/enum/leave_type.dart';
import 'package:mobile/utils/formatters.dart';

class LeaveRequestDetailScreen extends StatefulWidget {
  final String requestId;

  const LeaveRequestDetailScreen({super.key, required this.requestId});

  @override
  State<LeaveRequestDetailScreen> createState() =>
      _LeaveRequestDetailScreenState();
}

class _LeaveRequestDetailScreenState extends State<LeaveRequestDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    context.read<LeaveRequestBloc>().add(
      LeaveRequestDetailEvent(requestId: widget.requestId),
    );
  }

  void _showCancelDialog(LeaveRequestModel leaveRequest) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận hủy đơn'),
        content: Text(
          'Bạn có chắc chắn muốn hủy đơn nghỉ phép?\n\n'
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _cancelLeaveRequest(leaveRequest.id.toString());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Có, hủy đơn'),
          ),
        ],
      ),
    );
  }

  void _cancelLeaveRequest(String requestId) {
    context.read<LeaveRequestBloc>().add(
      CancelLeaveRequestEvent(requestId: requestId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeaveRequestBloc, LeaveRequestState>(
      listener: (context, state) {
        if (state.isSuccess && state.successMessage != null) {
          Navigator.pop(context);
        } else if (state.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Đã xảy ra lỗi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết đơn nghỉ phép'),
          centerTitle: true,
        ),
        body: BlocBuilder<LeaveRequestBloc, LeaveRequestState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.isError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'Đã xảy ra lỗi',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDetail,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            final leaveRequest = state.currentLeaveRequest;

            if (leaveRequest == null) {
              return const Center(
                child: Text('Không tìm thấy thông tin đơn nghỉ phép'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card chính
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    leaveRequest.leaveType.buildIconContainer(),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        leaveRequest.leaveType.label,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              leaveRequest.status.buildStatusChip(),
                            ],
                          ),
                          const Divider(height: 32),

                          // // Mã đơn
                          // _buildInfoRow(
                          //   Icons.tag,
                          //   'Mã đơn',
                          //   '#${leaveRequest.id}',
                          // ),
                          const SizedBox(height: 16),

                          // Thông tin ngày
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Từ ngày',
                            Formatters.formatDateVN(leaveRequest.startDate),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            Icons.event,
                            'Đến ngày',
                            Formatters.formatDateVN(leaveRequest.endDate),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            Icons.timelapse,
                            'Tổng số ngày',
                            '${Formatters.formatDays(leaveRequest.totalDays)} ngày',
                          ),
                          const SizedBox(height: 24),

                          // Lý do
                          if (leaveRequest.reason != null &&
                              leaveRequest.reason!.isNotEmpty) ...[
                            const Text(
                              'Lý do nghỉ phép',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                leaveRequest.reason!,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Ghi chú từ chối (nếu có)
                          if (leaveRequest.isRejected &&
                              leaveRequest.rejectNote != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.cancel,
                                        color: Colors.red.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Lý do từ chối',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red.shade700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    leaveRequest.rejectNote!,
                                    style: TextStyle(
                                      color: Colors.red.shade900,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Thông tin người duyệt
                          if (leaveRequest.isApproved ||
                              leaveRequest.isRejected) ...[
                            _buildApproverInfo(leaveRequest),
                            const SizedBox(height: 24),
                          ],

                          // Thông tin thời gian
                          _buildTimelineInfo(leaveRequest),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nút hủy đơn (chỉ hiển thị khi đang ở trạng thái pending)
                  if (leaveRequest.isPending)
                    BlocBuilder<LeaveRequestBloc, LeaveRequestState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: state.isLoading
                                ? null
                                : () => _showCancelDialog(leaveRequest),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: state.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.cancel),
                            label: Text(
                              state.isLoading ? 'Đang hủy...' : 'Hủy đơn',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildApproverInfo(LeaveRequestModel leaveRequest) {
    final approvedAt = leaveRequest.approvedAt;
    final rejectedAt = leaveRequest.rejectedAt;
    final actionTime = approvedAt ?? rejectedAt;

    if (actionTime == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: leaveRequest.isApproved
            ? Colors.green.shade50
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: leaveRequest.isApproved
              ? Colors.green.shade200
              : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                leaveRequest.isApproved ? Icons.check_circle : Icons.cancel,
                color: leaveRequest.isApproved
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                leaveRequest.isApproved ? 'Đã duyệt bởi' : 'Bị từ chối bởi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: leaveRequest.isApproved
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${leaveRequest.approverId ?? "N/A"}',
            style: TextStyle(
              color: leaveRequest.isApproved
                  ? Colors.green.shade900
                  : Colors.red.shade900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Thời gian: ${Formatters.formatDateTimeVN(actionTime)}',
            style: TextStyle(
              color: leaveRequest.isApproved
                  ? Colors.green.shade900
                  : Colors.red.shade900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineInfo(LeaveRequestModel leaveRequest) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Thông tin thời gian',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTimelineItem(
            'Tạo đơn',
            Formatters.formatDateTimeVN(leaveRequest.createdAt),
          ),
          const SizedBox(height: 8),
          _buildTimelineItem(
            'Cập nhật lần cuối',
            Formatters.formatDateTimeVN(leaveRequest.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
