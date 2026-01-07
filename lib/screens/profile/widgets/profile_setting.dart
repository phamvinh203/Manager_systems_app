import 'package:flutter/material.dart';

class ProfileSetting extends StatefulWidget {
  const ProfileSetting({super.key});

  @override
  State<ProfileSetting> createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  // Thông báo
  bool _pushNotificationsEnabled = true;
  bool _checkInReminderEnabled = true;
  bool _checkOutReminderEnabled = true;
  
  // Giao diện
  bool _darkModeEnabled = false;
  
  // Thời gian nhắc nhở
  TimeOfDay _checkInTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 17, minute: 30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ===== TÀI KHOẢN =====
          _buildSectionHeader('Tài khoản'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.person_outline,
              title: 'Thông tin cá nhân',
              subtitle: 'Cập nhật thông tin của bạn',
              onTap: () {
                // TODO: Navigate to profile detail
              },
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: 'Đổi mật khẩu',
              subtitle: 'Cập nhật mật khẩu đăng nhập',
              onTap: () {
                // TODO: Navigate to change password
              },
            ),
          ]),

          const SizedBox(height: 24),

          // ===== THÔNG BÁO =====
          _buildSectionHeader('Thông báo'),
          _buildSettingsCard([
            _buildSwitchItem(
              icon: Icons.notifications_outlined,
              title: 'Thông báo đẩy',
              subtitle: 'Nhận thông báo từ ứng dụng',
              value: _pushNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _pushNotificationsEnabled = value;
                  if (!value) {
                    _checkInReminderEnabled = false;
                    _checkOutReminderEnabled = false;
                  }
                });
              },
            ),
            if (_pushNotificationsEnabled) ...[
              _buildDivider(),
              _buildSwitchItem(
                icon: Icons.login,
                title: 'Nhắc check-in',
                subtitle: 'Nhắc nhở lúc ${_formatTime(_checkInTime)}',
                value: _checkInReminderEnabled,
                onChanged: (value) {
                  setState(() {
                    _checkInReminderEnabled = value;
                  });
                },
                onTap: _checkInReminderEnabled ? () => _selectTime(true) : null,
              ),
              _buildDivider(),
              _buildSwitchItem(
                icon: Icons.logout,
                title: 'Nhắc check-out',
                subtitle: 'Nhắc nhở lúc ${_formatTime(_checkOutTime)}',
                value: _checkOutReminderEnabled,
                onChanged: (value) {
                  setState(() {
                    _checkOutReminderEnabled = value;
                  });
                },
                onTap: _checkOutReminderEnabled ? () => _selectTime(false) : null,
              ),
            ],
          ]),

          const SizedBox(height: 24),

          // ===== GIAO DIỆN =====
          _buildSectionHeader('Giao diện'),
          _buildSettingsCard([
            _buildSwitchItem(
              icon: Icons.dark_mode_outlined,
              title: 'Chế độ tối',
              subtitle: 'Bật giao diện tối cho ứng dụng',
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
                // TODO: Apply dark mode
              },
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.language,
              title: 'Ngôn ngữ',
              subtitle: 'Tiếng Việt',
              onTap: () {
                _showLanguageDialog();
              },
            ),
          ]),

          const SizedBox(height: 24),

          // ===== HỖ TRỢ =====
          _buildSectionHeader('Hỗ trợ'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.help_outline,
              title: 'Trung tâm trợ giúp',
              subtitle: 'Câu hỏi thường gặp & hỗ trợ',
              onTap: () {
                // TODO: Navigate to help center
              },
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.bug_report_outlined,
              title: 'Báo lỗi',
              subtitle: 'Gửi phản hồi về lỗi ứng dụng',
              onTap: () {
                // TODO: Navigate to bug report
              },
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.star_outline,
              title: 'Đánh giá ứng dụng',
              subtitle: 'Đánh giá trên App Store',
              onTap: () {
                // TODO: Open app store
              },
            ),
          ]),

          const SizedBox(height: 24),

          // ===== THÔNG TIN =====
          _buildSectionHeader('Thông tin'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.info_outline,
              title: 'Về ứng dụng',
              subtitle: 'Phiên bản 1.0.0',
              onTap: () {
                _showAboutDialog();
              },
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.description_outlined,
              title: 'Điều khoản sử dụng',
              onTap: () {
                // TODO: Navigate to terms
              },
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Chính sách bảo mật',
              onTap: () {
                // TODO: Navigate to privacy
              },
            ),
          ]),

          const SizedBox(height: 24),

          

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ===== WIDGETS =====

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 60,
      endIndent: 16,
      color: Color(0xFFF1F5F9),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDanger 
                    ? const Color(0xFFFEE2E2) 
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDanger 
                    ? const Color(0xFFEF4444) 
                    : const Color(0xFF64748B),
              ),
            ),

            const SizedBox(width: 14),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDanger 
                          ? const Color(0xFFEF4444) 
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDanger 
                  ? const Color(0xFFFCA5A5) 
                  : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFF64748B),
              ),
            ),

            const SizedBox(width: 14),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        if (onTap != null) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.edit,
                            size: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Switch
            Transform.scale(
              scale: 0.85,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== DIALOGS =====

  Future<void> _selectTime(bool isCheckIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isCheckIn ? _checkInTime : _checkOutTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInTime = picked;
        } else {
          _checkOutTime = picked;
        }
      });
      // TODO: Update notification schedule
    }
  }

  void _showLanguageDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chọn ngôn ngữ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            _buildLanguageOption('Tiếng Việt', '🇻🇳', true),
            _buildLanguageOption('English', '🇺🇸', false),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String title, String flag, bool isSelected) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF3B82F6))
          : null,
      onTap: () {
        Navigator.pop(context);
        // TODO: Change language
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.access_time_filled,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Chấm Công',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              
              const SizedBox(height: 4),
              
              const Text(
                'Phiên bản 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Build', style: TextStyle(color: Color(0xFF64748B))),
                        Text('2025.01.07', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Platform', style: TextStyle(color: Color(0xFF64748B))),
                        Text('Flutter', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                '© 2025 Your Company.\nAll rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  // ===== HELPERS =====

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}