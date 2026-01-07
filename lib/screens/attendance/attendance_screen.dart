import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/attendance/attendance_bloc.dart';
import 'package:mobile/blocs/attendance/attendance_event.dart';
import 'package:mobile/blocs/attendance/attendance_state.dart';
import 'widgets/list_attendance.dart';

/// Attendance Screen - Hiển thị danh sách chấm công
/// Chịu trách nhiệm layout tổng, state management, gọi API
/// Truyền dữ liệu xuống ListAttendance để render
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load dữ liệu attendance khi khởi tạo
  void _loadData() {
    final now = DateTime.now();
    context.read<AttendanceBloc>().add(
      LoadMyAttendanceEvent(month: now.month, year: now.year),
    );
  }

  /// Refresh dữ liệu
  Future<void> _onRefresh() async {
    final now = DateTime.now();
    context.read<AttendanceBloc>().add(
      LoadMyAttendanceEvent(month: now.month, year: now.year),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(),
      body: BlocListener<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state.isError && state.errorMessage != null) {
            _showErrorMessage(state.errorMessage!);
          }
        },
        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            // Loading state
            if (state.isLoading && state.myAttendances.isEmpty) {
              return _buildLoadingState();
            }

            // Error state
            if (state.isError && state.myAttendances.isEmpty) {
              return _buildErrorState(state.errorMessage ?? 'Đã xảy ra lỗi');
            }

            // Empty state
            if (state.myAttendances.isEmpty && !state.isLoading) {
              return _buildEmptyState();
            }

            // Success state
            return Column(
              children: [
                // Filter header
                _buildFilterHeader(state),

                // Attendance list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: const Color(0xFF3B82F6),
                    child: ListAttendance(attendances: state.myAttendances),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Danh sách chấm công',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      actions: [
        // Filter button
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: const Icon(
              Icons.filter_list_rounded,
              color: Color(0xFF64748B),
            ),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Bộ lọc',
          ),
        ),
      ],
    );
  }

  /// Build filter header
  Widget _buildFilterHeader(AttendanceState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            size: 20,
            color: Color(0xFF3B82F6),
          ),
          const SizedBox(width: 8),
          Text(
            state.filterDisplay,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const Spacer(),
          if (state.myAttendances.isNotEmpty)
            Text(
              '${state.myAttendances.length} bản ghi',
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
        ],
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải dữ liệu...',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  /// Helper: Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_outlined,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không có dữ liệu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chưa có bản ghi chấm công nào',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  /// Show filter bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        currentMonth: context.read<AttendanceBloc>().state.filterMonth,
        currentYear: context.read<AttendanceBloc>().state.filterYear,
        onApply: (month, year) {
          Navigator.pop(context);
          setState(() {
            // _currentPage = 1;
          });
          context.read<AttendanceBloc>().add(
            LoadMyAttendanceEvent(month: month, year: year),
          );
        },
      ),
    );
  }

  /// Check-in/Check-out FAB
  Widget? _buildFloatingActionButton() {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        if (state.isLoading) return const SizedBox.shrink();

        if (state.canCheckIn) {
          return FloatingActionButton.extended(
            heroTag: 'attendance_checkin_fab',
            onPressed: () {
              context.read<AttendanceBloc>().quickCheckIn();
            },
            backgroundColor: const Color(0xFF22C55E),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.login_rounded),
            label: const Text('Check In'),
          );
        }

        if (state.canCheckOut) {
          return FloatingActionButton.extended(
            heroTag: 'attendance_checkout_fab',
            onPressed: () {
              context.read<AttendanceBloc>().quickCheckOut();
            },
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Check Out'),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Filter bottom sheet widget
class _FilterBottomSheet extends StatefulWidget {
  final int? currentMonth;
  final int? currentYear;
  final Function(int?, int?) onApply;

  const _FilterBottomSheet({
    required this.currentMonth,
    required this.currentYear,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late int? selectedMonth;
  late int? selectedYear;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.currentMonth;
    selectedYear = widget.currentYear;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Bộ lọc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Month picker
          const Text(
            'Tháng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(12, (index) {
              final month = index + 1;
              final isSelected = selectedMonth == month;
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedMonth = isSelected ? null : month;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'T$month',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Year picker
          const Text(
            'Năm',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(5, (index) {
              final year = now.year - index;
              final isSelected = selectedYear == year;
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedYear = isSelected ? null : year;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$year',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(selectedMonth, selectedYear);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Áp dụng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
