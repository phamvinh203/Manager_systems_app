import 'package:flutter/material.dart';
import 'package:mobile/models/employee_model.dart';
import 'package:mobile/utils/employee_helpers.dart';

class ProfileHeader extends StatelessWidget {
  final Employee employee;

  const ProfileHeader({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final initials = EmployeeHelpers.getInitials(
      employee.firstName,
      employee.lastName,
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          // Avatar with camera icon
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: EmployeeHelpers.getAvatarColor(
                    employee.departmentName,
                  ),
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

              // Camera icon ở góc dưới bên phải
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tên đầy đủ
          Text(
            employee.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),

          const SizedBox(height: 8),

          // Vị trí
          Text(
            employee.positionName,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
