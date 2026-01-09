import 'package:flutter/material.dart';

class ProfileMenuItems extends StatelessWidget {
  final VoidCallback? onMyProfileTap;
  final VoidCallback? onLeaveTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onLogoutTap;

  const ProfileMenuItems({
    super.key,
    this.onMyProfileTap,
    this.onLeaveTap,
    this.onSettingsTap,
    this.onTermsTap,
    this.onPrivacyTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Hồ sơ của tôi',
            onTap: onMyProfileTap,
          ),

          _buildMenuItem(
            icon: Icons.work_off_outlined,
            title: 'Đơn xin nghỉ phép',
            onTap: onLeaveTap,
          ),

          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            onTap: onSettingsTap,
          ),

          _buildMenuItem(
            icon: Icons.description_outlined,
            title: 'Điều khoản & Điều kiện',
            onTap: onTermsTap,
          ),

          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Chính sách bảo mật',
            onTap: onPrivacyTap,
          ),

          _buildMenuItem(
            icon: Icons.logout,
            title: 'Đăng xuất',
            onTap: onLogoutTap,
            isLogout: true,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
    bool isLogout = false,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Icon
                Icon(
                  icon,
                  size: 24,
                  color: isLogout
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF1E293B),
                ),

                const SizedBox(width: 16),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isLogout
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: const Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),

          // Divider
          if (showDivider)
            const Divider(
              height: 1,
              indent: 56,
              endIndent: 16,
              color: Color(0xFFE2E8F0),
            ),
        ],
      ),
    );
  }
}
