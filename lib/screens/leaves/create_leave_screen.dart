import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_bloc.dart';
import 'package:mobile/blocs/leaves/leave_request_event.dart';
import 'package:mobile/blocs/leaves/leave_request_state.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/screens/leaves/widgets/leave_type_selector.dart';
import 'package:mobile/screens/leaves/widgets/date_picker_field.dart';
import 'package:mobile/utils/enum/leave_type.dart';
import 'package:mobile/utils/formatters.dart';

class CreateLeaveScreen extends StatefulWidget {
  const CreateLeaveScreen({super.key});

  @override
  State<CreateLeaveScreen> createState() => _CreateLeaveScreenState();
}

class _CreateLeaveScreenState extends State<CreateLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  LeaveType _selectedLeaveType = LeaveType.annual;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeaveRequestBloc, LeaveRequestState>(
      listener: (context, state) {
        if (state.isSuccess) {
          final leaveRequest = state.currentLeaveRequest;
          if (leaveRequest != null) {
            NotificationService().showLeaveRequestCreated(
              leaveType: leaveRequest.leaveType.label,
              startDate: Formatters.formatDateVN(leaveRequest.startDate),
              endDate: Formatters.formatDateVN(leaveRequest.endDate),
              totalDays: leaveRequest.totalDays,
            );
          }

          Navigator.pop(context, true);
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
          title: const Text('Tạo đơn nghỉ phép'),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Loại nghỉ phép
              const Text(
                'Loại nghỉ phép',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              LeaveTypeSelector(
                selectedType: _selectedLeaveType,
                onChanged: (type) {
                  setState(() => _selectedLeaveType = type);
                },
              ),
              const SizedBox(height: 24),

              // Ngày bắt đầu
              DatePickerField(
                label: 'Ngày bắt đầu',
                selectedDate: _startDate,
                onDateSelected: (date) {
                  setState(() {
                    _startDate = date;
                    // Reset end date nếu nhỏ hơn start date
                    if (_endDate != null && _endDate!.isBefore(date)) {
                      _endDate = null;
                    }
                  });
                },
                validator: (date) {
                  if (date == null) return 'Vui lòng chọn ngày bắt đầu';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ngày kết thúc
              DatePickerField(
                label: 'Ngày kết thúc',
                selectedDate: _endDate,
                firstDate: _startDate,
                onDateSelected: (date) {
                  setState(() => _endDate = date);
                },
                validator: (date) {
                  if (date == null) return 'Vui lòng chọn ngày kết thúc';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Hiển thị số ngày nghỉ
              if (_startDate != null && _endDate != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Tổng số ngày nghỉ: ${_calculateDays()} ngày',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Lý do
              const Text(
                'Lý do',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Nhập lý do nghỉ phép...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập lý do';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Nút gửi
              BlocBuilder<LeaveRequestBloc, LeaveRequestState>(
                builder: (context, state) {
                  return SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Gửi đơn',
                              style: TextStyle(
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
        ),
      ),
    );
  }

  int _calculateDays() {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) return;

    context.read<LeaveRequestBloc>().add(
      CreateLeaveRequestEvent(
        leaveType: _selectedLeaveType,
        startDate: Formatters.formatDateApi(_startDate!),
        endDate: Formatters.formatDateApi(_endDate!),
        reason: _reasonController.text.trim(),
      ),
    );
  }
}
