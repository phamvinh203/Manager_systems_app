import 'package:flutter/material.dart';
import 'package:mobile/utils/employee_helpers.dart';

class ManagerHeader extends StatelessWidget {
  final String departmentName;
  final String userName;
  final String? userAvatar;
  final VoidCallback? onSearchTap;
  final VoidCallback? onAvatarTap;

  const ManagerHeader({
    super.key,
    required this.departmentName,
    required this.userName,
    this.userAvatar,
    this.onSearchTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên phòng ban
          Text(
            departmentName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Row: Title + Search + Avatar
          Row(
            children: [
              // Title
              Expanded(
                child: const Text(
                  'Công việc Phòng ban',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Search button
              GestureDetector(
                onTap: onSearchTap,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Color(0xFF757575),
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Avatar
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: EmployeeHelpers.getAvatarColor(userName),
                    image: userAvatar != null
                        ? DecorationImage(
                            image: NetworkImage(userAvatar!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: userAvatar == null
                      ? Center(
                          child: Text(
                            EmployeeHelpers.getNameInitials(userName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
