import 'package:flutter/material.dart';
import 'package:mobile/core/services/notification_service.dart';

class NotificationSetting extends StatefulWidget {
  final ScrollController scrollController;

  const NotificationSetting({super.key, required this.scrollController});

  @override
  State<NotificationSetting> createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  final _notificationService = NotificationService();

  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _checkInReminderEnabled = true;
  bool _checkOutReminderEnabled = true;
  TimeOfDay _checkInTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 17, minute: 30);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notificationsEnabled = await _notificationService.isNotificationsEnabled();
    final checkInEnabled = await _notificationService.isCheckInReminderEnabled();
    final checkOutEnabled = await _notificationService.isCheckOutReminderEnabled();
    final checkInTime = await _notificationService.getCheckInTime();
    final checkOutTime = await _notificationService.getCheckOutTime();

    if (mounted) {
      setState(() {
        _notificationsEnabled = notificationsEnabled;
        _checkInReminderEnabled = checkInEnabled;
        _checkOutReminderEnabled = checkOutEnabled;
        _checkInTime = checkInTime;
        _checkOutTime = checkOutTime;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        _buildHeader(),

        // Bật/tắt toàn bộ thông báo
        SwitchListTile(
          title: const Text('Bật thông báo'),
          subtitle: Text(
            _notificationsEnabled
                ? 'Đang nhận thông báo'
                : 'Đã tắt toàn bộ thông báo',
          ),
          value: _notificationsEnabled,
          activeColor: const Color(0xFF22C55E),
          onChanged: _toggleAllNotifications,
        ),

        const Divider(height: 32),

        // Check-in reminder
        Opacity(
          opacity: _notificationsEnabled ? 1.0 : 0.5,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Nhắc nhở Check-in'),
                subtitle: Text('Hàng ngày lúc ${_checkInTime.format(context)}'),
                value: _checkInReminderEnabled && _notificationsEnabled,
                activeColor: const Color(0xFF3B82F6),
                onChanged: _notificationsEnabled ? _toggleCheckInReminder : null,
              ),
              ListTile(
                enabled: _notificationsEnabled && _checkInReminderEnabled,
                leading: const Icon(Icons.access_time, color: Color(0xFF3B82F6)),
                title: const Text('Giờ nhắc Check-in'),
                trailing: Text(
                  _checkInTime.format(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                onTap: () => _selectTime(isCheckIn: true),
              ),
            ],
          ),
        ),

        const Divider(height: 32),

        // Check-out reminder
        Opacity(
          opacity: _notificationsEnabled ? 1.0 : 0.5,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Nhắc nhở Check-out'),
                subtitle: Text('Hàng ngày lúc ${_checkOutTime.format(context)}'),
                value: _checkOutReminderEnabled && _notificationsEnabled,
                activeColor: const Color(0xFFF59E0B),
                onChanged: _notificationsEnabled ? _toggleCheckOutReminder : null,
              ),
              ListTile(
                enabled: _notificationsEnabled && _checkOutReminderEnabled,
                leading: const Icon(Icons.access_time, color: Color(0xFFF59E0B)),
                title: const Text('Giờ nhắc Check-out'),
                trailing: Text(
                  _checkOutTime.format(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                onTap: () => _selectTime(isCheckIn: false),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Reset button
        OutlinedButton.icon(
          onPressed: _resetToDefault,
          icon: const Icon(Icons.restore),
          label: const Text('Đặt lại mặc định'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Color(0xFF64748B)),
            ),
            const Expanded(
              child: Text(
                'Cài đặt thông báo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _toggleAllNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await _notificationService.setNotificationsEnabled(value);

    if (!value) {
      await _notificationService.cancelAll();
      _showSnackBar('Đã tắt toàn bộ thông báo');
    } else {
      if (_checkInReminderEnabled) {
        await _notificationService.scheduleCheckInReminder(
          hour: _checkInTime.hour,
          minute: _checkInTime.minute,
        );
      }
      if (_checkOutReminderEnabled) {
        await _notificationService.scheduleCheckOutReminder(
          hour: _checkOutTime.hour,
          minute: _checkOutTime.minute,
        );
      }
      _showSnackBar('Đã bật thông báo');
    }
  }

  Future<void> _toggleCheckInReminder(bool value) async {
    setState(() => _checkInReminderEnabled = value);

    if (value) {
      await _notificationService.scheduleCheckInReminder(
        hour: _checkInTime.hour,
        minute: _checkInTime.minute,
      );
    } else {
      await _notificationService.cancelCheckInReminder();
    }
  }

  Future<void> _toggleCheckOutReminder(bool value) async {
    setState(() => _checkOutReminderEnabled = value);

    if (value) {
      await _notificationService.scheduleCheckOutReminder(
        hour: _checkOutTime.hour,
        minute: _checkOutTime.minute,
      );
    } else {
      await _notificationService.cancelCheckOutReminder();
    }
  }

  Future<void> _selectTime({required bool isCheckIn}) async {
    if (!_notificationsEnabled) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: isCheckIn ? _checkInTime : _checkOutTime,
    );

    if (picked == null) return;

    setState(() {
      if (isCheckIn) {
        _checkInTime = picked;
        if (_checkInReminderEnabled) {
          _notificationService.scheduleCheckInReminder(
            hour: picked.hour,
            minute: picked.minute,
          );
        }
      } else {
        _checkOutTime = picked;
        if (_checkOutReminderEnabled) {
          _notificationService.scheduleCheckOutReminder(
            hour: picked.hour,
            minute: picked.minute,
          );
        }
      }
    });
  }

  Future<void> _resetToDefault() async {
    setState(() {
      _notificationsEnabled = true;
      _checkInReminderEnabled = true;
      _checkOutReminderEnabled = true;
      _checkInTime = const TimeOfDay(hour: 8, minute: 0);
      _checkOutTime = const TimeOfDay(hour: 17, minute: 30);
    });

    await _notificationService.setNotificationsEnabled(true);
    await _notificationService.scheduleCheckInReminder(hour: 8, minute: 0);
    await _notificationService.scheduleCheckOutReminder(hour: 17, minute: 30);

    _showSnackBar('Đã đặt lại mặc định');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}