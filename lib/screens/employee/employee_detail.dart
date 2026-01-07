import 'package:flutter/material.dart';
import 'package:mobile/models/employee_model.dart';
import 'package:mobile/screens/employee/edit_employee.dart';
import 'package:mobile/utils/formatters.dart';
import 'package:mobile/utils/employee_helpers.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Employee Details',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEmployeeScreen(employee: employee),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar Section
            _buildAvatarSection(),

            const SizedBox(height: 30),

            // Employee Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildInfoSection(),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final String initials = EmployeeHelpers.getInitials(
      employee.firstName,
      employee.lastName,
    );

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: EmployeeHelpers.getAvatarColor(employee.departmentName),
            boxShadow: [
              BoxShadow(
                color: EmployeeHelpers.getAvatarColor(
                  employee.departmentName,
                ).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          employee.fullName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          employee.positionName,
          style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),
        StatusBadge(status: employee.status),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Information
        _buildSectionTitle('Personal Information'),
        _buildInfoRow(Icons.person, 'Full Name', employee.fullName),
        _buildInfoRow(Icons.email, 'Email', employee.email ?? 'N/A'),
        _buildInfoRow(Icons.phone, 'Phone', employee.phone ?? 'N/A'),
        _buildInfoRow(Icons.badge, 'Employee Code', employee.code),

        const SizedBox(height: 24),

        // Work Information
        _buildSectionTitle('Work Information'),
        _buildInfoRow(
          Icons.work,
          'Position',
          employee.positionName.isEmpty ? 'N/A' : employee.positionName,
        ),
        _buildInfoRow(
          Icons.business,
          'Department',
          employee.departmentName.isEmpty ? 'N/A' : employee.departmentName,
        ),
        _buildInfoRow(
          Icons.account_balance_wallet,
          'Salary',
          Formatters.formatVND(employee.salary ?? 0),
        ),
        _buildInfoRow(
          Icons.calendar_today,
          'Hired Date',
          Formatters.formatDate(employee.hiredAt),
        ),

        const SizedBox(height: 24),

        // System Information
        _buildSectionTitle('System Information'),
        _buildInfoRow(
          Icons.add_circle,
          'Created At',
          employee.createdAt != null
              ? Formatters.formatDate(employee.createdAt!)
              : 'N/A',
        ),
        _buildInfoRow(
          Icons.update,
          'Updated At',
          employee.updatedAt != null
              ? Formatters.formatDate(employee.updatedAt!)
              : 'N/A',
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
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
