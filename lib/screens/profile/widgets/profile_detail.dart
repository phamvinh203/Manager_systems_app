import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/blocs/employee/employee_bloc.dart';
import 'package:mobile/blocs/employee/employee_event.dart';
import 'package:mobile/blocs/employee/employee_state.dart';
import 'package:mobile/core/storage/token_storage.dart';
import 'package:mobile/utils/formatters.dart';

class ProfileDetail extends StatefulWidget {
  const ProfileDetail({super.key});

  @override
  State<ProfileDetail> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  @override
  void initState() {
    super.initState();
    _loadCurrentEmployee();
  }

  Future<void> _loadCurrentEmployee() async {
    final userId = await TokenStorage.getUserId();
    if (userId != null && mounted) {
      context.read<EmployeeBloc>().add(LoadCurrentEmployeeEvent(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          final employee = state.currentEmployee;

          if (employee == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadCurrentEmployee,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  const SizedBox(height: 24),

                  _buildSectionHeader('Personal Information'),

                  _buildInfoCard([
                    _buildInfoItem(
                      icon: Icons.badge_outlined,
                      label: 'Employee Code',
                      value: employee.code,
                      color: const Color(0xFF3B82F6),
                    ),
                    _buildInfoItem(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: employee.email ?? 'N/A',
                      color: const Color(0xFF10B981),
                    ),
                    _buildInfoItem(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: employee.phone ?? 'N/A',
                      color: const Color(0xFFF59E0B),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Work Information Section
                  _buildSectionHeader('Work Information'),

                  _buildInfoCard([
                    _buildInfoItem(
                      icon: Icons.work_outline,
                      label: 'Position',
                      value: employee.positionName.isEmpty
                          ? 'N/A'
                          : employee.positionName,
                      color: const Color(0xFF8B5CF6),
                    ),
                    _buildInfoItem(
                      icon: Icons.business_outlined,
                      label: 'Department',
                      value: employee.departmentName.isEmpty
                          ? 'N/A'
                          : employee.departmentName,
                      color: const Color(0xFFEC4899),
                    ),
                    _buildInfoItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Hire Date',
                      value: Formatters.formatDate(employee.hiredAt),
                      color: const Color(0xFF06B6D4),
                    ),
                  ]),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),

          const SizedBox(width: 16),

          // Label & Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
